/*******************************************************************************
 * Copyright (c) 2016 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.connectors.omgidl

import com.google.inject.Inject
import org.csu.idl.idlmm.Contained
import org.csu.idl.idlmm.IdlmmPackage
import org.csu.idl.idlmm.InterfaceDef
import org.csu.idl.idlmm.ModuleDef
import org.csu.idl.idlmm.TranslationUnit
import org.franca.core.framework.TransformationLogger
import org.franca.core.franca.FModel
import org.franca.core.franca.FrancaFactory

import static org.franca.core.framework.TransformationIssue.*
import org.csu.idl.idlmm.Include
import org.csu.idl.idlmm.StructDef
import org.csu.idl.idlmm.Field
import org.csu.idl.idlmm.PrimitiveDef
import org.franca.core.franca.FBasicTypeId
import org.franca.core.franca.FStructType
import org.csu.idl.idlmm.IDLType
import org.csu.idl.idlmm.Typed
import org.csu.idl.idlmm.EnumDef
import org.csu.idl.idlmm.EnumMember
import org.franca.core.franca.FEnumerationType
import org.franca.core.franca.FEnumerator
import org.csu.idl.idlmm.UnionDef
import org.csu.idl.idlmm.UnionField
import org.franca.core.franca.FUnionType
import org.franca.core.franca.FType
import org.csu.idl.idlmm.AliasDef
import org.csu.idl.idlmm.ConstantDef
import org.franca.core.franca.FConstantDef
import org.csu.idl.idlmm.Expression
import org.csu.idl.idlmm.BinaryExpression
import org.franca.core.franca.FExpression
import org.franca.core.franca.FOperator
import org.csu.idl.idlmm.UnaryExpression
import org.csu.idl.idlmm.ConstantDefRef
import org.csu.idl.idlmm.ValueExpression
import java.math.BigInteger
import org.franca.core.franca.FTypeRef
import org.csu.idl.idlmm.TypedefDef
import java.util.Map
import org.eclipse.emf.ecore.EObject
import java.lang.reflect.Type
import org.franca.core.franca.FEvaluableElement
import org.csu.idl.idlmm.ArrayDef
import org.franca.core.franca.FModelElement
import org.franca.core.franca.FInterface
import org.franca.core.franca.FTypeDef
import java.util.List

/**
 * Model-to-model transformation from OMG IDL (aka CORBA) to Franca IDL.  
 */
class OMGIDL2FrancaTransformation {
	val static OMG_IDL_EXT = '.idl'
	val static FRANCA_IDL_EXT = '.fidl'
	val static HYPHEN = '_'
//	val static DEFAULT_NODE_NAME = "default"
	
	Map<EObject, EObject> map_IDL_Franca
	List<InterfaceDef> baseInterfaces = newArrayList()
	
	@Inject extension TransformationLogger

//	List<FType> newTypes
	
	def getTransformationIssues() {
		return getIssues
	}
	
	def getTransformationMap() {
		map_IDL_Franca ?: newLinkedHashMap()
	}

