/** 
 * Copyright (c) 2014 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package org.franca.core.dsl.validation

import com.google.inject.Inject
import java.util.HashMap
import java.util.Map
import java.util.Set
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EReference
import org.eclipse.emf.ecore.EStructuralFeature
import org.eclipse.xtext.naming.IQualifiedNameProvider
import org.eclipse.xtext.nodemodel.INode
import org.eclipse.xtext.nodemodel.util.NodeModelUtils
import org.eclipse.xtext.validation.Check
import org.eclipse.xtext.validation.CheckMode
import org.eclipse.xtext.validation.ValidationMessageAcceptor
import org.franca.core.FrancaModelExtensions
import org.franca.core.dsl.validation.internal.ContractValidator
import org.franca.core.dsl.validation.internal.CyclicDependenciesValidator
import org.franca.core.dsl.validation.internal.OverloadingValidator
import org.franca.core.dsl.validation.internal.TypesValidator
import org.franca.core.dsl.validation.internal.ValidationHelpers
import org.franca.core.dsl.validation.internal.ValidationMessageReporter
import org.franca.core.dsl.validation.internal.ValidatorRegistry
import org.franca.core.framework.FrancaHelpers
import org.franca.core.franca.FAnnotation
import org.franca.core.franca.FAnnotationType
import org.franca.core.franca.FArgument
import org.franca.core.franca.FAssignment
import org.franca.core.franca.FAttribute
import org.franca.core.franca.FBroadcast
import org.franca.core.franca.FCompoundInitializer
import org.franca.core.franca.FCompoundType
import org.franca.core.franca.FConstantDef
import org.franca.core.franca.FContract
import org.franca.core.franca.FDeclaration
import org.franca.core.franca.FEnumerationType
import org.franca.core.franca.FEnumerator
import org.franca.core.franca.FEvaluableElement
import org.franca.core.franca.FExpression
import org.franca.core.franca.FField
import org.franca.core.franca.FGuard
import org.franca.core.franca.FIntegerInterval
import org.franca.core.franca.FInterface
import org.franca.core.franca.FMethod
import org.franca.core.franca.FModel
import org.franca.core.franca.FQualifiedElementRef
import org.franca.core.franca.FState
import org.franca.core.franca.FStructType
import org.franca.core.franca.FTrigger
import org.franca.core.franca.FType
import org.franca.core.franca.FTypeCollection
import org.franca.core.franca.FTypeDef
import org.franca.core.franca.FTypeRef
import org.franca.core.franca.FTypedElement
import org.franca.core.franca.FUnionType
import org.franca.core.franca.FrancaPackage

import static org.eclipse.xtext.nodemodel.util.NodeModelUtils.*
import static org.franca.core.dsl.validation.internal.ValidationHelpers.*
import static org.franca.core.franca.FrancaPackage.Literals.*

import static extension org.franca.core.FrancaModelExtensions.*
import static extension org.franca.core.dsl.validation.internal.FrancaNameProvider.*

/** 
 * This Java class is an intermediate class in the hierarchy of 
 * validators for Franca IDL. It is still here for historical reasons.
 * Please implement new validation methods in FrancaIDLValidator.xtend.
 */
class FrancaIDLValidator extends AbstractFrancaIDLValidator implements ValidationMessageReporter {
	@Inject protected CyclicDependenciesValidator cyclicDependenciesValidator
	@Inject protected IQualifiedNameProvider qnProvider

	/** 
	 * Call external validators (those have been installed via an
	 * Eclipse extension point).
	 */
	@Check def void checkExtensionValidators(FModel model) {
		var CheckMode mode = getCheckMode()
		for (IFrancaExternalValidator validator : ValidatorRegistry::getValidatorMap().get(mode)) {
			validator.validateModel(model, getMessageAcceptor())
		}
	}

	@Check def void checkTypeNamesUnique(FTypeCollection collection) {
		ValidationHelpers::checkDuplicates(this, collection.getTypes(), FrancaPackage.Literals::FMODEL_ELEMENT__NAME,
			"type name")
	}

