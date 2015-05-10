/*******************************************************************************
 * Copyright (c) 2012 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.core.dsl.scoping

import com.google.common.collect.Lists
import com.google.inject.Inject
import java.util.Collections
import java.util.List
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EReference
import org.eclipse.xtext.EcoreUtil2
import org.eclipse.xtext.naming.IQualifiedNameProvider
import org.eclipse.xtext.naming.QualifiedName
import org.eclipse.xtext.resource.EObjectDescription
import org.eclipse.xtext.scoping.IScope
import org.eclipse.xtext.scoping.Scopes
import org.eclipse.xtext.scoping.impl.AbstractDeclarativeScopeProvider
import org.eclipse.xtext.scoping.impl.ImportUriGlobalScopeProvider
import org.eclipse.xtext.scoping.impl.SimpleScope
import org.franca.core.FrancaModelExtensions
import org.franca.core.franca.FCompoundInitializer
import org.franca.core.franca.FContract
import org.franca.core.franca.FEventOnIf
import org.franca.core.franca.FInterface
import org.franca.core.franca.FModel
import org.franca.core.franca.FModelElement
import org.franca.core.franca.FQualifiedElementRef
import org.franca.core.franca.FTransition
import org.franca.core.franca.FTypedElement

import static extension org.franca.core.FrancaModelExtensions.*

import static extension org.eclipse.xtext.scoping.Scopes.*
import static extension org.franca.core.framework.FrancaHelpers.*

/**
 * This class contains custom scoping description.
 * 
 * see : http://www.eclipse.org/Xtext/documentation/latest/xtext.html#scoping on
 * how and when to use it
 *
 */
class FrancaIDLScopeProvider extends AbstractDeclarativeScopeProvider {
	
	@Inject
	private IQualifiedNameProvider qualifiedNameProvider
	
	@Inject
	private ImportUriGlobalScopeProvider importUriGlobalScopeProvider
	

	def IScope scope_FAssignment_lhs (FContract contract, EReference ref) {
		contract.variables.scopeFor
	}
	
	def IScope scope_FTypeRef_derived(FInterface _interface, EReference ref) {
		new FTypeScope(
				this.delegateGetScope(_interface, ref),
				true, 
				importUriGlobalScopeProvider, 
				_interface.eResource(), 
				qualifiedNameProvider
		)
	}

	
	// *****************************************************************************

	def IScope scope_FQualifiedElementRef_element (FTransition tr, EReference ref) {
		val List<EObject> scopes = Lists.newArrayList

		// add state variables of the enclosing contract to this scope
		val contract = FrancaModelExtensions.getContract(tr)
		if (contract!=null) { 
			scopes.addAll(contract.variables)
		}

		// add the trigger's parameters to this scope
		val ev = tr.trigger.event
		if (ev.call!=null) {
			scopes.addAll(ev.call.inArgs)
		} else if (ev.respond!=null) {
			scopes.addAll(ev.respond.outArgs)
		} else if (ev.signal!=null) {
			scopes.addAll(ev.signal.outArgs)
		}
		
		val container = EcoreUtil2::getContainerOfType(tr, typeof(FModel))
		val outerTypeScope = this.getScope(container, ref)
		var scope = Scopes.scopeFor(scopes, outerTypeScope)
		
		val method = getTriggeringMethod(ev)
		if (method != null) {
			var errorTypeDefinition = method.errors
			if (errorTypeDefinition == null) {
				errorTypeDefinition = method.errorEnum
			}
			if (errorTypeDefinition != null) {
				val errorTypeName = QualifiedName.create("errordef")
				val errorDescription =
						new EObjectDescription(errorTypeName, errorTypeDefinition, null)
				scope = new SimpleScope(scope, Collections.singleton(errorDescription))
			}
		}

		scope
	}
	
