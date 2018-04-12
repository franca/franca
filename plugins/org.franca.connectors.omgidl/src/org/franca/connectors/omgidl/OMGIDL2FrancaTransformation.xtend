/*******************************************************************************
 * Copyright (c) 2016 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.connectors.omgidl

import com.google.inject.Inject
import java.math.BigInteger
import java.util.List
import java.util.Map
import java.util.Set
import org.csu.idl.idlmm.AliasDef
import org.csu.idl.idlmm.ArrayDef
import org.csu.idl.idlmm.AttributeDef
import org.csu.idl.idlmm.BinaryExpression
import org.csu.idl.idlmm.ConstantDef
import org.csu.idl.idlmm.ConstantDefRef
import org.csu.idl.idlmm.Contained
import org.csu.idl.idlmm.EnumDef
import org.csu.idl.idlmm.EnumMember
import org.csu.idl.idlmm.ExceptionDef
import org.csu.idl.idlmm.Expression
import org.csu.idl.idlmm.Field
import org.csu.idl.idlmm.FixedDef
import org.csu.idl.idlmm.ForwardDef
import org.csu.idl.idlmm.IDLType
import org.csu.idl.idlmm.IdlmmPackage
import org.csu.idl.idlmm.Include
import org.csu.idl.idlmm.InterfaceDef
import org.csu.idl.idlmm.ModuleDef
import org.csu.idl.idlmm.OperationDef
import org.csu.idl.idlmm.ParameterDef
import org.csu.idl.idlmm.PrimitiveDef
import org.csu.idl.idlmm.PrimitiveKind
import org.csu.idl.idlmm.SequenceDef
import org.csu.idl.idlmm.StructDef
import org.csu.idl.idlmm.TranslationUnit
import org.csu.idl.idlmm.Typed
import org.csu.idl.idlmm.TypedefDef
import org.csu.idl.idlmm.UnaryExpression
import org.csu.idl.idlmm.UnionDef
import org.csu.idl.idlmm.UnionField
import org.csu.idl.idlmm.ValueExpression
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.util.EcoreUtil
import org.franca.core.framework.TransformationLogger
import org.franca.core.franca.FAnnotationType
import org.franca.core.franca.FAttribute
import org.franca.core.franca.FBasicTypeId
import org.franca.core.franca.FConstantDef
import org.franca.core.franca.FEnumerationType
import org.franca.core.franca.FEvaluableElement
import org.franca.core.franca.FExpression
import org.franca.core.franca.FInterface
import org.franca.core.franca.FMethod
import org.franca.core.franca.FModel
import org.franca.core.franca.FModelElement
import org.franca.core.franca.FOperator
import org.franca.core.franca.FStructType
import org.franca.core.franca.FType
import org.franca.core.franca.FTypeCollection
import org.franca.core.franca.FTypeDef
import org.franca.core.franca.FTypeRef
import org.franca.core.franca.FTypedElement
import org.franca.core.franca.FUnionType
import org.franca.core.franca.FrancaFactory

import static org.franca.core.framework.TransformationIssue.*

import static extension org.franca.core.FrancaModelExtensions.*
import static extension org.franca.core.framework.FrancaHelpers.*
import org.franca.core.franca.FAnnotationBlock

/**
 * Model-to-model transformation from OMG IDL (aka CORBA) to Franca IDL. 
 */
class OMGIDL2FrancaTransformation {
	
	val static FRANCA_IDL_EXT = 'fidl'
	val static HYPHEN = '_'
//	val static DEFAULT_NODE_NAME = "default"
	
	Map<EObject, EObject> map_IDL_Franca
	List<InterfaceDef> baseInterfaces
	int countOfSequence
	@Inject extension TransformationLogger

	var boolean usingBaseTypedefs
	Map<String, FTypeDef> baseTypedefs
	
//	List<FType> newTypes
	
	def getTransformationIssues() {
		return getIssues
	}
	
	def getTransformationMap() {
		map_IDL_Franca ?: newLinkedHashMap()
	}
	
