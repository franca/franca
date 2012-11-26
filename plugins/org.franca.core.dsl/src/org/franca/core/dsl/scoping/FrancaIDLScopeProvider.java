/*******************************************************************************
 * Copyright (c) 2012 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.core.dsl.scoping;

import java.util.List;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EReference;
import org.eclipse.xtext.resource.EObjectDescription;
import org.eclipse.xtext.resource.IEObjectDescription;
import org.eclipse.xtext.scoping.IScope;
import org.eclipse.xtext.scoping.Scopes;
import org.eclipse.xtext.scoping.impl.AbstractDeclarativeScopeProvider;
import org.eclipse.xtext.scoping.impl.SimpleScope;
import org.franca.core.framework.FrancaHelpers;
import org.franca.core.franca.FContract;
import org.franca.core.franca.FDeclaration;
import org.franca.core.franca.FEventOnIf;
import org.franca.core.franca.FMethod;
import org.franca.core.franca.FState;
import org.franca.core.franca.FStateGraph;
import org.franca.core.franca.FTransition;
import org.franca.core.franca.FTrigger;

import com.google.common.collect.Lists;

/**
 * This class contains custom scoping description.
 * 
 * see : http://www.eclipse.org/Xtext/documentation/latest/xtext.html#scoping on
 * how and when to use it
 * 
 */
public class FrancaIDLScopeProvider extends AbstractDeclarativeScopeProvider {

	
	public IScope scope_FAssignment_lhs (FContract contract, EReference ref) {
		return Scopes.scopeFor(contract.getVariables());
	}

	
	public IScope scope_FTypedElementRef_element (FTransition tr, EReference ref) {
		final List<EObject> scopes = Lists.newArrayList();

		// add state variables of the enclosing contract to this scope
		FContract contract = FrancaHelpers.getContract(tr);
//		System.out.println("Scope " + tr.getTrigger().getEvent().toString());
		if (contract!=null) { 
			scopes.addAll(contract.getVariables());
//			for(FDeclaration d : contract.getVariables()) {
//				System.out.println("  var " + d.getName());
//			}
		}

		// add the trigger's parameters to this scope
		FEventOnIf ev = tr.getTrigger().getEvent();
		if (ev.getCall()!=null) {
			scopes.addAll(ev.getCall().getInArgs());
		} else if (ev.getRespond()!=null) {
			scopes.addAll(ev.getRespond().getOutArgs());
		} else if (ev.getSignal()!=null) {
			scopes.addAll(ev.getSignal().getOutArgs());
		}

		return Scopes.scopeFor(scopes);
	}

}