	@Check def void checkTypeNamesUnique(FInterface iface) {
		ValidationHelpers::checkDuplicates(this, iface.getTypes(), FrancaPackage.Literals::FMODEL_ELEMENT__NAME,
			"type name")
	}

	@Check def void checkConstantNamesUnique(FTypeCollection collection) {
		ValidationHelpers::checkDuplicates(this, collection.getConstants(),
			FrancaPackage.Literals::FMODEL_ELEMENT__NAME, "constant name")
	}

	@Check def void checkConstantNamesUnique(FInterface iface) {
		ValidationHelpers::checkDuplicates(this, iface.getConstants(), FrancaPackage.Literals::FMODEL_ELEMENT__NAME,
			"constant name")
	}

	@Check def void checkStructHasElements(FStructType type) {
		if (type.getBase() === null && type.getElements().isEmpty() && !type.isPolymorphic()) {
			error("Non-polymorphic structs must have own or inherited elements", type,
				FrancaPackage.Literals::FMODEL_ELEMENT__NAME, -1)
		}
	}

	@Check def void checkUnionHasElements(FUnionType type) {
		if (type.getBase() === null && type.getElements().isEmpty()) {
			error("Union must have own or inherited elements", type, FrancaPackage.Literals::FMODEL_ELEMENT__NAME, -1)
		}
	}

	@Check def void checkEnumerationHasEnumerators(FEnumerationType type) {
		if (type.getEnumerators().isEmpty()) {
			error("Enumeration must not be empty", type, FrancaPackage.Literals::FMODEL_ELEMENT__NAME, -1)
		}
	}

	@Check def void checkMethodFlags(FMethod method) {
		if (method.isFireAndForget()) {
			if (!method.getOutArgs().isEmpty()) {
				error("Fire-and-forget methods cannot have out arguments", method,
					FrancaPackage.Literals::FMETHOD__FIRE_AND_FORGET, -1)
			}
			if (FrancaModelExtensions::hasErrorResponse(method)) {
				error("Fire-and-forget methods cannot have error return codes", method,
					FrancaPackage.Literals::FMETHOD__FIRE_AND_FORGET, -1)
			}
		}
	}

	@Check def void checkMethodArgsUnique(FMethod method) {
		ValidationHelpers::checkDuplicates(this, method.getInArgs(), FrancaPackage.Literals::FMODEL_ELEMENT__NAME,
			"argument name")
		ValidationHelpers::checkDuplicates(this, method.getOutArgs(), FrancaPackage.Literals::FMODEL_ELEMENT__NAME,
			"argument name")
		// check if in- and out-arguments are pairwise different
		var Map<String, FArgument> inArgs = new HashMap<String, FArgument>()
		for (FArgument a : method.getInArgs()) {
			inArgs.put(a.getName(), a)
		}
		for (FArgument a : method.getOutArgs()) {
			var String key = a.getName()
			if (inArgs.containsKey(key)) {
				var String msg = '''Duplicate argument name '«»«key»' used for in and out'''.toString
				error(msg, inArgs.get(key), FrancaPackage.Literals::FMODEL_ELEMENT__NAME, -1)
				error(msg, a, FrancaPackage.Literals::FMODEL_ELEMENT__NAME, -1)
			}
		}
	}

	@Check def void checkBroadcastArgsUnique(FBroadcast bc) {
		ValidationHelpers::checkDuplicates(this, bc.getOutArgs(), FrancaPackage.Literals::FMODEL_ELEMENT__NAME,
			"argument name")
	}

	@Check
	def checkAttributeFlags(FAttribute attribute) {
		if (attribute.isNoRead && attribute.isReadonly && attribute.isNoSubscriptions) {
			error(
				"Inconsistent flags of attribute '" + attribute.name + "', " +
				" prohibiting any read or write access.",
				attribute, FMODEL_ELEMENT__NAME)
		}
	}