	def FModel transform(TranslationUnit src, Map<EObject, EObject> map) {
		clearIssues
		
		map_IDL_Franca = map
		
		val it = factory.createFModel
		map_IDL_Franca.put(src, it)
		// TODO: handle src.includes
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
	
	/* ---------------------- dispatch transform Contained ------------------------- */
	
	def private dispatch FModelElement transformDefinition(InterfaceDef src, FModel target) {
		factory.createFInterface => [
			// transform all properties of this InterfaceDef
			name = src.identifier
			// interface inheritance
			if (!src.derivesFrom.isNullOrEmpty) {
				// only the first interface is transformed, all others are ignored
				base = (map_IDL_Franca.get(src.derivesFrom.get(0)) ?: {
					val baseInterface = src.derivesFrom.get(0).transformDefinition(target)
					map_IDL_Franca.put(src.derivesFrom.get(0), baseInterface)
					baseInterface
				}) as FInterface
				// a warning is issued
				val bases = newArrayList()
				src.derivesFrom.forEach[bases.add(it.identifier)]
				addIssue(FEATURE_NOT_FULLY_SUPPORTED,
					src, IdlmmPackage::INTERFACE_DEF__DERIVES_FROM,
					"OMG IDL multiple interface inheritance from " + bases.join(', ') + " to " + src.identifier + " can not be mapped to Franca"
				)
			}
			// cache all the interfaces directly or indirectly extended
			baseInterfaces = src.baseInterfaces
			for (contained: src.contains) {
				val definition = contained.transformDefinition()
				map_IDL_Franca.put(contained, definition)
				switch contained {
					case contained instanceof TypedefDef: types.add(definition as FType)
					case contained instanceof ConstantDef: constants.add(definition as FConstantDef)
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
		target.addInAnonymousTypeCollection(definition)
		return definition
	}
	
	def private dispatch FModelElement transformDefinition(AliasDef src) {
		factory.createFTypeDef => [
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
			name = src.identifier
			src.members.forEach[member | member.transformTyped(it)]
		]
	}
	
	def private dispatch FModelElement transformDefinition(EnumDef src) {
		factory.createFEnumerationType => [
			name = src.identifier
			src.members.forEach[member | member.transformDefinition(it)]
		]
	}
	
	def private dispatch FModelElement transformDefinition(UnionDef src) {
		factory.createFUnionType => [
			name = src.identifier
			src.unionMembers.forEach[member | member.transformTyped(it)]
		]
	}
	
	def private dispatch FModelElement transformDefinition(EnumMember src, FEnumerationType target) {
		factory.createFEnumerator => [
			name = src.identifier
			target.enumerators.add(it)
		]
	}
	
	def private dispatch FModelElement transformDefinition(ConstantDef src, FModel target) {
		val definition = src.transformDefinition as FConstantDef
		target.addInAnonymousTypeCollection(definition)
		return definition
	}
	
	def private dispatch FModelElement transformDefinition(ConstantDef src) {
		factory.createFConstantDef => [
			name = src.identifier
			if (src.sharedType == null) {
				type = src.containedType.transformIDLType
			} else {
				type = src.sharedType.transformIDLType
			}
			rhs = src.constValue.transformExpression(type)
		]
	}
	
	// catch-all for this dispatch method
	def private dispatch FModelElement transformDefinition(Contained src, FModel target) {
		src.transformDefinition
	}
	
	def private dispatch FModelElement transformDefinition(Contained src) {
		addIssue(FEATURE_NOT_HANDLED_YET,
			src, IdlmmPackage::CONTAINED__IDENTIFIER,
			"OMG IDL definition '" + src.class.name + "' not handled yet (object '" + src.identifier + "')")
		return null
	}
	
	/*------------------ transform Typed --------------------------------- */
	
	def private dispatch transformTyped(Typed src, FStructType target) {
		addIssue(FEATURE_NOT_HANDLED_YET,
			src, IdlmmPackage::TYPED,
			"OMG IDL Typed '" + src.class.name + "' not handled yet (object '" + src.toString + "')")
	}
	
	def private dispatch transformTyped(Field src, FStructType target) {
		factory.createFField => [
			name = src.identifier
			if (src.sharedType != null) {
				type = src.sharedType.transformIDLType
			} else if (src.containedType instanceof PrimitiveDef) {
				type = (src.containedType as PrimitiveDef).transformIDLType
			} else if (src.containedType instanceof StructDef) {
				map_IDL_Franca.put(src.containedType, (src.containedType as StructDef).transformDefinition(map_IDL_Franca.get(src.translationUnit)))
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
	
	/* -------------------- transform IDLType ---------------------- */
	/**
	 * Generate the reference to other user-defined type
	 */
	def private dispatch FTypeRef transformIDLType(IDLType src) {
		factory.createFTypeRef => [
			switch src {
				// This case identifies that the type is invisible in the given interface A, since its container interface B is neither A nor a base interface of A
				case (src.interfaceContainer != null) && (!baseInterfaces.contains(src.interfaceContainer)): {
					predefined = FBasicTypeId.UNDEFINED
				}
				case map_IDL_Franca.containsKey(src) : derived = map_IDL_Franca.get(src) as FType
				default: {
					val translationUnit = src.translationUnit
					if (map_IDL_Franca.get(translationUnit) != null && src instanceof Contained) {
						derived = (src as Contained).transformDefinition(map_IDL_Franca.get(src.translationUnit)) as FType
						map_IDL_Franca.put(src, derived)
					} else {
						addIssue(FEATURE_NOT_HANDLED_YET,
							translationUnit, IdlmmPackage::TRANSLATION_UNIT,
							"OMG IDL Translation Unit '" + translationUnit.class.name + "' not handled yet (object '" + translationUnit + "')")
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
	
	def private dispatch FTypeRef transformIDLType(ArrayDef src) {
		return src.transformIDLType(map_IDL_Franca.get(src.translationUnit) as FModel, '', src.bounds.size)
	}
	
	def private FTypeRef transformIDLType(ArrayDef src, String prefix) {
		return src.transformIDLType(map_IDL_Franca.get(src.translationUnit) as FModel, prefix, src.bounds.size)
	}
	
	def private FTypeRef transformIDLType(ArrayDef src, FModel target, String prefix, int dimensionSize) {
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
						target.addInAnonymousTypeCollection(it)
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
		val uri = src.importURI
		if (uri.isNullOrEmpty) {
			addIssue(FEATURE_UNSUPPORTED_VALUE,
				src, IdlmmPackage::INCLUDE__IMPORT_URI,
				"The URI of imported IDL file '" + src + "' is null or empty"
			)
		}
		if (uri.contains(OMG_IDL_EXT)) {
			return uri.substring(0, uri.indexOf(OMG_IDL_EXT)) + FRANCA_IDL_EXT
		}
		return uri + FRANCA_IDL_EXT
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
	
	def private dispatch addInAnonymousTypeCollection (FModel target, FType type) {
		if (target.typeCollections.isNullOrEmpty) {
			val typeCollection = createTypeCollection(null, 1, 0)
			typeCollection.types.add(type)
			target.typeCollections.add(typeCollection)
		} else {
			target.typeCollections.get(0).types.add(type)
		}
	}
	
	def private dispatch addInAnonymousTypeCollection (FModel target, FConstantDef consttantDef) {
		if (target.typeCollections.isNullOrEmpty) {
			val typeCollection = createTypeCollection(null, 1, 0)
			typeCollection.constants.add(consttantDef)
			target.typeCollections.add(typeCollection)
		} else {
			target.typeCollections.get(0).constants.add(consttantDef)
		}
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
	
	def private getTranslationUnit (EObject object) {
		var obj = object.eContainer
		while (obj != null) {
			if (obj instanceof TranslationUnit){
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
		var obj = object.eContainer
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