	def isUsingBaseTypedefs() {
		return usingBaseTypedefs
	}
	
	
	/**
	 * Transform to a single Franca model
	 */
	def FModel transformToSingleFModel(TranslationUnit src, Map<EObject, EObject> map, FTypeCollection baseTypes) {
		clearIssues

		countOfSequence = 0
		baseInterfaces = newArrayList
		
		usingBaseTypedefs = false
		baseTypedefs = if (baseTypes===null) null else baseTypes.types.filter(FTypeDef).toMap[name]

		// register global map IDL2Franca to local one 
		map_IDL_Franca = map
		val model = factory.createFModel
		map_IDL_Franca.put(src, model)

		// get module which will be transformed (all others are ignored)		
		val module = src.relevantModule
		if (module===null) {
			model.name = URI.createFileURI(src.eResource.URI.trimFileExtension.lastSegment).lastSegment
		} else {
			model.name = module.nestedModuleName
			map_IDL_Franca.put(module, model)
		}

		// handle src.includes
		src.includes.forEach[include | include.transformIncludeDeclaration(model)]

		if (src.contains.empty) {
			addIssue(IMPORT_WARNING,
				src, IdlmmPackage::TRANSLATION_UNIT__IDENTIFIER,
				"Empty OMG IDL translation unit, created empty Franca model")
		} else {
			if (module===null) {
				// no module on top-level, or more than one module (special case)
				val modules = src.contains.filter(ModuleDef)
				if (modules.empty) {
					// transform interfaces on top-level of TranslationUnit
					val ifs = src.contains.filter(InterfaceDef)
					ifs.filter(Contained).transformItems(model)
				} else {
					// special case: more than one module on top-level, transform their contents
					// transform contents of modules, if any
					val contents = modules.map[contains].flatten
					contents.transformItems(model)
				}
			} else {
				// found one module on top-level of TranslationUnit
				module.contains.transformItems(model)
			}

			// sanity check on top-level elements
			val other = src.contains.findFirst[
				! ((it instanceof ModuleDef) || (it instanceof InterfaceDef) || (it instanceof ForwardDef))
			]
			if (other!==null) {
				addIssue(IMPORT_ERROR,
					src, IdlmmPackage::TRANSLATION_UNIT__CONTAINS,
					"Members of OMG IDL translation unit should be of type either 'interface' or 'module'")
			}
		}
		
		if (usingBaseTypedefs) {
			factory.createImport => [
				importedNamespace = "org.franca.omgidl.*"
				importURI = "OMGIDLBase.fidl"
				model.imports.add(it)
			]
		}

		model
	}

	def private transformItems(Iterable<Contained> items, FModel model) {
		for (i: items) {
			if (! map_IDL_Franca.containsKey(i)) {
				val transformed = i.transformDefinition(model)
				if (transformed!==null) {
					map_IDL_Franca.put(i, transformed)					
				}
			}
		}
	}
	
	/**
	 * Get OMG IDL module which will be transformed.
	 * 
	 * Restriction: Only the first module is transformed. Others are ignored.
	 * Another restriction: If there is a module, there should not be other elements.
	 */
	def private ModuleDef getRelevantModule(TranslationUnit unit) {
		val modules = unit.contains.filter(ModuleDef)
		if (modules.empty) {
			// no module at all
			null
		} else {
			if (unit.contains.size > modules.size) {
				// no other elements next to a module are allowed
				// (the resulting Franca model will get the module name as package name)
				addIssue(FEATURE_NOT_SUPPORTED,
					unit, IdlmmPackage::TRANSLATION_UNIT__CONTAINS,
					"All top-level elements next to a module in an OMG IDL translation unit will be ignored")
			}
			if (modules.size > 1) {
				// two or more modules, we do not use their name as package name
				addIssue(FEATURE_NOT_SUPPORTED,
					unit, IdlmmPackage::TRANSLATION_UNIT__CONTAINS,
					"More than one module in OMG IDL translation unit, will use filename as Franca package name")
					
				// check if there are nested modules
				for(m : modules) {
					if (m.contains.filter(ModuleDef).size > 1) {
						addIssue(FEATURE_NOT_SUPPORTED,
							m, IdlmmPackage::CONTAINER__CONTAINS,
							"Nested modules are ignored in a file with multiple OMG IDL modules")
					}
				} 
				
				// return null to indicate that the module name should not be used as Franca package name
				null 
			} else {
				// dive into first module
				modules.get(0).relevantSubModule
			}
		}
	}
	
	/**
	 * Get OMG IDL submodule which will be transformed.
	 * 
	 * We currently support nested modules, but there should be just one module on each level.
	 * 
	 * Restriction: Only the first submodule is transformed. Others are ignored.
	 * Another restriction: If there is a submodule, there should not be other elements.
	 */
	def private ModuleDef getRelevantSubModule(ModuleDef module) {
		val submodules = module.contains.filter(ModuleDef)
		if (submodules.empty) {
			// no submodule at all, return parent module
			module
		} else {
			if (submodules.size > 1) {
				// two or more modules, use first but issue warning
				addIssue(FEATURE_NOT_SUPPORTED,
					module, IdlmmPackage::CONTAINER__CONTAINS,
					"Only the first sub-module in an OMG IDL module is transformed, others are ignored")
			}
			// no other elements next to the modules are allowed
			// (the resulting Franca model will get the nested module name as package name)
			if (module.contains.size > submodules.size) {
				addIssue(FEATURE_NOT_SUPPORTED,
					module, IdlmmPackage::CONTAINER__CONTAINS,
					"All elements next to a submodule in an OMG IDL module will be ignored")
			}

			// dive into first submodule
			submodules.get(0).relevantSubModule
		}
	}

