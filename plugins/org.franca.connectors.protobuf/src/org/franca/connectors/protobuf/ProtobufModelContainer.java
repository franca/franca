/*******************************************************************************
 * Copyright (c) 2016 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.connectors.protobuf;

import org.franca.core.framework.IModelContainer;

import com.google.eclipse.protobuf.protobuf.Protobuf;

/**
 * Container for a Google Protobuf model (in the protobuf-dt representation).
 *  
 * @author Klaus Birken (itemis AG)
 */
public class ProtobufModelContainer implements IModelContainer {
	private Protobuf model = null;
	
	public ProtobufModelContainer (Protobuf model) {
		this.model = model;
	}
	
	public Protobuf model() {
		return model;
	}

 }
