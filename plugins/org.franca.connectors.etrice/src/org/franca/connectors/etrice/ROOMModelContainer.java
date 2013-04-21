/*******************************************************************************
 * Copyright (c) 2012 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.connectors.etrice;

import org.eclipse.etrice.core.room.RoomModel;
import org.franca.core.framework.IModelContainer;

public class ROOMModelContainer implements IModelContainer {
	private RoomModel model = null;
	
	public ROOMModelContainer (RoomModel model) {
		this.model = model;
	}
	
	public RoomModel model() {
		return model;
	}
}
