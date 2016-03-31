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
import org.csu.idl.idlmm.AliasDef
import org.csu.idl.idlmm.ArrayDef
import org.csu.idl.idlmm.AttributeDef
import org.csu.idl.idlmm.BinaryExpression
import org.csu.idl.idlmm.ConstantDef
import org.csu.idl.idlmm.ConstantDefRef
import org.csu.idl.idlmm.Contained
import org.csu.idl.idlmm.EnumDef
import org.csu.idl.idlmm.EnumMember
import org.csu.idl.idlmm.Expression
import org.csu.idl.idlmm.Field
import org.csu.idl.idlmm.ForwardDef
import org.csu.idl.idlmm.IDLType
import org.csu.idl.idlmm.IdlmmPackage
import org.csu.idl.idlmm.Include
import org.csu.idl.idlmm.InterfaceDef
import org.csu.idl.idlmm.ModuleDef
import org.csu.idl.idlmm.OperationDef
import org.csu.idl.idlmm.ParameterDef
import org.csu.idl.idlmm.PrimitiveDef
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
import org.franca.core.framework.TransformationLogger
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
import org.franca.core.franca.FTypeRef
import org.franca.core.franca.FTypedElement
import org.franca.core.franca.FUnionType
import org.franca.core.franca.FrancaFactory

import static org.franca.core.framework.TransformationIssue.*
import org.csu.idl.idlmm.ExceptionDef

/**
 * Model-to-model transformation from OMG IDL (aka CORBA) to Franca IDL.  
 */
class OMGIDL2FrancaTransformation {
	val static FRANCA_IDL_EXT = 'fidl'
	val static HYPHEN = '_'
//	val static DEFAULT_NODE_NAME = "default"
	
	Map<EObject, EObject> map_IDL_Franca
	Map<String, ModuleDef> map_Name_Module
	List<InterfaceDef> baseInterfaces
	List<FModel> models
	int countOfSequence
	@Inject extension TransformationLogger

//	List<FType> newTypes
	
	def getTransformationIssues() {
		return getIssues
	}
	
	def getTransformationMap() {
		map_IDL_Franca ?: newLinkedHashMap()
	}
	
	/**
	 * Transform to single Franca model
	 */
	def FModel transform(TranslationUnit src, Map<EObject, EObject> map) {
		clearIssues
		// register global map IDL2Franca to local one 
		map_IDL_Franca = map
		val it = factory.createFModel
		map_IDL_Franca.put(src, it)
		// handle src.includes
		src.includes.forEach[include | include.transformIncludeDeclaration(it)]
		if (src.contains.empty) {
			addIssue(IMPORT_WARNING,
				src, IdlmmPackage::TRANSLATION_UNIT__IDENTIFIER,
				"Empty OMG IDL translation unit, created empty Franca model")
			
		} else {
			if (src.contains.size > 1) {
				addIssue(FEATURE_IS_IGNORED,
					src, IdlmmPackage::TRANSLATION_UNIT__IDENTIFIER,
					"OMG IDL translation unit with more than one definition, ignoring all but the first one")
			}
			// TODO: what should we do with TUs that have more than one definition?
			val first = src.contains.get(0)
			if (first instanceof ModuleDef) {
				map_IDL_Franca.put(first, it)
				// we expect that first definition is a ModuleDef, ignore all other ones
				// TODO: correct? or should we create several Franca files per OMG IDL TU?
				
				// OMG IDL's module name will be the package identifier in Franca  
				it.name = first.identifier

				// map all definitions of this module to the Franca model
				for(d : first.contains) {
					if(!map_IDL_Franca.containsKey(d)) {
						map_IDL_Franca.put(d, d.transformDefinition(it))					
					}
				}
			} else {
				// TODO: check if this restriction is what we want
				addIssue(IMPORT_ERROR,
					first, IdlmmPackage::CONTAINED__IDENTIFIER,
					"First and only member of OMG IDL translation unit should be a 'module' definition")
			}
		}
		it
	}
	
