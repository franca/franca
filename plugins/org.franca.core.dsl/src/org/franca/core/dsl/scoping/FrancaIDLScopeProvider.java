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
import org.eclipse.emf.mwe2.language.scoping.QualifiedNameProvider;
import org.eclipse.xtext.scoping.IScope;
import org.eclipse.xtext.scoping.Scopes;
import org.eclipse.xtext.scoping.impl.AbstractDeclarativeScopeProvider;
import org.eclipse.xtext.scoping.impl.ImportUriGlobalScopeProvider;
import org.franca.core.FrancaModelExtensions;
import org.franca.core.contracts.TypeSystem;
import org.franca.core.franca.FCompoundType;
import org.franca.core.franca.FContract;
import org.franca.core.franca.FEventOnIf;
import org.franca.core.franca.FInterface;
import org.franca.core.franca.FTransition;
import org.franca.core.franca.FType;
import org.franca.core.franca.FTypeRef;
import org.franca.core.franca.FTypedElementRef;

import com.google.common.collect.Lists;
import com.google.inject.Inject;

/**
 * This class contains custom scoping description.
 * 
 * see : http://www.eclipse.org/Xtext/documentation/latest/xtext.html#scoping on
 * how and when to use it
 * 
 */
public class FrancaIDLScopeProvider extends AbstractDeclarativeScopeProvider {

	@Inject
	private QualifiedNameProvider qualifiedNameProvider;
	
	@Inject
	private ImportUriGlobalScopeProvider importUriGlobalScopeProvider;
	
	public IScope scope_FAssignment_lhs (FContract contract, EReference ref) {
		return Scopes.scopeFor(contract.getVariables());
	}
	
	public IScope scope_FTypeRef_derived(FInterface _interface, EReference ref) {
		return new FTypeScope(
				this.delegateGetScope(_interface, ref),
				true, 
				importUriGlobalScopeProvider, 
				_interface.eResource(), 
				qualifiedNameProvider
		);
	}

	public IScope scope_FTypedElementRef_element (FTransition tr, EReference ref) {
		final List<EObject> scopes = Lists.newArrayList();

		// add state variables of the enclosing contract to this scope
		FContract contract = FrancaModelExtensions.getContract(tr);
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

	public IScope scope_FTypedElementRef_field (FTypedElementRef var, EReference ref) {
		if (var.getTarget() == null) {
			return IScope.NULLSCOPE;
		}
		
		TypeSystem ts = new TypeSystem();
		FTypeRef typeRef = ts.getType(var.getTarget());
		//FTypedElement te = var.getTarget().getElement();
		//FType type = te.getType().getDerived();
		//While editing the model there might be no typeRef 
		if (typeRef != null) {
			FType type = typeRef.getDerived();
			if (type!=null && type instanceof FCompoundType) {
				FCompoundType compound = (FCompoundType)type;
				return Scopes.scopeFor(compound.getElements());
			}
		}
		return IScope.NULLSCOPE;
	}

}