	/**
	 * Compute a FQN for a module or submodule in the OMG IDL model.
	 * 
	 * The FQN will be used as Franca IDL model name (i.e. package).
	 */
	def private String getNestedModuleName(ModuleDef module) {
		val parent = module.eContainer
		if (parent instanceof ModuleDef) {
			parent.nestedModuleName + "." + module.identifier
		} else {
			module.identifier
		}
	}

//	def private FModel transformModule(ModuleDef module, TranslationUnit src) {
//		var FModel model
//		// a module with the same name has already been processed
//		if (map_Name_Module.containsKey(module.identifier)) {
//			// get the already created FModel
//			model = map_IDL_Franca.get(map_Name_Module.get(module.identifier)) as FModel
//		} else {
//			model = factory.createFModel
//			model.name = module.identifier
//			val _model = model
//			src.includes.forEach[include | include.transformIncludeDeclaration(_model)]
//			map_Name_Module.put(module.identifier, module)
//			models.add(model)
//		}
//		if (!map_IDL_Franca.containsKey(module)){
//			map_IDL_Franca.put(module, model)
//		}
//		model
//	}
	
	/* ---------------------- dispatch transform Contained ------------------------- */
	def private dispatch FModelElement transformDefinition(InterfaceDef src, FModel target) {
		factory.createFInterface => [
			map_IDL_Franca.put(src, it)
			// transform all properties of this InterfaceDef
			name = src.identifier
			// interface inheritance
			if (!src.derivesFrom.isNullOrEmpty) {
				// we will collect all base interfaces (transitive main inheritance line or flattened) along the way   
				val Set<FInterface> baseTransitive = newHashSet
				
				// transform all base interfaces (OMG IDL supports multiple inheritance)
				for(derivedFrom : src.derivesFrom) {
					val transformedBase = (map_IDL_Franca.get(derivedFrom) ?: {
						// interface hasn't been transformed yet, do it now
						// src.derivesFrom.get(0) is defined in the current TranslationUnit, but maybe under another module
						val baseIDLInterface = src.derivesFrom.get(0)
						//val baseIDLModuleContainer = baseIDLInterface.moduleContainer
						val baseIDLTranslationUnitContainer = baseIDLInterface.moduleContainer
						var FModel model
						//if (baseIDLModuleContainer instanceof ModuleDef) {
						//	model = baseIDLModuleContainer.transformModule(baseIDLTranslationUnitContainer as TranslationUnit)
						//} else {
							model = map_IDL_Franca.get(baseIDLTranslationUnitContainer) as FModel
						//}
						val baseInterface = baseIDLInterface.transformDefinition(model)
						map_IDL_Franca.put(derivedFrom, baseInterface)
						baseInterface
					}) as FInterface

					if (src.derivesFrom.indexOf(derivedFrom)==0) {
						// only the first base interface is used as base of the Franca interface 
						it.base = transformedBase

						// remember all base interfaces along the chain
						baseTransitive.addAll(it.getInterfaceInheritationSet)
					} else {
						// all base interfaces except the first one are flattened into the transformed interface
						// the flattening is done for the base interface and all its base interfaces
						// (base interfaces as long as they are not covered by the main inheritance chain)
						// TODO: replace this after Franca IDL supports multiple interface inheritance
						
						var FInterface base2 = transformedBase
						while (base2!==null) {
							if (baseTransitive.contains(base2)) {
								// we already handled this base interface
								base2 = null
							} else {
								baseTransitive.add(base2)
								
								val comment = 
										"Member from original interface " + base2.name +
										" (currently Franca IDL does not support multiple inheritance)."
								for(a : base2.attributes) {
									val ac = EcoreUtil.copy(a)
									ac.addAnnotation(FAnnotationType.DETAILS, comment)
									it.attributes.add(ac)
								}
								for(m : base2.methods) {
									val mc = EcoreUtil.copy(m)
									mc.addAnnotation(FAnnotationType.DETAILS, comment)
									it.methods.add(mc)
								}
								// skip broadcasts, will not be generated by the OMG IDL transformation at all
							}
						}
						
						// create warning message to inform user 
						addIssue(FEATURE_NOT_FULLY_SUPPORTED,
							src, IdlmmPackage::INTERFACE_DEF__DERIVES_FROM,
							"OMG IDL multiple interface inheritance from '" + src.identifier + "' to '" + derivedFrom.identifier + "' will be flattened in Franca"
						)
					}
				}
			}
			// cache all the interfaces directly or indirectly extended by src
			baseInterfaces = src.baseInterfaces
			for (contained: src.contains) {
				val definition = contained.transformDefinition()

				switch (contained) {
					TypedefDef: types.add(definition as FType)
					ConstantDef: constants.add(definition as FConstantDef)
					AttributeDef: attributes.add(definition as FAttribute)
					OperationDef: methods.add(definition as FMethod)
				}
			}

			// set all type definitions in the Franca interface to public,
			// because in OMG IDL all data types are publicly visible
			types.forEach[public = true] 
				
			// 
			// reset the list
			baseInterfaces = newArrayList()

			// add resulting object to target model
			target.interfaces.add(it)
		]
	}