	/**
	 * Transform to a single Franca model
	 */
	def FModel transformToSingleFModel(TranslationUnit src, Map<EObject, EObject> map) {
		clearIssues
		countOfSequence = 0
		baseInterfaces = newArrayList()
		// register global map IDL2Franca to local one 
		map_IDL_Franca = map
		val model = factory.createFModel
		map_IDL_Franca.put(src, model)
		for (module: src.contains.filter(ModuleDef)){
				map_IDL_Franca.put(module, model)
		}
		if (src.contains.filter(ModuleDef).size == 1) {
			model.name = src.contains.filter(ModuleDef).last.identifier
		} else {
			model.name = URI.createFileURI(src.eResource.URI.trimFileExtension.lastSegment).lastSegment
		}
		src.includes.forEach[include | include.transformIncludeDeclaration(model)]
		// handle src.includes
		if (src.contains.empty) {
			addIssue(IMPORT_WARNING,
				src, IdlmmPackage::TRANSLATION_UNIT__IDENTIFIER,
				"Empty OMG IDL translation unit, created empty Franca model")
		} else {
			// case: interfaces on top level of TranslationUnit
			for(^interface: src.contains.filter(InterfaceDef)) {
				if(!map_IDL_Franca.containsKey(^interface)) {
					map_IDL_Franca.put(^interface, ^interface.transformDefinition(model))					
				}
			}
			// case: modules on top level of TranslationUnit
			for (module: src.contains.filter(ModuleDef)){
				for(d : module.contains) {
					if(!map_IDL_Franca.containsKey(d)) {
						map_IDL_Franca.put(d, d.transformDefinition(model))					
					}
				}
			}
			// case: other contained (except interface and module) on top level of TranslationUnit
			val others = src.contains.filter[
				var isOther = true
				if (it instanceof ModuleDef) {
					isOther = false
				} else if (it instanceof InterfaceDef) {
					isOther = false 
				} else if (it instanceof ForwardDef) {
					isOther = false
				}
				isOther
			]
			if (!others.isNullOrEmpty) {
				addIssue(IMPORT_ERROR,
					src, IdlmmPackage::TRANSLATION_UNIT__CONTAINS,
					"Members of OMG IDL translation unit should be of type either 'interface' or 'module'")
			}
		}
		model
	}
	
	/**
	 * Transform to a list of Franca models
	 */
	def List<FModel> transformToMultiFModel(TranslationUnit src, Map<EObject, EObject> map) {
		clearIssues
		// register global map IDL2Franca to local one 
		map_IDL_Franca = map
		map_Name_Module = newHashMap()
		baseInterfaces = newLinkedList()
		models = newLinkedList()
		if (src.contains.empty) {
			addIssue(IMPORT_WARNING,
				src, IdlmmPackage::TRANSLATION_UNIT__IDENTIFIER,
				"Empty OMG IDL translation unit, created empty Franca model")
			val model = factory.createFModel
			model.name = URI.createFileURI(src.eResource.URI.trimFileExtension.lastSegment).lastSegment
			map_IDL_Franca.put(src, model)
			src.includes.forEach[include | include.transformIncludeDeclaration(model)]
			models.add(model)
		} else {
			// case: interfaces on top level of TranslationUnit
			val interfaces = src.contains.filter(InterfaceDef)
			if (interfaces.size > 0) {
				val model = factory.createFModel
				model.name = URI.createFileURI(src.eResource.URI.trimFileExtension.lastSegment).lastSegment
				map_IDL_Franca.put(src, model)
				src.includes.forEach[include | include.transformIncludeDeclaration(model)]
				for(^interface: interfaces) {
					if(!map_IDL_Franca.containsKey(^interface)) {
						map_IDL_Franca.put(^interface, ^interface.transformDefinition(model))					
					}
				}
				models.add(model)
			}
			// case: modules on top level of TranslationUnit
			for (module: src.contains.filter(ModuleDef)){
				val model = module.transformModule(src)
				for(d : module.contains) {
					if(!map_IDL_Franca.containsKey(d)) {
						map_IDL_Franca.put(d, d.transformDefinition(model))					
					}
				}
			}
			// case: other contained (except interface and module) on top level of TranslationUnit
			val others = src.contains.filter[
				var isOther = true
				if (it instanceof ModuleDef) {
					isOther = false
				} else if (it instanceof InterfaceDef) {
					isOther = false 
				} else if (it instanceof ForwardDef) {
					isOther = false
				}
				isOther
			]
			if (!others.isNullOrEmpty) {
				addIssue(IMPORT_ERROR,
					src, IdlmmPackage::TRANSLATION_UNIT__CONTAINS,
					"Members of OMG IDL translation unit should be of type either 'interface' or 'module'")
			}
		}
		models
	}

