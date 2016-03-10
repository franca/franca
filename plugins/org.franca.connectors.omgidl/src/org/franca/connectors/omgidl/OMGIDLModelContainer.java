/*******************************************************************************
 * Copyright (c) 2016 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.connectors.omgidl;

import org.csu.idl.idlmm.TranslationUnit;
import org.franca.core.framework.IModelContainer;

/**
 * Container for an OMG IDL model (in the idl4emf representation).
 *  
 * @author Klaus Birken (itemis AG)
 */
public class OMGIDLModelContainer implements IModelContainer {
	private TranslationUnit model = null;
	
	public OMGIDLModelContainer (TranslationUnit model) {
		this.model = model;
	}
	
	public TranslationUnit model() {
		return model;
	}

 }
