/*******************************************************************************
 * Copyright (c) 2016 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.connectors.omgidl;

import java.util.List;
import java.util.Map;

import org.csu.idl.idlmm.TranslationUnit;
import org.franca.core.framework.IModelContainer;

import com.google.common.collect.Lists;
import com.google.common.collect.Maps;

/**
 * Container for an OMG IDL model (in the idl4emf representation).
 *  
 * @author Klaus Birken (itemis AG)
 */
public class OMGIDLModelContainer implements IModelContainer {
	
	/**
	 * A map containing the top-level model and all additional models which are #included
	 * from the top-level model or transitively. The map value contains the filename of the
	 * corresponding model.</p>
	 * 
	 * The first entry in the list is the top-level model.</p>
	 * 
	 * All resources corresponding to the TranslationUnits should be contained in the same ResourceSet.
	 */
	private Map<TranslationUnit, String> units = Maps.newLinkedHashMap();
	
	/**
	 * Constructor for creating the container for just one simple model.
	 * 
	 * @param model the OMG IDL model
	 */
	public OMGIDLModelContainer(TranslationUnit model) {
		String name = model.eResource().getURI().lastSegment();
		this.units.put(model, name);
	}
	
	/**
	 * Constructor for creating the container for a top-level model which 
	 * might import other models (including transitive includes).
	 * 
	 * @param unit2filename a map from all models to their corresponding filenames 
	 */
	public OMGIDLModelContainer(Map<TranslationUnit, String> units) {
		this.units.putAll(units);
	}
	
	public TranslationUnit model() {
		if (units.isEmpty())
			return null;
		return units.keySet().iterator().next();
	}

	
	public List<TranslationUnit> models() {
		return Lists.newArrayList(this.units.keySet());
	}

	public String getFilename(TranslationUnit unit) {
		return this.units.get(unit);
	}
 }
