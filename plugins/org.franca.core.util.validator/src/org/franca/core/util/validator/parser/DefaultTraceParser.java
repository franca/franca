package org.franca.core.util.validator.parser;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.runtime.CoreException;
import org.franca.core.franca.FEventOnIf;
import org.franca.core.franca.FInterface;
import org.franca.core.franca.FModel;
import org.franca.core.franca.FState;
import org.franca.core.franca.FTransition;

public class DefaultTraceParser extends ITraceParser {

	private Map<String, FEventOnIf> eventMap;
	
	public DefaultTraceParser(FModel model) {
		super(model);
		this.eventMap = new HashMap<String, FEventOnIf>();
		initialize();
	}
	
	private void initialize() {
		for (FInterface _interface : model.getInterfaces()) {
			for (FState state : _interface.getContract().getStateGraph().getStates()) {
				for (FTransition transition : state.getTransitions()) {
					FEventOnIf event = transition.getTrigger().getEvent();
					eventMap.put(event.getCall().getName(), event);
				}
			}
		}
	}

	@Override
	public List<FEventOnIf> parseTrace(IFile file) {
		InputStreamReader streamReader = null;
		BufferedReader bufferedReader = null;
		List<FEventOnIf> trace = new ArrayList<FEventOnIf>();
		try {
			streamReader = new InputStreamReader(file.getContents());
			bufferedReader = new BufferedReader(streamReader);
			String line = null;
			while ((line = bufferedReader.readLine()) != null) {
				trace.add(eventMap.get(line));
			}
			return trace;
		}
		catch (CoreException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}
		finally {
			if (streamReader != null) {
				try {
					streamReader.close();
				} catch (IOException e) {
					e.printStackTrace();
				}
			}
			if (bufferedReader != null) {
				try {
					bufferedReader.close();
				} catch (IOException e) {
					e.printStackTrace();
				}
			}
		}
		return null;
	}

}
