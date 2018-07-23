/*******************************************************************************
 * Copyright (c) 2012 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.deploymodel.dsl.scoping

import com.google.inject.Inject
import java.util.List
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EReference
import org.eclipse.xtext.naming.IQualifiedNameConverter
import org.eclipse.xtext.naming.IQualifiedNameProvider
import org.eclipse.xtext.naming.QualifiedName
import org.eclipse.xtext.resource.EObjectDescription
import org.eclipse.xtext.resource.IEObjectDescription
import org.eclipse.xtext.scoping.IScope
import org.eclipse.xtext.scoping.impl.AbstractDeclarativeScopeProvider
import org.eclipse.xtext.scoping.impl.FilteringScope
import org.eclipse.xtext.scoping.impl.ImportUriGlobalScopeProvider
import org.eclipse.xtext.scoping.impl.SimpleScope
import org.franca.core.franca.FArrayType
import org.franca.core.franca.FCompoundType
import org.franca.core.franca.FEnumerationType
import org.franca.core.franca.FMapType
import org.franca.core.franca.FStructType
import org.franca.core.franca.FType
import org.franca.core.franca.FTypeDef
import org.franca.core.franca.FUnionType
import org.franca.deploymodel.core.FDModelUtils
import org.franca.deploymodel.core.PropertyMappings
import org.franca.deploymodel.dsl.fDeploy.FDAbstractExtensionElement
import org.franca.deploymodel.dsl.fDeploy.FDArgument
import org.franca.deploymodel.dsl.fDeploy.FDArgumentList
import org.franca.deploymodel.dsl.fDeploy.FDArray
import org.franca.deploymodel.dsl.fDeploy.FDAttribute
import org.franca.deploymodel.dsl.fDeploy.FDBroadcast
import org.franca.deploymodel.dsl.fDeploy.FDCompoundOverwrites
import org.franca.deploymodel.dsl.fDeploy.FDElement
import org.franca.deploymodel.dsl.fDeploy.FDEnumType
import org.franca.deploymodel.dsl.fDeploy.FDEnumValue
import org.franca.deploymodel.dsl.fDeploy.FDEnumeration
import org.franca.deploymodel.dsl.fDeploy.FDEnumerationOverwrites
import org.franca.deploymodel.dsl.fDeploy.FDExtensionElement
import org.franca.deploymodel.dsl.fDeploy.FDExtensionRoot
import org.franca.deploymodel.dsl.fDeploy.FDExtensionType
import org.franca.deploymodel.dsl.fDeploy.FDField
import org.franca.deploymodel.dsl.fDeploy.FDInterface
import org.franca.deploymodel.dsl.fDeploy.FDMap
import org.franca.deploymodel.dsl.fDeploy.FDMapKey
import org.franca.deploymodel.dsl.fDeploy.FDMapValue
import org.franca.deploymodel.dsl.fDeploy.FDMethod
import org.franca.deploymodel.dsl.fDeploy.FDModel
import org.franca.deploymodel.dsl.fDeploy.FDOverwriteElement
import org.franca.deploymodel.dsl.fDeploy.FDProperty
import org.franca.deploymodel.dsl.fDeploy.FDPropertyDecl
import org.franca.deploymodel.dsl.fDeploy.FDPropertyFlag
import org.franca.deploymodel.dsl.fDeploy.FDRootElement
import org.franca.deploymodel.dsl.fDeploy.FDSpecification
import org.franca.deploymodel.dsl.fDeploy.FDStruct
import org.franca.deploymodel.dsl.fDeploy.FDTypeOverwrites
import org.franca.deploymodel.dsl.fDeploy.FDTypedef
import org.franca.deploymodel.dsl.fDeploy.FDTypes
import org.franca.deploymodel.dsl.fDeploy.FDUnion
import org.franca.deploymodel.dsl.fDeploy.FDeployPackage
import org.franca.deploymodel.extensions.ExtensionRegistry

import static org.eclipse.xtext.EcoreUtil2.*

import static extension org.eclipse.xtext.scoping.Scopes.*
import static extension org.franca.core.FrancaModelExtensions.*
import static extension org.franca.deploymodel.core.FDModelUtils.*

class FDeployScopeProvider extends AbstractDeclarativeScopeProvider {

	@Inject
	private IQualifiedNameProvider qualifiedNameProvider

	@Inject
	private ImportUriGlobalScopeProvider importUriGlobalScopeProvider
	
	@Inject DeploySpecProvider deploySpecProvider;
	@Inject IQualifiedNameConverter qnConverter;
	
	def scope_FDRootElement_spec(EObject ctxt, EReference ref){
		return delegateGetScope(ctxt,ref).joinImportedDeploySpecs(ctxt);
	}
	
		
	def scope_FDSpecification_base(EObject ctxt, EReference ref){
		return delegateGetScope(ctxt,ref).joinImportedDeploySpecs(ctxt);
	}
	
	/** Evaluates the importedAliases of the FDModel containing the <i>ctxt</i> 
	 * and adds the belonging <i>FDSpecification</i>s to the given scope. */
	def joinImportedDeploySpecs(IScope scope, EObject ctxt){
		val model = getContainerOfType(ctxt, typeof(FDModel))
		val importedAliases = model.imports.filter[importedSpec!==null].map[importedSpec]
		val List<IEObjectDescription> fdSpecsScopeImports = <IEObjectDescription>newArrayList();
		try { 
			for(a:importedAliases){
				val entry = deploySpecProvider.getEntry(a)
				if(entry?.FDSpecification !== null){
					fdSpecsScopeImports.add(new EObjectDescription(qnConverter.toQualifiedName(a),entry.FDSpecification,null));
				}
			}
		} catch(Exception e) { e.printStackTrace}
		return new SimpleScope(scope,fdSpecsScopeImports,false)
	}

	def scope_FDAbstractExtensionElement_target(FDAbstractExtensionElement ctxt, EReference ref) {
		val elemDef = ExtensionRegistry.getElement(ctxt)
		if (elemDef.targetClass===null) {
			// no target class, skip reference to target object
			IScope::NULLSCOPE
		} else {
			// target class has been configured, collect all EObjects of that class which are visible from here
			val root = getContainerOfType(ctxt, typeof(FDExtensionRoot))
			val delegate = root.delegateGetScope(ref)
			new FilteringScope(delegate, [isAssignableFrom(elemDef.targetClass, it.EClass)])
		}
	}

	def scope_FDTypes_target(FDTypes ctxt, EReference ref) {	
		return new FTypeCollectionScope(IScope::NULLSCOPE, false, importUriGlobalScopeProvider, ctxt.eResource, qualifiedNameProvider);
	} 

	def scope_FDArray_target(FDTypes ctxt, EReference ref) {
		ctxt.getScopes(typeof(FArrayType))
	}

	def scope_FDStruct_target(FDTypes ctxt, EReference ref) {
		ctxt.getScopes(typeof(FStructType))
	}

	def scope_FDUnion_target(FDTypes ctxt, EReference ref) {
		ctxt.getScopes(typeof(FUnionType))
	}

	def scope_FDEnumeration_target(FDTypes ctxt, EReference ref) {
		ctxt.getScopes(typeof(FEnumerationType))
	}

	def scope_FDMap_target(FDTypes ctxt, EReference ref) {
		ctxt.getScopes(typeof(FMapType))
	}

	def scope_FDTypedef_target(FDTypes ctxt, EReference ref) {
		ctxt.getScopes(typeof(FTypeDef))
	}

	def private getScopes(FDTypes ctxt, Class<? extends EObject> clazz) {
		ctxt.getTarget().getTypes().filter(clazz).scopeFor
	}

	// *****************************************************************************
	def scope_FDAttribute_target(FDInterface ctxt, EReference ref) {
		ctxt.getTarget().getAttributes().scopeFor
	}

	def scope_FDMethod_target(FDInterface ctxt, EReference ref) {
		ctxt.getTarget().getMethods().scopeFor(
			[ QualifiedName.create(getUniqueName) ],
			IScope.NULLSCOPE
		)
	}

	def scope_FDBroadcast_target(FDInterface ctxt, EReference ref) {
		ctxt.getTarget().getBroadcasts().scopeFor(
			[ QualifiedName.create(getUniqueName) ],
			IScope.NULLSCOPE
		)
	}

	def scope_FDArray_target(FDInterface ctxt, EReference ref) {
		ctxt.getScopes(typeof(FArrayType))
	}

	def scope_FDStruct_target(FDInterface ctxt, EReference ref) {
		ctxt.getScopes(typeof(FStructType))
	}

	def scope_FDUnion_target(FDInterface ctxt, EReference ref) {
		ctxt.getScopes(typeof(FUnionType))
	}

	def scope_FDEnumeration_target(FDInterface ctxt, EReference ref) {
		ctxt.getScopes(typeof(FEnumerationType))
	}

	def scope_FDTypedef_target(FDInterface ctxt, EReference ref) {
		ctxt.getScopes(typeof(FTypeDef))
	}

	def private getScopes(FDInterface ctxt, Class<? extends EObject> clazz) {
		ctxt.getTarget().getTypes().filter(clazz).scopeFor
	}

	// *****************************************************************************
	def scope_FDArgument_target(FDArgumentList ctxt, EReference ref) {
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

	def scope_FDArgument_target(FDBroadcast ctxt, EReference ref) {
		ctxt.getTarget().getOutArgs.scopeFor
	}

	def scope_FDField_target(FDStruct ctxt, EReference ref) {
		ctxt.getTarget().getElements.scopeFor
	}

	def scope_FDField_target(FDUnion ctxt, EReference ref) {
		ctxt.getTarget().getElements.scopeFor
	}

	/**
	 * Compute the target elements (of type FField) for a given FDField,
	 * if the FDField is a child of a FDCompoundOverwrites section.</p>
	 * 
	 * I.e., ctxt will be either a struct overwrite section or a union
	 * overwrite section. The actual available fields depend on the 
	 * Franca type of the target element of the overwrite section's parent.
	 */
	def scope_FDField_target(FDCompoundOverwrites ctxt, EReference ref) {
		val parent = ctxt.eContainer as FDOverwriteElement
		val type = parent.getOverwriteTargetType
		if (type!==null) {
			if (type instanceof FCompoundType) {
				return type.elements.scopeFor
			}
		}
		IScope.NULLSCOPE
	}

	def scope_FDEnumValue_target(FDEnumeration ctxt, EReference ref) {
		ctxt.getTarget().getEnumerators.scopeFor
	}

	/**
	 * Compute the target elements (of type FEnumValue) for a given FDEnumValue,
	 * if the FDEnumValue is a child of a FDEnumerationOverwrites section.</p>
	 * 
	 * The actual available enumerators depend on the Franca type of the
	 * target element of the overwrite section's parent.
	 */
	def scope_FDEnumValue_target(FDEnumerationOverwrites ctxt, EReference ref) {
		val parent = ctxt.eContainer as FDOverwriteElement
		val type = parent.getOverwriteTargetType
		if (type!==null) {
			if (type instanceof FEnumerationType) {
				return type.enumerators.scopeFor
			}
		}
		IScope.NULLSCOPE
	}

	def scope_FDMap_target(FDInterface ctxt, EReference ref) {
		ctxt.getScopes(typeof(FMapType))
	}


	// *****************************************************************************

	/**
	 * Define scope for use-attribute of deployed type collections.</p>
	 * 
	 * Type collection deployments may only use other type collection deployments.</p>
	 */
	def IScope scope_FDRootElement_use(FDTypes elem, EReference ref) {
		val IScope delegateScope = elem.delegateGetScope(ref)
		new FilteringScope(delegateScope, [
			isAssignableFrom(FDeployPackage.eINSTANCE.FDTypes, it.EClass)
		])
	}
	
	/**
	 * Define scope for use-attribute of deployed interfaces.</p>
	 * 
	 * Interface deployments may only use type collection deployments
	 * and other interface deployments.</p>
	 */
	def IScope scope_FDRootElement_use(FDInterface elem, EReference ref) {
		val IScope delegateScope = elem.delegateGetScope(ref)
		new FilteringScope(delegateScope, [
			isAssignableFrom(FDeployPackage.eINSTANCE.FDTypes, it.EClass) ||
			isAssignableFrom(FDeployPackage.eINSTANCE.FDInterface, it.EClass)
		])
	}	

	/*
	 * Checks if two deployment definition roots have compatible specifications.</p>
	 * 
	 * Compatibility means either both parent and child elements reference the
	 * same specification or the child's specification is derived from the
	 * parent's specification.</p>
	 * 
	 * As derived DSLs may use some extended logic for retrieving the specification
	 * for a root element, this can be configured by providing a function argument.</p>
	 */
	def protected haveCompatibleSpecs(
		FDRootElement parent,
		FDRootElement child,
		(FDRootElement)=>FDSpecification specGetter
	) {
		val parentSpec = specGetter.apply(parent)
		var check = specGetter.apply(child)

		while (check !== null) {
			if (parentSpec == check)
				return true
			check = check.base
		} 
		false
	}


	// *****************************************************************************

	def scope_FDProperty_decl(FDExtensionRoot owner, EReference ref) {
		owner.getPropertyDecls
	}

	def scope_FDProperty_decl(FDExtensionElement owner, EReference ref) {
		owner.getPropertyDecls
	}

	def scope_FDProperty_decl(FDInterface owner, EReference ref) {
		owner.getPropertyDecls
	}

	def scope_FDProperty_decl(FDTypes owner, EReference ref) {
		owner.getPropertyDecls
	}

	def scope_FDProperty_decl(FDAttribute owner, EReference ref) {
		owner.getPropertyDecls
	}

	def scope_FDProperty_decl(FDMethod owner, EReference ref) {
		owner.getPropertyDecls
	}

	def scope_FDProperty_decl(FDBroadcast owner, EReference ref) {
		owner.getPropertyDecls
	}

	def scope_FDProperty_decl(FDArgument owner, EReference ref) {
		owner.getPropertyDecls
	}

	def scope_FDProperty_decl(FDArray owner, EReference ref) {
		owner.getPropertyDecls
	}

	def scope_FDProperty_decl(FDStruct owner, EReference ref) {
		owner.getPropertyDecls
	}

	def scope_FDProperty_decl(FDUnion owner, EReference ref) {
		owner.getPropertyDecls
	}

	def scope_FDProperty_decl(FDField owner, EReference ref) {
		owner.getPropertyDecls
	}

	def scope_FDProperty_decl(FDEnumeration owner, EReference ref) {
		owner.getPropertyDecls
	}

	def scope_FDProperty_decl(FDEnumValue owner, EReference ref) {
		owner.getPropertyDecls
	}

	def scope_FDProperty_decl(FDMap owner, EReference ref) {
		owner.getPropertyDecls
	}

	def scope_FDProperty_decl(FDMapKey owner, EReference ref) {
		owner.getPropertyDecls
	}

	def scope_FDProperty_decl(FDMapValue owner, EReference ref) {
		owner.getPropertyDecls
	}

	def scope_FDProperty_decl(FDTypedef owner, EReference ref) {
		owner.getPropertyDecls
	}

	/**
	 * The properties of an overwrite section are determined by the
	 * Franca type of the parent element (i.e., container element in
	 * the deployment definition model hierarchy).</p>
	 * 
	 * Example: In a FDStructOverwrites section, the parent element
	 * might be for example a FDAttribute. Validation will ensure that
	 * the Franca type of the FDAttribute target (which is an FAttribute)
	 * is an FStructType. Thus, the properties we are looking for here
	 * are all struct-related properties from the deployment specification.</p>    
	 */
	def scope_FDProperty_decl(FDTypeOverwrites owner, EReference ref) {
		val parent = owner.eContainer as FDOverwriteElement
		val type = parent.getOverwriteTargetType
		if (type!==null) {
			parent.getPropertyDecls(type)
		} else {
			IScope::NULLSCOPE
		}
	}

	def private IScope getPropertyDecls(FDElement elem) {
		val root = FDModelUtils::getRootElement(elem)
		PropertyMappings::getAllPropertyDecls(root.getSpec(), elem).scopeFor
	}

	def private IScope getPropertyDecls(FDElement some, FType elem) {
		val root = FDModelUtils::getRootElement(some)
		PropertyMappings::getAllPropertyDecls(root.getSpec(), elem).scopeFor
	}

	// *****************************************************************************
	// simple type system

	def scope_FDGeneric_value(FDPropertyFlag elem, EReference ref) {
		val decl = elem.eContainer as FDPropertyDecl
		decl.getPropertyDeclGenericScopes(decl, ref)
	}

	def scope_FDGeneric_value(FDProperty elem, EReference ref) {
		elem.getDecl.getPropertyDeclGenericScopes(elem, ref)
	}

	def private IScope getPropertyDeclGenericScopes(
		FDPropertyDecl decl,
		EObject ctxt,
		EReference ref
	) {
		val typeRef = decl.getType
		if (typeRef.getComplex !== null) {
			val type = typeRef.getComplex
			if (type instanceof FDEnumType) {
				return type.getEnumerators.scopeFor
			} else if (type instanceof FDExtensionType) {
				// get scope for possible value references for extension type
				val typeDef = ExtensionRegistry.findType(type.name)
				val delegate = ctxt.delegateGetScope(ref)
				return typeDef.getScope(delegate)
			}
		}
		IScope::NULLSCOPE
	}

}