	def private void addAnnotation(FModelElement elem, FAnnotationType tag, String text) {
		if (elem.comment===null) {
			elem.comment = factory.createFAnnotationBlock
		}
		factory.createFAnnotation => [
			type = tag
			comment = text
			elem.comment.elements.add(it)
		]
	}

	def private dispatch FModelElement transformDefinition(TypedefDef src, FModel target) {
		val definition = src.transformDefinition as FType
		target.getTypeCollection().addInTypeCollection(definition)
		return definition
	}
	
	def private dispatch FModelElement transformDefinition(EnumMember src, FEnumerationType target) {
		factory.createFEnumerator => [
			name = src.identifier
			target.enumerators.add(it)
		]
	}
	
	def private dispatch FModelElement transformDefinition(ConstantDef src, FModel target) {
		val definition = src.transformDefinition as FConstantDef
//		target.mappedFrancaObject.typeCollection
		target.getTypeCollection().addInTypeCollection(definition)
//		addInAnonymousTypeCollection(definition)
		return definition
	}
	
	def private dispatch FModelElement transformDefinition(FixedDef src, FModel target) {
		val definition = src.transformDefinition as FType
		target.getTypeCollection().addInTypeCollection(definition)
		return definition
	}
	
	// catch-all for this dispatch method
	def private dispatch FModelElement transformDefinition(Contained src, FModel target) {
		val definition = src.transformDefinition
		if (definition !== null) {
			target.getTypeCollection().addInTypeCollection(definition)
		}
		return definition
	}

	
	/* ----------------- dispatch transform Contained without container -------------------- */
	
	def private dispatch FModelElement transformDefinition(Contained src) {
		addIssue(FEATURE_NOT_HANDLED_YET,
			src, IdlmmPackage::CONTAINED__IDENTIFIER,
			"OMG IDL definition '" + src.class.name + "' not handled yet (object '" + src.identifier + "')")
		return null
	}
	
	def private dispatch FModelElement transformDefinition(AttributeDef src) {
		factory.createFAttribute => [
			map_IDL_Franca.put(src, it)
			name = src.identifier
			readonly = src.isIsReadonly
			if (src.sharedType === null) {
				type = src.containedType.transformIDLType
			} else {
				type = src.sharedType.transformIDLType
			}
		]
	}
	
	def private dispatch FModelElement transformDefinition(OperationDef src) {
		factory.createFMethod => [
			map_IDL_Franca.put(src, it)
			name = src.identifier
			fireAndForget = src.isIsOneway
			if (src.sharedType!==null || !src.containedType.isVoid) {
				// add operation's return value as first out argument with name _RESULT 
				outArgs.add(
					factory.createFArgument => [
						name = "_RESULT"
						type =
							if (src.sharedType === null) {
								src.containedType.transformIDLType
							} else {
								src.sharedType.transformIDLType
							}
					]
				)
			}
			src.parameters.forEach[member | member.transformTyped(it)]
			if (!src.canRaise.isNullOrEmpty) {
				errors = factory.createFEnumerationType => [ errorContainer |
					// generate one enumerator for each exception
					for (exception: src.canRaise) {
						errorContainer.enumerators.add(
							factory.createFEnumerator => [
								name = exception.identifier
							]
						)
						// if the exception is a struct with at least one field, create one artifical FMethod to be used to retrieve the struct for this exception
						if (!exception.members.isNullOrEmpty) {
							factory.createFMethod => [ method |
								method.name = 'getException' + it.name.toFirstUpper + exception.identifier.toFirstUpper
								method.outArgs.add(
									factory.createFArgument => [
										name = exception.identifier
										type = exception.transformIDLType
									]
								)
								(src.mappedTypeCollection as FInterface).methods.add(method)
							]
						}
					}
				]
			}
//			src.canRaise.forEach[exception | exception.]
		]
	}

	def private isVoid(IDLType type) {
		if (type instanceof PrimitiveDef) {
			type.kind==PrimitiveKind.PK_VOID
		} else {
			false
		}
	}
	
	def private dispatch FModelElement transformDefinition(AliasDef src) {
		factory.createFTypeDef => [
			map_IDL_Franca.put(src, it)
			name = src.identifier
			if (src.sharedType === null) {
				actualType = src.containedType.transformIDLType
			} else {
				actualType = src.sharedType.transformIDLType
			}
		]
	}
	
	def private dispatch FModelElement transformDefinition(StructDef src) {
		factory.createFStructType => [
			map_IDL_Franca.put(src, it)
			name = src.identifier
			src.members.forEach[member | member.transformTyped(it)]
		]
	}
	
