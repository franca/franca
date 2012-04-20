package org.franca.connectors.dbus;

import org.franca.core.framework.IModelContainer;
import model.emf.dbusxml.NodeType;

public class DBusModelContainer implements IModelContainer {
	private NodeType model = null;
	
	public DBusModelContainer (NodeType model) {
		this.model = model;
	}
	
	public NodeType model() {
		return model;
	}
}
