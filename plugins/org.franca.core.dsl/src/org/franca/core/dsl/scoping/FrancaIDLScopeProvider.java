/*******************************************************************************
 * Copyright (c) 2012 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.core.dsl.scoping;

import static org.franca.core.FrancaModelExtensions.getAllElements;
import static org.franca.core.FrancaModelExtensions.getTriggeringMethod;

import java.util.Collections;
import java.util.List;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EReference;
import org.eclipse.xtext.EcoreUtil2;
import org.eclipse.xtext.naming.IQualifiedNameProvider;
import org.eclipse.xtext.naming.QualifiedName;
import org.eclipse.xtext.resource.EObjectDescription;
import org.eclipse.xtext.resource.IEObjectDescription;
import org.eclipse.xtext.scoping.IScope;
import org.eclipse.xtext.scoping.Scopes;
import org.eclipse.xtext.scoping.impl.AbstractDeclarativeScopeProvider;
import org.eclipse.xtext.scoping.impl.ImportUriGlobalScopeProvider;
import org.eclipse.xtext.scoping.impl.SimpleScope;
import org.franca.core.FrancaModelExtensions;
import org.franca.core.franca.FCompoundInitializer;
import org.franca.core.franca.FContract;
import org.franca.core.franca.FEnumerationType;
import org.franca.core.franca.FEventOnIf;
import org.franca.core.franca.FInterface;
import org.franca.core.franca.FMethod;
import org.franca.core.franca.FModel;
import org.franca.core.franca.FModelElement;
import org.franca.core.franca.FQualifiedElementRef;
import org.franca.core.franca.FTransition;
import org.franca.core.franca.FType;
import org.franca.core.franca.FTypeRef;
import org.franca.core.franca.FTypedElement;

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
	private FrancaModelExtensions francaModelExtensions;
	
	@Inject
	private IQualifiedNameProvider qualifiedNameProvider;
	
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
	
	public IScope scope_FQualifiedElementRef_element (FTransition tr, EReference ref) {
		final List<EObject> scopes = Lists.newArrayList();

		// add state variables of the enclosing contract to this scope
		FContract contract = FrancaModelExtensions.getContract(tr);
		if (contract!=null) { 
			scopes.addAll(contract.getVariables());
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
		
		IScope outerTypeScope = this.getScope(EcoreUtil2.getContainerOfType(tr, FModel.class), ref);
		IScope scope = Scopes.scopeFor(scopes, outerTypeScope);
		
		FMethod method = getTriggeringMethod(ev);
		if (method != null) {
			FEnumerationType errorTypeDefinition = method.getErrors();
			if (errorTypeDefinition == null) {
				errorTypeDefinition = method.getErrorEnum();
			}
			if (errorTypeDefinition != null) {
				QualifiedName errorTypeName = QualifiedName.create("errordef");
				IEObjectDescription errorDescription =
						new EObjectDescription(errorTypeName, errorTypeDefinition, null);
				scope = new SimpleScope(scope, Collections.singleton(errorDescription));
			}
			
		}

		return scope;
	}
	
	public IScope scope_FQualifiedElementRef_field (FQualifiedElementRef var, EReference ref) {
		FQualifiedElementRef qualifier = var.getQualifier();
		
		if (qualifier == null) {
			return IScope.NULLSCOPE;
		}
		
		FModelElement lastQualifier = qualifier.getElement();
		if (lastQualifier == null) lastQualifier = qualifier.getField();
		
		if (lastQualifier instanceof FTypedElement) {
			FTypeRef typeRef = ((FTypedElement) lastQualifier).getType();
			FType type = typeRef.getDerived();
			Iterable<? extends FModelElement> elements = getAllElements(type);
			return Scopes.scopeFor(elements);
		} else if (lastQualifier != null) {
			// probably we are referencing a type
			Iterable<? extends FModelElement> elements = getAllElements(lastQualifier);
			return Scopes.scopeFor(elements);
		}
		
		return IScope.NULLSCOPE;
	}

	public IScope scope_FFieldInitializer_element (FCompoundInitializer initializer, EReference ref) {
		FTypeRef expected = InitializerMapper.getExpectedType(initializer);
		if (expected.getDerived()==null)
			return IScope.NULLSCOPE;

		Iterable<? extends FModelElement> elements = getAllElements(expected.getDerived());
		return Scopes.scopeFor(elements);
	}
	
}