	@Check def void checkConsistentInheritance(FInterface api) {
		ValidationHelpers::checkDuplicates(this, FrancaHelpers::getAllAttributes(api),
			FrancaPackage.Literals::FMODEL_ELEMENT__NAME, "attribute")
		// methods and broadcasts will be checked by the OverloadingValidator
		ValidationHelpers::checkDuplicates(this, FrancaHelpers::getAllTypes(api),
			FrancaPackage.Literals::FMODEL_ELEMENT__NAME, "type")
		ValidationHelpers::checkDuplicates(this, FrancaHelpers::getAllConstants(api),
			FrancaPackage.Literals::FMODEL_ELEMENT__NAME, "constant")
		if (api.getContract() !== null && FrancaHelpers::hasBaseContract(api)) {
			error("Interface cannot overwrite base contract", api.getContract(),
				FrancaPackage.Literals::FINTERFACE__CONTRACT, -1)
		}
	}

	@Check def void checkOverloadedMethods(FInterface api) {
		OverloadingValidator::checkOverloadedMethods(this, api)
	}

	@Check def void checkOverloadedBroadcasts(FInterface api) {
		OverloadingValidator::checkOverloadedBroadcasts(this, api)
	}

	@Check def void checkCyclicDependencies(FModel m) {
		cyclicDependenciesValidator.check(this, m)
	}

	/** 
	 * Check order of elements in an interface.
	 * The contract should be at the end of the interface definition.
	 * In Franca 0.9.0 and older, there was a fixed order of elements in the
	 * interface. With 0.9.1 and later, the order can be changed, but the contract
	 * has to be at the end of the interface.
	 * For backward compatibility reasons, we still allow constants and type definitions
	 * after the contract, but will mark these as deprecated.
	 * @see https://code.google.com/a/eclipselabs.org/p/franca/issues/detail?id=104#c1
	 * @param api the Franca interface
	 */
	@Check def void checkElementOrder(FInterface api) {
		if (api.getContract() !== null) {
			var INode contractNode = NodeModelUtils::getNode(api.getContract())
			if(contractNode === null) return;
			var int contractOffset = contractNode.getOffset()
			// check against all constant and type definitions
			var String msg = "Deprecated order of interface elements (contract should be at the end)"
			for (FConstantDef i : api.getConstants()) {
				var INode node = NodeModelUtils::getNode(i)
				if (node !== null) {
					var int offset = node.getOffset()
					if (offset > contractOffset) {
						warning(msg, api, FrancaPackage.Literals::FTYPE_COLLECTION__CONSTANTS,
							api.getConstants().indexOf(i))
					}
				}
			}
			for (FType i : api.getTypes()) {
				var INode node = NodeModelUtils::getNode(i)
				if (node !== null) {
					var int offset = node.getOffset()
					if (offset > contractOffset) {
						warning(msg, api, FrancaPackage.Literals::FTYPE_COLLECTION__TYPES, api.getTypes().indexOf(i))
					}
				}
			}
		}
	}

	// *****************************************************************************
	// type-related checks
	@Check def void checkConstantDef(FConstantDef constantDef) {
		TypesValidator::checkConstantType(this, constantDef)
	}

	@Check def void checkDeclaration(FDeclaration declaration) {
		TypesValidator::checkConstantType(this, declaration)
	}

	@Check def void checkEnumValue(FEnumerator enumerator) {
		if(enumerator.getValue() !== null) TypesValidator::checkEnumValueType(this, enumerator)
	}

	@Check def void checkIntegerInterval(FTypeRef intervalType) {
		if (intervalType.getInterval() !== null) {
			var FIntegerInterval interval = intervalType.getInterval()
			if (interval.getLowerBound() !== null && interval.getUpperBound() !== null) {
				if (interval.getLowerBound().compareTo(interval.getUpperBound()) > 0) {
					error("Invalid interval specification", intervalType, FrancaPackage.Literals::FTYPE_REF__INTERVAL,
						-1)
				}
			}
		}
	}