	def private FModel transformModule(ModuleDef module, TranslationUnit src) {
		var FModel model
		// a module with the same name has already been processed
		if (map_Name_Module.containsKey(module.identifier)) {
			// get the already created FModel
			model = map_IDL_Franca.get(map_Name_Module.get(module.identifier)) as FModel
		} else {
			model = factory.createFModel
			model.name = module.identifier
			val _model = model
			src.includes.forEach[include | include.transformIncludeDeclaration(_model)]
			map_Name_Module.put(module.identifier, module)
			models.add(model)
		}
		if (!map_IDL_Franca.containsKey(module)){
			map_IDL_Franca.put(module, model)
		}
		model
	}
	/* ---------------------- dispatch transform Contained ------------------------- */
	def private dispatch FModelElement transformDefinition(InterfaceDef src, FModel target) {
		factory.createFInterface => [
			map_IDL_Franca.put(src, it)
			// transform all properties of this InterfaceDef
			name = src.identifier
			// interface inheritance
			if (!src.derivesFrom.isNullOrEmpty) {
				// only the first interface is transformed, all others are ignored
				base = (map_IDL_Franca.get(src.derivesFrom.get(0)) ?: {
// src.derivesFrom.get(0) is defined in the current Translation Unit, but maybe under another module
					val baseIDLInterface = src.derivesFrom.get(0)
//					val baseIDLModuleContainer = baseIDLInterface.moduleContainer
					val baseIDLTranslationUnitContainer = baseIDLInterface.moduleContainer
					var FModel model
//					if (baseIDLModuleContainer instanceof ModuleDef) {
//						model = baseIDLModuleContainer.transformModule(baseIDLTranslationUnitContainer as TranslationUnit)
//					} else {
					model = map_IDL_Franca.get(baseIDLTranslationUnitContainer) as FModel
//					}
					val baseInterface = baseIDLInterface.transformDefinition(model)
					map_IDL_Franca.put(src.derivesFrom.get(0), baseInterface)
					baseInterface
				}) as FInterface
				// a warning is issued
				val bases = newArrayList()
				src.derivesFrom.forEach[bases.add(it.identifier)]
				addIssue(FEATURE_NOT_FULLY_SUPPORTED,
					src, IdlmmPackage::INTERFACE_DEF__DERIVES_FROM,
					"OMG IDL multiple interface inheritance from " + bases.join(', ') + " to " + src.identifier + " can not be completely mapped to Franca"
				)
			}
			// cache all the interfaces directly or indirectly extended by src
			baseInterfaces = src.baseInterfaces
			for (contained: src.contains) {
				val definition = contained.transformDefinition()
				switch contained {
					case contained instanceof TypedefDef: types.add(definition as FType)
					case contained instanceof ConstantDef: constants.add(definition as FConstantDef)
					case contained instanceof AttributeDef: attributes.add(definition as FAttribute)
					case contained instanceof OperationDef: methods.add(definition as FMethod)
				}
			}
			// reset the list
			baseInterfaces = newArrayList()
			// add resulting object to target model
			target.interfaces.add(it)
		]
	}