	def private dispatch FModelElement transformDefinition(EnumDef src) {
		factory.createFEnumerationType => [
			map_IDL_Franca.put(src, it)
			name = src.identifier
			src.members.forEach[member | member.transformDefinition(it)]
		]
	}
	
	def private dispatch FModelElement transformDefinition(UnionDef src) {
		val result = factory.createFUnionType => [
			map_IDL_Franca.put(src, it)
			name = src.identifier
			src.unionMembers.forEach[member | member.transformTyped(it)]
		]
		if (src.sharedDiscrim!==null) {
			result.addSourceAnno("switch '" + src.sharedDiscrim.identifier + "'")
		}
		result
	}
	
	def private dispatch FModelElement transformDefinition(ConstantDef src) {
		factory.createFConstantDef => [
			map_IDL_Franca.put(src, it)
			name = src.identifier
			if (src.sharedType === null) {
				type = src.containedType.transformIDLType
			} else {
				type = src.sharedType.transformIDLType
			}
			rhs = src.constValue.transformExpression(type)
		]
	}
	
	def private dispatch FModelElement transformDefinition(FixedDef src) {
		val digits = (src.digits as ValueExpression).value
		val scale = (src.scale as ValueExpression).value
		factory.createFTypeDef => [ alias |
			map_IDL_Franca.put(src, alias)
			alias.name = '''Fixed_«digits»_«scale»'''
			alias.actualType = factory.createFTypeRef => [ ref |
				// TODO: should fixed<..,..> be really mapped to UINT32?
				ref.predefined = FBasicTypeId.UINT32
			]
		]
	}
		
	def private dispatch FModelElement transformDefinition(ExceptionDef src) {
		if (src.members.isNullOrEmpty) {
			null
		} else {
			factory.createFStructType => [
				map_IDL_Franca.put(src, it)
				name = src.identifier
				src.members.forEach[member | member.transformTyped(it)]
				it.addSourceAnno("exception '" + name + "'")
			]
		}
	}
	
	/*------------------ transform Typed --------------------------------- */
	
	def private dispatch void transformTyped(Typed src, FStructType target) {
		addIssue(FEATURE_NOT_HANDLED_YET,
			src, IdlmmPackage::TYPED,
			"OMG IDL Typed '" + src.class.name + "' not handled yet (object '" + src.toString + "')")
	}
	
	def private dispatch void transformTyped (Typed src, FTypedElement target) {
		if (src.sharedType === null) {
			target.type = src.containedType.transformIDLType
		} else {
			target.type = src.sharedType.transformIDLType
		}
		if (src instanceof SequenceDef) {
			target.array = true
		}
	}
	
	def private dispatch void transformTyped(Field src, FStructType target) {
		factory.createFField => [
			name = src.identifier
			if (src.sharedType !== null) {
				type = src.sharedType.transformIDLType
			} else {
				val ct = src.containedType
				switch (ct) {
					PrimitiveDef: type = ct.transformIDLType
					StructDef: {
						map_IDL_Franca.put(ct, ct.transformDefinition(map_IDL_Franca.get(src.container)))
						type = src.containedType.transformIDLType
					}
					ArrayDef: {
						type = ct.transformIDLType((src.eContainer as Contained).identifier + HYPHEN)
					}
					SequenceDef: {
						ct.transformTyped(it)
					}
					default:
						addIssue(FEATURE_NOT_HANDLED_YET,
							ct, IdlmmPackage::IDL_TYPE,
							"OMG IDL Typed '" + ct.class.name + "' used as field not handled yet (object '" + src.toString + "')")
				}
			}
			target.elements.add(it)
		]
	}
	
	def private dispatch void transformTyped(UnionField src, FUnionType target) {
		val result = factory.createFField => [
			name = src.identifier
			if (src.sharedType === null) {
				type = src.containedType.transformIDLType
			} else {
				type = src.sharedType.transformIDLType
			}
			target.elements.add(it)
		]
		if (src.isIsDefault) {
			result.addSourceAnno("default")
		} else {
			if (src.label!==null && !src.label.empty) {
				val first = src.label.get(0)
				if (first instanceof ConstantDefRef) {
					result.addSourceAnno("case '" + first.constant.identifier + "'")
				}
			}
		}
	}
	
	def private dispatch void transformTyped(ParameterDef src, FMethod target) {
		switch src.direction {
			case PARAM_IN: {
				target.inArgs.add(src.transformParameter)
			}
			case PARAM_OUT: {
				target.outArgs.add(src.transformParameter)
			}
			case PARAM_INOUT: {
				target.inArgs.add(src.transformParameter)
				target.outArgs.add(src.transformParameter)
			}
		}
	}
	
	def private transformParameter(ParameterDef src) {
		factory.createFArgument => [
			name = src.identifier
			if (src.sharedType === null) {
				type = src.containedType.transformIDLType
			} else {
				type = src.sharedType.transformIDLType
			}
		]
	}
	