	// *****************************************************************************
	@Check def void checkContract(FContract contract) {
		ContractValidator::checkContract(this, contract)
	}

	@Check def void checkState(FState s) {
		ContractValidator::checkState(this, s)
	}

	@Check def void checkTrigger(FTrigger trigger) {
		ContractValidator::checkTrigger(this, trigger)
	}

	@Check def void checkAssignment(FAssignment assignment) {
		ContractValidator::checkAssignment(this, assignment)
	}

	@Check def void checkGuard(FGuard guard) {
		ContractValidator::checkGuard(this, guard)
	}

	// visibility of derived types
	@Check def void checkTypeVisible(FTypeRef typeref) {
		if (typeref.getDerived() !== null) {
			// this is a derived type, check if referenced type can be accessed
			var FType referencedType = typeref.getDerived()
			checkDefinitionVisible(typeref, referencedType, '''Type «referencedType.getName()»'''.toString,
				FrancaPackage.Literals::FTYPE_REF__DERIVED)
		}
	}

	@Check def void checkTypedElementRefVisible(FQualifiedElementRef qe) {
		var FEvaluableElement referenced = qe.getElement()
		if (referenced !== null && referenced instanceof FTypedElement) {
			checkDefinitionVisible(qe, referenced, '''«getTypeLabel(referenced)» «referenced.getName()»'''.toString,
				FrancaPackage.Literals::FQUALIFIED_ELEMENT_REF__ELEMENT)
		}
	}

	def private String getTypeLabel(FEvaluableElement elem) {
		if (elem instanceof FArgument) {
			return "Argument"
		} else if (elem instanceof FAttribute) {
			return "Attribute"
		} else if (elem instanceof FConstantDef) {
			return "Constant"
		} else if (elem instanceof FDeclaration) {
			return "State variable"
		} else if (elem instanceof FField) {
			return "Element of struct or union"
		} else if (elem instanceof FEnumerator) {
			return "Enumerator"
		} else {
			// sensible default
			return "Model element"
		}
	}

	def private void checkDefinitionVisible(EObject referrer, EObject referenced, String what,
		EReference referencingFeature) {
		var FInterface target = FrancaModelExtensions::getInterface(referenced)
		if (target === null) { // referenced element is defined by a type collection, can be accessed freely
		} else {
			// referenced element is defined by an FInterface, can be accessed if it is a public type
			var boolean isFType = referenced instanceof FType
			if (isFType && ((referenced as FType)).isPublic()) { // public visibility, do not show an error
			} else {
				// referenced element is not a public type, thus reference is only allowed from
				// the same FInterface (local access) or from on of its base interfaces (via inheritance)
				var FInterface referrerInterface = FrancaModelExtensions::getInterface(referrer)
				var boolean showError = false
				if (referrerInterface === null) {
					// referrer is a type collection, it cannot reference a type from an interface
					showError = true
				} else {
					var Set<FInterface> baseInterfaces = FrancaModelExtensions::
						getInterfaceInheritationSet(referrerInterface)
					if (!baseInterfaces.contains(target)) {
						showError = true
					}
				}
				if (showError) {
					error(
						'''«what» «(if (isFType) "is not public, thus it " else "" )»can only be referenced inside interface «target.getName()» or derived interfaces'''.
							toString, referrer, referencingFeature, -1)
				}
			}
		}
	}

	@Check def void checkPublicKeywordForType(FType type) {
		if (type.isPublic()) {
			var FInterface owner = FrancaModelExtensions::getInterface(type)
			if (owner === null) {
				// this is a type collection, "public" is not allowed here
				error("Misplaced 'public', types are always visible in type collections", type,
					FrancaPackage.Literals::FTYPE__PUBLIC, -1)
			}
		}
	}

