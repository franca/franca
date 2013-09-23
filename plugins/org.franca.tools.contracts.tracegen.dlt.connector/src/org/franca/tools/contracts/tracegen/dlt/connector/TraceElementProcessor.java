package org.franca.tools.contracts.tracegen.dlt.connector;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.xtext.resource.XtextResource;
import org.eclipse.xtext.resource.XtextResourceSet;
import org.franca.core.dsl.FrancaIDLStandaloneSetup;
import org.franca.core.franca.FContract;
import org.franca.core.franca.FEventOnIf;
import org.franca.core.franca.FModel;
import org.franca.core.franca.FTransition;
import org.franca.tools.contracts.tracegen.dlt.connector.client.TraceValidatorClient;
import org.franca.tools.contracts.validator.TraceValidationResult;
import org.franca.tools.contracts.validator.TraceValidator;
import org.franca.tools.contracts.validator.parser.ITraceParser;

import com.google.inject.Injector;

public class TraceElementProcessor extends Thread {

	private Map<String, Set<Set<FTransition>>> contextTraceGroupMap;
	private Map<String, FContract> francaContractMap;
	private List<TraceElementRequest> requests;
	private volatile boolean interrupted;
	private Injector injector;
	private ITraceParser traceParser;
	public static final TraceElementProcessor INSTANCE = new TraceElementProcessor();
	
	private TraceElementProcessor() {
		this.injector = new FrancaIDLStandaloneSetup().createInjectorAndDoEMFRegistration();
		this.requests = new ArrayList<TraceElementRequest>();
		this.interrupted = false;
		this.contextTraceGroupMap = new HashMap<String, Set<Set<FTransition>>>();
		this.francaContractMap = new HashMap<String, FContract>();
		this.traceParser = this.injector.getInstance(ITraceParser.class);
	}
	
	@Override
	public void run() {
		while (!interrupted) {
			TraceElementRequest request = null;
			synchronized (requests) {
				if (requests.isEmpty()) {
					try {
						// timeout wait is used to be able to check the state of 
						// the interrupted flag
						requests.wait(5000);
					} catch (InterruptedException e) {
						e.printStackTrace();
					}
				}
				else {
					request = requests.remove(0);
				}
			}
			
			if (request != null) {
				Set<Set<FTransition>> initial = contextTraceGroupMap.get(request.getContextId());
				FContract contract = loadFrancaModel(request.getFilePath());
				
				// try resolving
				if (contract != null) {
					FModel model = (FModel) contract.eContainer().eContainer();
					francaContractMap.put(request.getContextId(), contract);
					Set<FEventOnIf> parsedEvents = traceParser.parseSingle(model, request.getTraceElement());
					List<Set<FEventOnIf>> trace = new ArrayList<Set<FEventOnIf>>();
					trace.add(parsedEvents);
					TraceValidationResult result = TraceValidator.isValidTrace(contract, trace, initial);
					contextTraceGroupMap.put(request.getContextId(), result.lastTraceGroup);
					try {
						TraceValidatorClient.send(new TraceElementResponse(request.getMessageId(), result.valid, request.getContextId(), ""));
					} catch (IOException e) {
						e.printStackTrace();
					}
				}				
			}
		}	
	}
	
	private FContract loadFrancaModel(String filePath) {
		FContract contract = null;
		if (!francaContractMap.containsKey(filePath)) {
			XtextResourceSet resourceSet = injector.getInstance(XtextResourceSet.class);
			resourceSet.addLoadOption(XtextResource.OPTION_RESOLVE_ALL, Boolean.TRUE);
			Resource resource = resourceSet.getResource(URI.createFileURI(filePath), true);
			EObject rootObj = resource.getContents().get(0);
			if (rootObj != null && rootObj instanceof FModel) {
				FModel model = (FModel) rootObj;
				if (model.getInterfaces().size() > 0) {
					contract = model.getInterfaces().get(0).getContract();
					this.francaContractMap.put(filePath, contract);
				}
			}
		}
		return this.francaContractMap.get(filePath);
	}
	
	public void interruptThread() {
		this.interrupted = true;
	}
	
	public void addRequest(TraceElementRequest request) {
		synchronized (requests) {
			requests.add(request);
			requests.notify();
		}
	}
}
