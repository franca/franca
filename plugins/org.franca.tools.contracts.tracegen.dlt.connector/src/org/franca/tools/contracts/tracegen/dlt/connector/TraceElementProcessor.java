package org.franca.tools.contracts.tracegen.dlt.connector;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
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

	// all mapping should be based on the context id as key
	// maps the context id to the trace groups
	private Map<String, Set<Set<FTransition>>> contextTraceGroupMap;
	
	// maps the file path to the resolved model
	private Map<String, FContract> francaContractMap;
	
	private Map<String, String> contextIdPathMap;
	
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
		this.contextIdPathMap = new HashMap<String, String>();
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
				
				// a new file path has been selected by the user
				if (!request.getFilePath().equals(contextIdPathMap.get(request.getContextId()))) {
					contextTraceGroupMap.remove(request.getContextId());
					francaContractMap.remove(request.getContextId());
				}
				
				this.contextIdPathMap.put(request.getContextId(), request.getFilePath());
				Set<Set<FTransition>> initial = contextTraceGroupMap.get(request.getContextId());
				FContract contract = loadFrancaModel(request.getFilePath());
				
				// try resolving
				if (contract != null) {
					FModel model = (FModel) contract.eContainer().eContainer();
					Set<FEventOnIf> parsedEvents = traceParser.parseSingle(model, request.getTraceElement());
					
					TraceElementResponse response = new TraceElementResponse(request.getMessageId(), false, request.getContextId(), "");
					if (parsedEvents != null) {
						TraceValidationResult result = TraceValidator.isValidTrace(contract, parsedEvents, initial);
						response.setValid(result.valid);
						response.setData(prettyPrintExpectation(result.expected));
						contextTraceGroupMap.put(request.getContextId(), result.lastTraceGroup);
					}
					// send respond even if the validation failed due to some reason
					try {
						System.out.println("Response: "+response);
						TraceValidatorClient.send(response);
					} catch (IOException e) {
						e.printStackTrace();
					}
				}				
			}
		}	
	}
	
	private String prettyPrintExpectation(Set<FTransition> expected) {
		if (expected == null) return "";
			else {
			StringBuilder sb = new StringBuilder();
			
			// to filter out duplicates - there can be multiple different 
			// (equals yields false) FTransitions with the exact same String representation
			Set<String> _expected = new HashSet<String>();
			for (FTransition t : expected) {
				FEventOnIf event = t.getTrigger().getEvent();
				if (event.getCall() != null) {
					_expected.add("call_"+event.getCall().getName());
				}
				else if (event.getRespond() != null) {
					_expected.add("respond_"+event.getRespond().getName());
				}
				else if (event.getSignal() != null) {
					_expected.add("signal_"+event.getSignal().getName());
				}
			}
			
			int i = 0;
			for (String s : _expected) {
				sb.append(s);
				if (i < _expected.size() - 1) {
					sb.append(", ");
				}
				i++;
			}
			
			return sb.toString();
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
