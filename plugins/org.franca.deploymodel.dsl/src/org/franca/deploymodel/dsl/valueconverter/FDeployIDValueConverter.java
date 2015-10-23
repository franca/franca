/*******************************************************************************
 * Copyright (c) 2015 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.deploymodel.dsl.valueconverter;

import org.eclipse.xtext.conversion.impl.IDValueConverter;
import org.eclipse.xtext.nodemodel.INode;

public class FDeployIDValueConverter extends IDValueConverter {

	FDeployIDValueConverter() {
		super();
	}

	/**
	 * The toValue method is overridden in order to support fully qualified names
	 * where single segments need to be escaped by "^" to avoid clashes with 
	 * keywords of the DSL. 
	 */
	@Override
	public String toValue(String string, INode node) {
		if (string == null)
			return null;
		return (string.startsWith("^") ? string.substring(1) : string).replaceAll("\\^", "");
	}

}
