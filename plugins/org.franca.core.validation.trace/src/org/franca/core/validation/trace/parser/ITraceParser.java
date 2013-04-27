package org.franca.core.validation.trace.parser;

import java.util.List;

import org.eclipse.core.resources.IFile;
import org.franca.core.franca.FEventOnIf;
import org.franca.core.franca.FModel;

public abstract class ITraceParser {

	protected FModel model;
	
	public ITraceParser(FModel model) {
		this.model = model;
	}
	
	public abstract List<FEventOnIf> parseTrace(IFile file);
	
}
