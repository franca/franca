/*******************************************************************************
 * Copyright (c) 2012 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.deploymodel.dsl.scoping

import java.util.List
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EReference
import org.eclipse.xtext.scoping.IScope
import org.eclipse.xtext.scoping.impl.AbstractDeclarativeScopeProvider
import org.franca.core.franca.FArgument
import org.franca.core.franca.FArrayType
import org.franca.core.franca.FEnumerationType
import org.franca.core.franca.FStructType
import org.franca.core.franca.FUnionType
import org.franca.deploymodel.dsl.FDModelHelper
import org.franca.deploymodel.dsl.fDeploy.FDArgument
import org.franca.deploymodel.dsl.fDeploy.FDArray
import org.franca.deploymodel.dsl.fDeploy.FDAttribute
import org.franca.deploymodel.dsl.fDeploy.FDBroadcast
import org.franca.deploymodel.dsl.fDeploy.FDElement
import org.franca.deploymodel.dsl.fDeploy.FDEnumType
import org.franca.deploymodel.dsl.fDeploy.FDEnumValue
import org.franca.deploymodel.dsl.fDeploy.FDEnumeration
import org.franca.deploymodel.dsl.fDeploy.FDField
import org.franca.deploymodel.dsl.fDeploy.FDInterface
import org.franca.deploymodel.dsl.fDeploy.FDInterfaceInstance
import org.franca.deploymodel.dsl.fDeploy.FDMethod
import org.franca.deploymodel.dsl.fDeploy.FDProperty
import org.franca.deploymodel.dsl.fDeploy.FDPropertyDecl
import org.franca.deploymodel.dsl.fDeploy.FDPropertyFlag
import org.franca.deploymodel.dsl.fDeploy.FDProvider
import org.franca.deploymodel.dsl.fDeploy.FDStruct
import org.franca.deploymodel.dsl.fDeploy.FDTypes
import org.franca.deploymodel.dsl.fDeploy.FDUnion

import static extension org.eclipse.xtext.scoping.Scopes.*
import org.franca.deploymodel.dsl.fDeploy.FDArgumentList

class FDeployScopeProvider extends AbstractDeclarativeScopeProvider {
	
	def scope_FDArray_target (FDTypes ctxt, EReference ref) {
		ctxt.getScopes(typeof(FArrayType))
	}

	def scope_FDStruct_target (FDTypes ctxt, EReference ref) {
		ctxt.getScopes(typeof(FStructType))
	}

	def scope_FDUnion_target (FDTypes ctxt, EReference ref) {
		ctxt.getScopes(typeof(FUnionType))
	}

	def scope_FDEnumeration_target (FDTypes ctxt, EReference ref) {
		ctxt.getScopes(typeof(FEnumerationType))
	}

	def private getScopes (FDTypes ctxt, Class<? extends EObject> clazz) {
		ctxt.getTarget().getTypes().filter(clazz).scopeFor
	}
	
	// *****************************************************************************
	
	def scope_FDAttribute_target (FDInterface ctxt, EReference ref) {
		ctxt.getTarget().getAttributes().scopeFor
	}
	
	def scope_FDMethod_target (FDInterface ctxt, EReference ref) {
		ctxt.getTarget().getMethods().scopeFor
	}

	def scope_FDBroadcast_target (FDInterface ctxt, EReference ref) {
		ctxt.getTarget().getBroadcasts().scopeFor
	}


	def scope_FDArray_target (FDInterface ctxt, EReference ref) {
		ctxt.getScopes(typeof(FArrayType))
	}
	
	def scope_FDStruct_target (FDInterface ctxt, EReference ref) {
		ctxt.getScopes(typeof(FStructType))
	}

	def scope_FDUnion_target (FDInterface ctxt, EReference ref) {
		ctxt.getScopes(typeof(FUnionType))
	}
	
	def scope_FDEnumeration_target (FDInterface ctxt, EReference ref) {
		ctxt.getScopes(typeof(FEnumerationType))
	}

	def private getScopes (FDInterface ctxt, Class<? extends EObject> clazz) { 	
		ctxt.getTarget().getTypes().filter(clazz).scopeFor
	}


	// *****************************************************************************

	def scope_FDArgument_target (FDArgumentList ctxt, EReference ref) {
		val owner = ctxt.eContainer
		switch (owner) {
			FDMethod: {
				if (ctxt == owner.inArguments)
					owner.target.inArgs.scopeFor
				else
					owner.target.outArgs.scopeFor
			}
			FDBroadcast: {
				owner.target.outArgs.scopeFor
			}
		}		
	}

	def scope_FDArgument_target (FDBroadcast ctxt, EReference ref) {
		ctxt.getTarget().getOutArgs.scopeFor
	}

	def scope_FDField_target (FDStruct ctxt, EReference ref) {
		ctxt.getTarget().getElements.scopeFor
	}

	def scope_FDField_target (FDUnion ctxt, EReference ref) {
		ctxt.getTarget().getElements.scopeFor
	}

	def scope_FDEnumValue_target (FDEnumeration ctxt, EReference ref) {
		ctxt.getTarget().getEnumerators.scopeFor
	}


	// *****************************************************************************

	def scope_FDProperty_decl (FDProvider owner, EReference ref) {
		owner.getPropertyDecls
	}

	def scope_FDProperty_decl (FDInterfaceInstance owner, EReference ref) {
		owner.getPropertyDecls
	}

	def scope_FDProperty_decl (FDInterface owner, EReference ref) {
		owner.getPropertyDecls
	}

	def scope_FDProperty_decl (FDAttribute owner, EReference ref) {
		owner.getPropertyDecls
	}

	def scope_FDProperty_decl (FDMethod owner, EReference ref) {
		owner.getPropertyDecls
	}
	
	def scope_FDProperty_decl (FDBroadcast owner, EReference ref) {
		owner.getPropertyDecls
	}

	def scope_FDProperty_decl (FDArgument owner, EReference ref) {
		owner.getPropertyDecls
	}

	def scope_FDProperty_decl (FDArray owner, EReference ref) {
		owner.getPropertyDecls
	}

	def scope_FDProperty_decl (FDStruct owner, EReference ref) {
		owner.getPropertyDecls
	}

	def scope_FDProperty_decl (FDUnion owner, EReference ref) {
		owner.getPropertyDecls
	}

	def scope_FDProperty_decl (FDField owner, EReference ref) {
		owner.getPropertyDecls
	}

	def scope_FDProperty_decl (FDEnumeration owner, EReference ref) {
		owner.getPropertyDecls
	}

	def scope_FDProperty_decl (FDEnumValue owner, EReference ref) {
		owner.getPropertyDecls
	}

	def private IScope getPropertyDecls (FDElement elem) {
		val root = FDModelHelper::getRootElement(elem)
		FDModelHelper::getAllPropertyDecls(root.getSpec(), elem).scopeFor
	}


	// *****************************************************************************
	// simple type system
	
	def scope_FDEnum_value (FDPropertyFlag elem, EReference ref) {
		if (elem.getDefault==null) {
			IScope::NULLSCOPE
		} else {
			val decl = elem.eContainer as FDPropertyDecl
			decl.getPropertyDeclEnumScopes
		}
	}
	
	def scope_FDEnum_value (FDProperty elem, EReference ref) {
		elem.getDecl.getPropertyDeclEnumScopes
	}
	
	def private IScope getPropertyDeclEnumScopes (FDPropertyDecl decl) {
		val typeRef = decl.getType
		if (typeRef.getComplex!=null) {
			val type = typeRef.getComplex
			if (type instanceof FDEnumType) {
				return (type as FDEnumType).getEnumerators.scopeFor
			}
		}
		
		IScope::NULLSCOPE
	}

}
