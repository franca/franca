/*******************************************************************************
 * Copyright (c) 2016 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.connectors.protobuf;

import java.util.Map;

import org.franca.core.framework.MultiModelContainer;

import com.google.eclipse.protobuf.protobuf.Protobuf;

/**
 * Container for a Google Protobuf model (in the protobuf-dt representation).
 *  
 * @author Klaus Birken (itemis AG)
 */
public class ProtobufModelContainer extends MultiModelContainer<Protobuf> {

	public ProtobufModelContainer(Protobuf model) {
		super(model);
	}

	public ProtobufModelContainer(Map<Protobuf, String> part2filename) {
		super(part2filename);
	}
}