	/* -------------------- transform IDLType ---------------------- */
	/**
	 * Generate the reference to other user-defined type
	 */
	def private dispatch FTypeRef transformIDLType(EObject src) {
		factory.createFTypeRef => [
			switch src {
				// src, i.e. the referenced type, can be an interface but not a proxy interface
				case src instanceof InterfaceDef && !src.eIsProxy : {
					if (!map_IDL_Franca.containsKey(src)) {
						map_IDL_Franca.put(src, (src as InterfaceDef).transformDefinition(map_IDL_Franca.get(src.translationUnit)))						
					}
					val interfacedef = map_IDL_Franca.get(src)
					if (map_IDL_Franca.containsKey(interfacedef)) {
						derived = map_IDL_Franca.get(interfacedef) as FType
					} else {
						derived = factory.createFTypeDef => [ ifDef |
							map_IDL_Franca.put(interfacedef, ifDef)
							ifDef.name = (src as InterfaceDef).identifier + 'Reference'
							ifDef.actualType = factory.createFTypeRef => [ stringRef |
								stringRef.predefined = FBasicTypeId.STRING
							]
							src.translationUnit.mappedTypeCollection.addInTypeCollection(ifDef)
						]
					}
				}

				case map_IDL_Franca.containsKey(src) : {
					derived = map_IDL_Franca.get(src) as FType
				}
				// This case identifies that the type is not yet transformed
				default: {
					val container = src.container
					if (src instanceof Contained && map_IDL_Franca.get(container) !== null) {
						derived = (src as Contained).transformDefinition(map_IDL_Franca.get(container)) as FType
						map_IDL_Franca.put(src, derived)
					} else {
						addIssue(FEATURE_NOT_HANDLED_YET,
							src.translationUnit, IdlmmPackage::TRANSLATION_UNIT__IDENTIFIER,
							"OMG IDL Container '" + container.class.name + "' not handled yet (object '" + container + "')")
					}
				}
			} 
		]
	}
	
	def private dispatch FTypeRef transformIDLType(PrimitiveDef src) {
		switch src.kind {
			case PK_OCTET: getBaseTypeOrSubstitute("octet", FBasicTypeId.UINT8)
			case PK_CHAR: getBaseTypeOrSubstitute("char", FBasicTypeId.UINT8)
			case PK_WCHAR: getBaseTypeOrSubstitute("wchar", FBasicTypeId.UINT32)
			case PK_SHORT: FBasicTypeId.INT16.asTypeRef
			case PK_LONG: FBasicTypeId.INT32.asTypeRef
			case PK_LONGLONG: FBasicTypeId.INT64.asTypeRef
			case PK_USHORT: FBasicTypeId.UINT16.asTypeRef
			case PK_ULONG: FBasicTypeId.UINT32.asTypeRef
			case PK_ULONGLONG: FBasicTypeId.UINT64.asTypeRef
			case PK_FLOAT: FBasicTypeId.FLOAT.asTypeRef
			case PK_DOUBLE: FBasicTypeId.DOUBLE.asTypeRef
			case PK_LONGDOUBLE: getBaseTypeOrSubstitute("long_double", FBasicTypeId.DOUBLE)
			case PK_STRING: FBasicTypeId.STRING.asTypeRef
			case PK_WSTRING: getBaseTypeOrSubstitute("wstring", FBasicTypeId.STRING)
			case PK_BOOLEAN: FBasicTypeId.BOOLEAN.asTypeRef
			case PK_ANY: getBaseTypeOrSubstitute("any", FBasicTypeId.UNDEFINED)
			case PK_OBJREF: getBaseTypeOrSubstitute("Object", FBasicTypeId.UNDEFINED)
			default: FBasicTypeId.UNDEFINED.asTypeRef
		}
	}
	
	def private FTypeRef getBaseTypeOrSubstitute(String typename, FBasicTypeId subst) {
		if (baseTypedefs!==null && baseTypedefs.containsKey(typename)) {
			usingBaseTypedefs = true
			factory.createFTypeRef => [
				derived = baseTypedefs.get(typename)
			]
		} else {
			subst.asTypeRef
		}
	}
	
	def private asTypeRef(FBasicTypeId id) {
		factory.createFTypeRef => [ predefined = id ]
	}
	
	def private dispatch FTypeRef transformIDLType(FixedDef src) {
		factory.createFTypeRef => [
			derived = src.transformDefinition as FType
			src.mappedTypeCollection.addInTypeCollection(derived)
		]
	}
	
	def private dispatch FTypeRef transformIDLType(SequenceDef src) {
		factory.createFTypeRef => [
			derived = factory.createFArrayType => [
				name = 'Sequence' + HYPHEN + countOfSequence
				countOfSequence++
				if (src.sharedType === null) {
					elementType = src.containedType.transformIDLType
				} else {
					elementType = src.sharedType.transformIDLType
				}
				if (!map_IDL_Franca.containsKey(src.container)) {
					println(src.container)
				}
				src.mappedTypeCollection.addInTypeCollection(it)
			]
		]
	}
	
