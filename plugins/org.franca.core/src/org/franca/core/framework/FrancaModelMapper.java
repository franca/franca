/*******************************************************************************
 * Copyright (c) 2013 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.core.framework;

import org.eclipse.emf.common.notify.impl.AdapterImpl;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.util.EcoreUtil;

/**
 * When a Franca IDL model is transformed into a model of another IDL,
 * created model elements will usually have a 1:1 counterpart in the
 * source Franca model. This class provides the back references for
 * each of those model elements back to the Franca model.
 * 
 * As the implementation of this class use EMF adapters, the backlinks
 * will only be available after the transformation. They will be stored
 * only by the EMF model in memory, there will be no persistence of this
 * information.
 *  
 * @author kbirken
 */
public class FrancaModelMapper {

	static class MappingAdapter extends AdapterImpl {
		EObject francaObject;
		
		public MappingAdapter (EObject francaObject) {
			this.francaObject = francaObject;
		}
		
		@Override
		public boolean isAdapterForType (Object type) {
			return MappingAdapter.class == type;
		}

		public EObject getFrancaElement() {
			return francaObject;
		} 
	}
	
	public static void addBacklink (EObject otherObj, EObject francaObj) {
		MappingAdapter adapter = new MappingAdapter(francaObj);
		otherObj.eAdapters().add(adapter);
	}

	public static EObject getFrancaElement (EObject otherObj) {
		if (otherObj.eAdapters().isEmpty())
			return null;
		
		MappingAdapter adapter = (MappingAdapter) EcoreUtil
				.getAdapter(otherObj.eAdapters(), MappingAdapter.class);

		if (adapter==null)
			return null;
		
		return adapter.getFrancaElement();
	}
}
