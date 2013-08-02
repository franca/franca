/*******************************************************************************
 * Copyright (c) 2013 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.tools.contracts.tracegen.values.complex;

/**
 * 
 * @author Steffen Weik
 *
 */
public class NULL {

	private static final NULL instance = new NULL();

	private NULL() {
	}

	public static NULL getInstance() {
		return instance;
	}

}