	def private dispatch FTypeRef transformIDLType(ArrayDef src) {
		return src.transformIDLType(src.container.mappedTypeCollection, '', src.bounds.size)
	}
	
	def private FTypeRef transformIDLType(ArrayDef src, String prefix) {
		return src.transformIDLType(src.container.mappedTypeCollection, prefix, src.bounds.size)
	}
	
	def private FTypeRef transformIDLType(ArrayDef src, FTypeCollection target, String prefix, int dimensionSize) {
		factory.createFTypeRef => [
			derived = factory.createFArrayType => [
						name = prefix + src.name + HYPHEN + dimensionSize
						if (dimensionSize <= 1) {
							if (src.sharedType === null) {
								elementType = src.containedType.transformIDLType
							} else {
								elementType = src.sharedType.transformIDLType
							}
						} else {
							elementType = src.transformIDLType(target, prefix, dimensionSize - 1)
						}
						target.addInTypeCollection(it)
					]
		]
	}
	
	/* ------------------ dispatch transform Expression ------------------------- */
	def private dispatch transformExpression(Expression src, FTypeRef type) {
		addIssue(FEATURE_NOT_HANDLED_YET,
			src, IdlmmPackage::EXPRESSION,
			"OMG IDL Expression '" + src.class.name + "' not handled yet (object '" + src + "')")
	}
	
	def private dispatch FExpression transformExpression(BinaryExpression src, FTypeRef type) {
		factory.createFBinaryOperation => [
			left = src.left.transformExpression(type)
			op = src.operator.transformOperator
			right = src.right.transformExpression(type)
		]
	}
	
	def private dispatch FExpression transformExpression(UnaryExpression src, FTypeRef type) {
		factory.createFUnaryOperation => [
			operand = src.expression.transformExpression(type)
			op = src.operator.transformOperator
		]
	}
	
	def private dispatch FExpression transformExpression (ValueExpression src, FTypeRef type) {
		val regex_INT = '[0-9]+'
		val regex_HEX_LITERAL = '0x[0-9a-fA-F]+' //('0'..'9'|'a'..'f'|'A'..'F')+
		val regex_WIDE_STRING_LITERAL = "L\"(.*)\""
		val regex_INTEGER_LITERAL = '[0-9]+\\.[0]+'
		val regex_FLOATING_PT_LITERAL = '(([0-9]*\\.[0-9]+)|([0-9]+))[dD]'
		val regex_BOOLEAN_LITERAL = '(TRUE)|(FALSE)'
		val expression = switch src.value {
			case src.value.matches(regex_INT): {
				 switch (type.derived) {
				 	case (type.derived instanceof FEnumerationType): 
				 		factory.createFQualifiedElementRef => [
				 			element = 
				 			 ((type.derived as FEnumerationType).enumerators.get(Integer.valueOf(src.value)) as FEvaluableElement)
				 			]
				 	default: factory.createFIntegerConstant => [^val = new BigInteger(src.value)]
				 }
			}
			case src.value.matches(regex_INTEGER_LITERAL): factory.createFIntegerConstant => [^val = new BigInteger(src.value.substring(0, src.value.indexOf('.')))]
			case src.value.matches(regex_HEX_LITERAL): factory.createFIntegerConstant => [^val = new BigInteger(src.value.substring(2), 16)]
			case src.value.matches(regex_WIDE_STRING_LITERAL): factory.createFStringConstant => [^val = src.value.substring(2, src.value.length-1)]
			case src.value.matches(regex_FLOATING_PT_LITERAL): {
				if (type.isDouble) {
					factory.createFDoubleConstant => [^val = Double.valueOf(src.value)]
				} else {
					factory.createFFloatConstant => [^val = new Float(src.value)]
				}
			} 
			case src.value.matches(regex_BOOLEAN_LITERAL): factory.createFBooleanConstant => [^val = new Boolean(src.value)]
			default: factory.createFStringConstant => [^val = src.value.substring(1, src.value.length-1)]
		}
		return expression
	}
	
	def private dispatch FExpression transformExpression (ConstantDefRef src, FTypeRef type) {
		
	}
	
	/*-------------------------------------------------------------------------------------------*/
	
	def private transformOperator (String operator) {
		val op = switch operator {
			case '|' : FOperator.OR
			case '^' : null
			case '&' : FOperator.AND
			case '>>' : null
			case '<<' : null
			case '+' : FOperator.ADDITION
			case '-' : FOperator.SUBTRACTION
			case '*' : FOperator.MULTIPLICATION
			case '/' : FOperator.DIVISION
			case '%' : null
			case '~' : null
			default : null
		}
		if (op === null) {
			addIssue(FEATURE_NOT_HANDLED_YET,
			null, IdlmmPackage::EXPRESSION,
			"OMG IDL Operatior '" + operator + "' in Expression not handled yet")
		}
		return op
	}
	