	def IScope scope_FQualifiedElementRef_field (FQualifiedElementRef elem, EReference ref) {
		val qualifier = elem.qualifier
		
		if (qualifier == null) {
			return IScope.NULLSCOPE
		}
		
		val lastQualifier = qualifier.element ?: qualifier.field
		if (lastQualifier instanceof FTypedElement) {
			val typeRef = (lastQualifier as FTypedElement).type
			val type = typeRef.derived
			val Iterable<? extends FModelElement> elements = getAllElements(type)
			return elements.scopeFor
		} else if (lastQualifier != null) {
			// probably we are referencing a type
			val Iterable<? extends FModelElement> elements = getAllElements(lastQualifier)
			return elements.scopeFor
		}
		
		IScope.NULLSCOPE
	}

	def IScope scope_FFieldInitializer_element(FCompoundInitializer initializer, EReference ref) {
		val expected = InitializerMapper.getExpectedType(initializer)
		if (expected.derived==null)
			return IScope.NULLSCOPE

		val Iterable<? extends FModelElement> elements = getAllElements(expected.derived)
		elements.scopeFor
	}
	

	// *****************************************************************************

//	def IScope scope_FEventOnIf_role (FContract contract, EReference ref) {
// 		if (contract instanceof FSystemContract) {
// 			val syscon = contract as FSystemContract
//			return Scopes.scopeFor(syscon.roles)
//		} else {
//			return IScope.NULLSCOPE
//		}
//	}
	
	def IScope scope_FEventOnIf_call (FEventOnIf ev, EReference ref) {
		getScope_FEventOnIf_method(ev)
	}
	
	def IScope scope_FEventOnIf_respond (FEventOnIf ev, EReference ref) {
		return getScope_FEventOnIf_method(ev);
	}
	
	def IScope scope_FEventOnIf_error (FEventOnIf ev, EReference ref) {
		return getScope_FEventOnIf_method(ev);
	}
	
	def private IScope getScope_FEventOnIf_method (FEventOnIf ev) {
		val contract = ev.getContract
//		if (contract instanceof FSystemContract) {
//			if (ev.role==null) {
//				IScope.NULLSCOPE
//			} else {
//				ev.role.interface.methods.scopeFor
//			}
//		} else {
			val api = contract.getInterface
			api.getAllMethods.scopeFor(
				[ QualifiedName.create(getUniqueName) ],
				IScope.NULLSCOPE
			)
//		}
	}
	
	def IScope scope_FEventOnIf_signal (FEventOnIf ev, EReference ref) {
		getScope_FEventOnIf_broadcast(ev)
	}
	
	def private IScope getScope_FEventOnIf_broadcast (FEventOnIf ev) {
		val contract = ev.getContract
//		if (contract instanceof FSystemContract) {
//			if (ev.role==null) {
//				IScope.NULLSCOPE
//			} else {
//				ev.role.interface.broadcasts.scopeFor
// 			}
// 		} else {
 			val api = contract.getInterface
			api.getAllBroadcasts.scopeFor(
				[ QualifiedName.create(getUniqueName) ],
				IScope.NULLSCOPE
			)
// 		}
 	}
 	
	def IScope scope_FEventOnIf_set (FEventOnIf ev, EReference ref) {
		getScope_FEventOnIf_attribute(ev)
	}
	
	def IScope scope_FEventOnIf_update (FEventOnIf ev, EReference ref) {
		getScope_FEventOnIf_attribute(ev)
	}
	
	def private IScope getScope_FEventOnIf_attribute(FEventOnIf ev) {
		val contract = ev.getContract
//		if (contract instanceof FSystemContract) {
//			if (ev.role==null) {
//				IScope.NULLSCOPE
//			} else {
//				ev.role.interface.attributes.scopeFor
//			}
//		} else {
			val api = contract.getInterface
			api.getAllAttributes.scopeFor
//		}
	}
	
	def private FContract getContract(EObject obj) {
		var i = obj
		while (i!=null && !(i instanceof FContract)) {
			i = i.eContainer
		}
		return i as FContract
	}

}
