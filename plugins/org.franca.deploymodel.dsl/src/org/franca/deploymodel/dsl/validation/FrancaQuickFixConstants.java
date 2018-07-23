/*******************************************************************************
 * Copyright (c) 2013 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.deploymodel.dsl.validation;

import org.franca.deploymodel.dsl.fDeploy.FDElement;

/**
 * These constants indicated {@link FDElement} types during quickfix resolution. 
 * 
 * @author Tamas Szabo
 *
 */
public enum FrancaQuickFixConstants {

	INTERFACE,
	ATTRIBUTE,
	METHOD,
	BROADCAST,
	ARRAY,
	STRUCT,
	UNION,
	ENUMERATION,
	MAP,
	MAP_KEY,
	MAP_VALUE,
	TYPEDEF
	
}