	// TODO: handle all kinds of OMG IDL definitions here
	def private dispatch FModelElement transformDefinition(TypedefDef src, FModel target) {
		val definition = src.transformDefinition as FType
		OMGIDL2FrancaTransformationUtil.getTypeCollection(target).addInTypeCollection(definition)
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
		OMGIDL2FrancaTransformationUtil.getTypeCollection(target).addInTypeCollection(definition)
//		addInAnonymousTypeCollection(definition)
		return definition
	}
	
	// catch-all for this dispatch method
	def private dispatch FModelElement transformDefinition(Contained src, FModel target) {
		val definition = src.transformDefinition
		if (definition != null) {
			OMGIDL2FrancaTransformationUtil.getTypeCollection(target).addInTypeCollection(definition)
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
			if (src.sharedType == null) {
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
			src.parameters.forEach[member | member.transformTyped(it)]
			if (!src.canRaise.isNullOrEmpty) {
				errors = factory.createFEnumerationType => [errorContainer|
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
	
	def private dispatch FModelElement transformDefinition(AliasDef src) {
		factory.createFTypeDef => [
			map_IDL_Franca.put(src, it)
			name = src.identifier
			if (src.sharedType == null) {
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
		factory.createFUnionType => [
			map_IDL_Franca.put(src, it)
			name = src.identifier
			src.unionMembers.forEach[member | member.transformTyped(it)]
		]
	}
	
	def private dispatch FModelElement transformDefinition(ConstantDef src) {
		factory.createFConstantDef => [
			map_IDL_Franca.put(src, it)
			name = src.identifier
			if (src.sharedType == null) {
				type = src.containedType.transformIDLType
			} else {
				type = src.sharedType.transformIDLType
			}
			rhs = src.constValue.transformExpression(type)
		]
	}
	
	def private dispatch FModelElement transformDefinition(ExceptionDef src) {
		var FStructType element
		if (src.members.isNullOrEmpty) {
			element = null
		} else {
			element = factory.createFStructType => [
				map_IDL_Franca.put(src, it)
				name = src.identifier
				src.members.forEach[member | member.transformTyped(it)]
			]
		}
		element
	}
	
	/*------------------ transform Typed --------------------------------- */
	
	def private dispatch transformTyped(Typed src, FStructType target) {
		addIssue(FEATURE_NOT_HANDLED_YET,
			src, IdlmmPackage::TYPED,
			"OMG IDL Typed '" + src.class.name + "' not handled yet (object '" + src.toString + "')")
	}
	
	def private dispatch transformTyped (Typed src, FTypedElement target) {
		if (src.sharedType == null) {
			target.type = src.containedType.transformIDLType
		} else {
			target.type = src.sharedType.transformIDLType
		}
		if (src instanceof SequenceDef) {
			target.array = true
		}
	}
	
	def private dispatch transformTyped(Field src, FStructType target) {
		factory.createFField => [
			name = src.identifier
			if (src.sharedType != null) {
				type = src.sharedType.transformIDLType
			} else if (src.containedType instanceof PrimitiveDef) {
				type = (src.containedType as PrimitiveDef).transformIDLType
			} else if (src.containedType instanceof StructDef) {
				map_IDL_Franca.put(src.containedType, (src.containedType as StructDef).transformDefinition(map_IDL_Franca.get(src.container)))
				type = src.containedType.transformIDLType
			} else if (src.containedType instanceof ArrayDef) {
				type = (src.containedType as ArrayDef).transformIDLType((src.eContainer as Contained).identifier + HYPHEN)
			}
			target.elements.add(it)
		]
	}
	
	def private dispatch transformTyped(UnionField src, FUnionType target) {
		factory.createFField => [
			name = src.identifier
			if (src.containedType instanceof PrimitiveDef) {
				type = (src.containedType as PrimitiveDef).transformIDLType()
			}
			target.elements.add(it)
		]
	}
	
	def private dispatch transformTyped(ParameterDef src, FMethod target) {
		switch src.direction {
			case PARAM_IN: {
				target.inArgs.add(src.transformTyped)
			}
			case PARAM_OUT: {
				target.outArgs.add(src.transformTyped)
			}
			case PARAM_INOUT: {
				target.inArgs.add(src.transformTyped)
				target.outArgs.add(src.transformTyped)
			}
		}
	}
	
	def private transformTyped(ParameterDef src) {
		factory.createFArgument => [
			name = src.identifier
			if (src.sharedType == null) {
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
			// src can be interface
			switch src {
				// This case identifies that the type is invisible in the given interface A, since its container interface B is neither A nor a base interface of A
				case (src.interfaceContainer != null) && (!baseInterfaces.contains(src.interfaceContainer)): {
					predefined = FBasicTypeId.UNDEFINED
				}
				case map_IDL_Franca.containsKey(src) : {
					derived = map_IDL_Franca.get(src) as FType
				}
				// This case identifies that the type is not yet transformed
				default: {
					val container = src.container
					if (src instanceof Contained && map_IDL_Franca.get(container) != null) {
						derived = (src as Contained).transformDefinition(map_IDL_Franca.get(container)) as FType
						map_IDL_Franca.put(src, derived)
					} else {
						println('yes!')
						addIssue(FEATURE_NOT_HANDLED_YET,
							translationUnit, IdlmmPackage::TRANSLATION_UNIT,
							"OMG IDL Container '" + container.class.name + "' not handled yet (object '" + container + "')")
					}
				}
			} 
		]
	}
	
	def private dispatch FTypeRef transformIDLType(PrimitiveDef src) {
		factory.createFTypeRef => [
			predefined = switch src.kind {
				case PK_SHORT: FBasicTypeId.INT16
				case PK_LONG: FBasicTypeId.INT32
				case PK_LONGLONG: FBasicTypeId.INT64
				case PK_USHORT: FBasicTypeId.UINT16
				case PK_ULONG: FBasicTypeId.UINT32
				case PK_ULONGLONG: FBasicTypeId.UINT64
				case PK_FLOAT: FBasicTypeId.FLOAT
				case PK_DOUBLE: FBasicTypeId.DOUBLE
				case PK_LONGDOUBLE: FBasicTypeId.DOUBLE
				case PK_STRING: FBasicTypeId.STRING
				case PK_WSTRING: FBasicTypeId.STRING
				case PK_BOOLEAN: FBasicTypeId.BOOLEAN
				default: FBasicTypeId.UNDEFINED
			}
		]
	}
	
	def private dispatch FTypeRef transformIDLType(SequenceDef src) {
		factory.createFTypeRef => [
			derived = factory.createFArrayType => [
				name = 'Sequence' + HYPHEN + countOfSequence
				countOfSequence++
				if (src.sharedType == null) {
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
							if (src.sharedType == null) {
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
				switch (type.predefined) {
					case FBasicTypeId.DOUBLE: factory.createFDoubleConstant => [^val = Double.valueOf(src.value)]
					default: factory.createFFloatConstant => [^val = new Float(src.value)]
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
		if (op == null) {
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
		return uri.lastSegment.replace(uri.fileExtension, FRANCA_IDL_EXT)
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
		OMGIDL2FrancaTransformationUtil.getTypeCollection(map_IDL_Franca.get(obj.container))
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
		while (obj != null) {
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
		while (obj != null) {
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
		while (obj != null) {
			if (obj instanceof InterfaceDef){
				return obj
			}
			obj = obj.eContainer
		}
		return obj
	}
	
	def private factory() {
		FrancaFactory::eINSTANCE
	}
}
