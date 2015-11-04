/*******************************************************************************
 * Copyright (c) 2013 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.examples.validators.fidl;

import java.util.Collection;

import org.eclipse.xtext.resource.DefaultLocationInFileProvider;
import org.eclipse.xtext.resource.ILocationInFileProvider;
import org.eclipse.xtext.validation.ValidationMessageAcceptor;
import org.franca.core.dsl.validation.IFrancaExternalValidator;
import org.franca.core.franca.FContract;
import org.franca.core.franca.FInterface;
import org.franca.core.franca.FModel;
import org.franca.core.franca.FState;
import org.franca.core.franca.FrancaPackage;

import com.google.common.collect.ArrayListMultimap;
import com.google.common.collect.Multimap;

public class UniqueStateNameValidator implements IFrancaExternalValidator {

	ILocationInFileProvider locationProvider;

	public UniqueStateNameValidator() {
		locationProvider = new DefaultLocationInFileProvider();
	}

	@Override
	public void validateModel(FModel model,
			ValidationMessageAcceptor messageAcceptor) {

		for (FInterface _interface : model.getInterfaces()) {
			FContract contract = _interface.getContract();
			if (contract!=null) {
				Multimap<String, FState> stateNameMap = ArrayListMultimap.create();
	
				for (FState state : contract.getStateGraph().getStates()) {
					stateNameMap.put(state.getName(), state);
				}
	
				for (String name : stateNameMap.keySet()) {
					Collection<FState> states = stateNameMap.get(name);
					if (states.size() > 1) {
						for (FState state : states) {
							messageAcceptor.acceptError(
									"The name of the state is not unique!", state,
									FrancaPackage.Literals.FMODEL_ELEMENT__NAME,
									ValidationMessageAcceptor.INSIGNIFICANT_INDEX, 
									null);
						}
					}
				}
			}
		}
	}
}