	// *****************************************************************************
	@Check def void checkAnnotationType(FAnnotation annotation) {
		var FAnnotationType type = annotation.getType()
		if (type === null) {
			error("Invalid annotation type", annotation, FrancaPackage.Literals::FANNOTATION__RAW_TEXT, -1)
		}
	}

	/**
	 * Check that there is no name collision among type collections and interfaces.
	 * All pairwise combinations will be checked. This method also checks the imported
	 * type collisions and interfaces.
	 */
	@Check
	def checkPackageMemberNamesUnique(FModel model) {
		val members = model.namedPackageMembers
		if (members.empty) {
			return
		}

		// check local type collections
		checkDuplicates(this, members,
				FrancaPackage.Literals.FMODEL_ELEMENT__NAME,
				"model element");

		// check against imported type collections
		val imported = model.getAllImportedModels
		for(m : imported.importedModels) {
			for(other : m.namedPackageMembers) {
				val qn = qnProvider.getFullyQualifiedName(other)
				for(local : members) {
					val qn0 = qnProvider.getFullyQualifiedName(local)
					if (qn.equals(qn0)) {
						error(
							"Model element name collides with imported model element " +
							"(imported via " + imported.getViaString(m.eResource) + ")",
							local, FMODEL_ELEMENT__NAME)
					}
				}
			}
		}
	}

	/**
	 * Check if there is more than one anonymous type collection in a package.
	 * 
	 * This also takes into account imported anonymous type collections.
	 */
	@Check
	def checkAnonymousTypeCollections(FModel model) {
		var count = 0
		var FTypeCollection anon = null
		for (coll : model.typeCollections) {
			if (coll.isAnonymous) {
				anon = coll
				count = count + 1
			}
		}
		
		if (count > 1) {
			val pkg =
				if (model.name!==null)
					"package '" + model.name + "'"
				else
					"root package"
			error("duplicate anonymous type collection in " + pkg, model, FMODEL__NAME)
		}
		
		if (anon!==null) {
			// check against imported type collections
			val imported = model.getAllImportedModels
			for(m : imported.getImportedModels) {
				if (m.name == model.name) {
					for(tc : m.typeCollections) {
						if (tc.isAnonymous) {
							error(
								"Another anonymous type collection in same package is imported via " +
								imported.getViaString(m.eResource),
								model, FMODEL__NAME)
							return
						}
					}
				}
			}
		}
	}
	
	def private isAnonymous(FTypeCollection tc) {
		tc.name===null || tc.name.empty
	}
	
	@Check
	def checkCompoundElementsUnique(FCompoundType type) {
		val elements = type.elements
		checkDuplicates(this, elements, FMODEL_ELEMENT__NAME, "element name")

		val baseNames = getBaseElementNames(type, [name])
		for (f : elements) {
			val n = f.name
			if (baseNames.containsKey(n)) {
				error("Element name collision with base element '" + baseNames.get(n) + "'", f,
					FMODEL_ELEMENT__NAME)
			}
		}
	}

	@Check
	def checkUnionElementTypesUnique(FUnionType type) {
		// check types of this union locally
		val names = createNameList
		for (f : type.elements) {
			val rn = getResolvedName(f.type, f.array)
			names.add(f, rn)
		}
		checkDuplicates(this, names, FTYPED_ELEMENT__TYPE, "element type")

		// check inherited types vs. local types
		val baseNames = getBaseElementNames(type, [it.type.getResolvedName(it.array)])
		for (f : type.elements) {
			val n = f.type.getResolvedName(f.array)
			if (baseNames.containsKey(n)) {
				error("Element type collision with base element '" + baseNames.get(n) + "'", f,
					FTYPED_ELEMENT__TYPE);
			}
		}
	}

	def String getResolvedName(FTypeRef ref, boolean isArray) {
		val rn =
			if (ref.derived instanceof FTypeDef) {
				var defs = ref.derived as FTypeDef;
				defs.actualType.getResolvedName(false)
			} else {
				ref.name
			}
		if (isArray) rn + "[]" else rn
	}

