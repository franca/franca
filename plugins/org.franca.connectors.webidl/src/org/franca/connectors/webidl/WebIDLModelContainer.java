package org.franca.connectors.webidl;

import org.franca.core.framework.IModelContainer;
import org.waml.w3c.webidl.webIDL.IDLDefinitions;

public class WebIDLModelContainer implements IModelContainer {
	private IDLDefinitions model = null;
	
	public WebIDLModelContainer (IDLDefinitions model) {
		this.model = model;
	}
	
	public IDLDefinitions model() {
		return model;
	}
}
