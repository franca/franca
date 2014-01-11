/*******************************************************************************
 * Copyright (c) 2013 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
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