	@Check
	def checkEnumeratorsUnique(FEnumerationType type) {
		val elements = type.enumerators
		checkDuplicates(this, elements, FMODEL_ELEMENT__NAME, "enumerator name");

		val baseNames = getBaseElementNames(type)
		for (f : elements) {
			val n = f.name
			if (baseNames.containsKey(n)) {
				error("Enumerator name collision with base element '" + baseNames.get(n) + "'", f,
					FMODEL_ELEMENT__NAME)
			}
		}
	}

	@Check
	def checkCompoundInitializersUnique(FCompoundInitializer initializer) {
		val names = createNameList
		for (e : initializer.elements) {
			names.add(e, e.element.name)
		}
		checkDuplicates(this, names, FFIELD_INITIALIZER__ELEMENT, "initializer field");
	}

	def private Map<String, String> getBaseElementNames(FCompoundType type, (FField)=>String nameProvider) {
		val Map<String, String> baseNames = newHashMap
		val base = type.getBase
		if (base !== null) {
			for (me : base.getAllElements) {
				val f = me as FField
				val owner = f.eContainer.name + "." + f.name
				val n = nameProvider.apply(f)
				baseNames.put(n, owner)
			}
		}
		baseNames
	}

	def private Map<String, String> getBaseElementNames(FEnumerationType type) {
		val Map<String, String> baseNames = newHashMap
		val base = type.base
		if (base !== null) {
			for (me : base.getAllElements) {
				val e = me as FEnumerator

				// if there is a cycle in the inheritance chain, type's elements will
				// be part of base.getAllElements: we block this here.
				if (! type.enumerators.contains(e)) {
					val owner = e.eContainer.name + "." + e.name
					baseNames.put(e.name, owner)
				}
			}
		}
		baseNames
	}

	/**
	 * Check if an enumerator definition is actually an invalid remainder of
	 * parsing on the lexer level, e.g. "ENUM1 = 0ENUM2". In this case, "0"
	 * will be parsed as integer (zero), and "ENUM2" will be parsed as next
	 * enumerator value. This can happen when no separator (optional comma)
	 * is used. 
	 * 
	 * We do not want to allow this kind of "hidden" enumerator definition.
	 * Therefore, we have to issue a validation error.
	 * 
	 * We have to do the implementation of the check on the parser's node model.   
	 */
	@Check
	def checkEnumeratorContext(FEnumerator enumerator) {
		val node = getNode(enumerator)
		val prev = node.getPreviousSibling
		
		// sanity check first
		if (node!==null && prev!==null) {
			// if there is no hidden element (i.e., whitespace) right before
			// the current node (corresponding to the enumerator under validation),
			// it is an indicator of the case we want to detect.
			if (! node.leafNodes.head.hidden) {
				// however, this might produce false positives
				// (e.g., "enumeration E {X }" should be legal, although there is
				// a curly bracket right before "X" and no whitespace).  
				val prevObj = prev.leafNodes.last.semanticElement
				if (prevObj!==null) {
					// now we check the previous node in the AST: if it is no expression
					// then we have a special case as with "{X" above.
					if (prevObj instanceof FExpression) {
						error(
							"invalid enumerator definition '" + enumerator.name + "', " +
							"use whitespace or comma to separate enumerators",
							enumerator, FMODEL_ELEMENT__NAME)
					}
				}
			}
		}
	}
	
	// *****************************************************************************
	// ValidationMessageReporter interface
	override void reportError(String message, EObject object, EStructuralFeature feature) {
		error(message, object, feature, ValidationMessageAcceptor::INSIGNIFICANT_INDEX)
	}

	override void reportError(String message, EObject object, EStructuralFeature feature, int index) {
		error(message, object, feature, index)
	}

	override void reportWarning(String message, EObject object, EStructuralFeature feature) {
		warning(message, object, feature, ValidationMessageAcceptor::INSIGNIFICANT_INDEX)
	}
}