	def private transformIncludeDeclaration (Include src, FModel target) {
		factory.createImport => [
			importURI = src.transformIncludeFileName
			target.imports.add(it)
		]
	}
	
	def private transformIncludeFileName (Include src) {
		var uri = URI.createFileURI(src.importURI)
		if (uri.isEmpty) {
			addIssue(FEATURE_UNSUPPORTED_VALUE,
				src, IdlmmPackage::INCLUDE__IMPORT_URI,
				"The URI of imported IDL file '" + src + "' is null or empty"
			)
			return ''
		}
		
		val orig = uri.lastSegment
		val n = orig.lastIndexOf(uri.fileExtension)
		if (n==-1) {
			// something is wrong, uri has wrong file extension
			addIssue(IMPORT_ERROR,
				src, IdlmmPackage::INCLUDE__IMPORT_URI,
				"The URI of imported IDL file '" + src + "' should have extension 'idl'"
			)
			return ''
		} else {
			orig.substring(0, n) + FRANCA_IDL_EXT
		}
	}
	
	def private dispatch addInTypeCollection (FTypeCollection target, FType type) {
		target.types.add(type)
	}
	
	def private dispatch addInTypeCollection (FTypeCollection target, FConstantDef consttantDef) {
		target.constants.add(consttantDef)
	}
	
	def private dispatch addInTypeCollection (EObject target, FType type) {
		target.mappedTypeCollection.types.add(type)
	}
	
	def private dispatch addInTypeCollection (EObject target, FConstantDef consttantDef) {
		target.mappedTypeCollection.constants.add(consttantDef)
	}
	
	// obj can be any IDL object
	def private getMappedTypeCollection (EObject obj) {
		map_IDL_Franca.get(obj.container).getTypeCollection()
	}
	
	def private dispatch getTypeCollection (FModel target) {
		if (target.typeCollections.isNullOrEmpty) {
			target.typeCollections.add(createTypeCollection(null, 1, 0))
		}
		target.typeCollections.get(0)
	}

	def private dispatch getTypeCollection (FInterface target) {
		target
	}
	
	/**
	 * Return the list of interfaces that are directly or indirectly extended by {@code iface}, including {@code iface} itself
	 */
	def private List<InterfaceDef> getBaseInterfaces (InterfaceDef iface) {
		val bases = newArrayList(iface)
		if (!iface.derivesFrom.isNullOrEmpty) {
			bases.addAll(iface.derivesFrom.get(0).baseInterfaces)
		}
		return bases
	}
	
	/**
	 * Return the closest container, maybe {@code object} itself
	 */
	def private getContainer (EObject object) {
		object.interfaceContainer ?: (object.moduleContainer ?:  object.translationUnit)
	}
	
	def private getTranslationUnit (EObject object) {
		if (object instanceof TranslationUnit) {
			return object
		}
		var obj = object.eContainer
		while (obj !== null) {
			if (obj instanceof TranslationUnit){
				return obj
			}
			obj = obj.eContainer
		}
		return obj
	}
	
	def private getModuleContainer (EObject object) {
		if (object instanceof ModuleDef) {
			return object
		}
		var obj = object.eContainer
		while (obj !== null) {
			if (obj instanceof ModuleDef){
				return obj
			}
			obj = obj.eContainer
		}
		return obj
	}
	
	/**
	 * Return the {@code object}'s closest ancestor of type InterfaceDef or null 
	 */
	def private getInterfaceContainer (EObject object) {
		if (object instanceof InterfaceDef) {
			return object
		}
		var  obj = object.eContainer
		while (obj !== null) {
			if (obj instanceof InterfaceDef){
				return obj
			}
			obj = obj.eContainer
		}
		return obj
	}
	
	def private createTypeCollection (String name, int major, int minor) {
		factory.createFTypeCollection => [
			it.name = name
			it.version = factory.createFVersion => [
				it.major = major
				it.minor = minor
			]
		]
	}
	
	def private getAnnotationBlock(FModelElement elem) {
		if(elem.comment===null) {
			elem.comment = FrancaFactory::eINSTANCE.createFAnnotationBlock
		}
		elem.comment
	}

	def private addSourceAnno(FModelElement elem, String source) {
		elem.annotationBlock.createSourceAlias("OMG IDL " + source)
	}

	def private createSourceAlias(FAnnotationBlock annos, String sourceAlias) {
		annos.elements.add(
			FrancaFactory::eINSTANCE.createFAnnotation => [
				type = FAnnotationType::SOURCE_ALIAS
				comment = sourceAlias
			]	
		)
	}


	def private factory() {
		FrancaFactory::eINSTANCE
	}
	
}
