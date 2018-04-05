/*******************************************************************************
 * Copyright (c) 2018 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.deploymodel.dsl.validation

import com.google.common.collect.Lists
import java.util.List
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EReference
import org.eclipse.emf.ecore.EStructuralFeature
import org.eclipse.xtext.validation.Check
import org.eclipse.xtext.validation.CheckMode
import org.eclipse.xtext.validation.ValidationMessageAcceptor
import org.franca.core.FrancaModelExtensions
import org.franca.core.franca.FArgument
import org.franca.core.franca.FArrayType
import org.franca.core.franca.FAttribute
import org.franca.core.franca.FBroadcast
import org.franca.core.franca.FEnumerationType
import org.franca.core.franca.FEnumerator
import org.franca.core.franca.FField
import org.franca.core.franca.FInterface
import org.franca.core.franca.FMethod
import org.franca.core.franca.FStructType
import org.franca.core.franca.FType
import org.franca.core.franca.FTypeDef
import org.franca.core.franca.FUnionType
import org.franca.deploymodel.core.FDModelUtils
import org.franca.deploymodel.core.FDPropertyHost
import org.franca.deploymodel.core.PropertyMappings
import org.franca.deploymodel.dsl.FDMapper
import org.franca.deploymodel.dsl.FDSpecificationExtender
import org.franca.deploymodel.dsl.fDeploy.FDAbstractExtensionElement
import org.franca.deploymodel.dsl.fDeploy.FDArgument
import org.franca.deploymodel.dsl.fDeploy.FDArray
import org.franca.deploymodel.dsl.fDeploy.FDAttribute
import org.franca.deploymodel.dsl.fDeploy.FDBoolean
import org.franca.deploymodel.dsl.fDeploy.FDBroadcast
import org.franca.deploymodel.dsl.fDeploy.FDBuiltInPropertyHost
import org.franca.deploymodel.dsl.fDeploy.FDComplexValue
import org.franca.deploymodel.dsl.fDeploy.FDDeclaration
import org.franca.deploymodel.dsl.fDeploy.FDElement
import org.franca.deploymodel.dsl.fDeploy.FDEnumType
import org.franca.deploymodel.dsl.fDeploy.FDEnumValue
import org.franca.deploymodel.dsl.fDeploy.FDEnumeration
import org.franca.deploymodel.dsl.fDeploy.FDEnumerationOverwrites
import org.franca.deploymodel.dsl.fDeploy.FDEnumerator
import org.franca.deploymodel.dsl.fDeploy.FDExtensionElement
import org.franca.deploymodel.dsl.fDeploy.FDExtensionRoot
import org.franca.deploymodel.dsl.fDeploy.FDExtensionType
import org.franca.deploymodel.dsl.fDeploy.FDField
import org.franca.deploymodel.dsl.fDeploy.FDInteger
import org.franca.deploymodel.dsl.fDeploy.FDInterface
import org.franca.deploymodel.dsl.fDeploy.FDInterfaceRef
import org.franca.deploymodel.dsl.fDeploy.FDMethod
import org.franca.deploymodel.dsl.fDeploy.FDModel
import org.franca.deploymodel.dsl.fDeploy.FDOverwriteElement
import org.franca.deploymodel.dsl.fDeploy.FDPlainTypeOverwrites
import org.franca.deploymodel.dsl.fDeploy.FDPredefinedTypeId
import org.franca.deploymodel.dsl.fDeploy.FDProperty
import org.franca.deploymodel.dsl.fDeploy.FDPropertyDecl
import org.franca.deploymodel.dsl.fDeploy.FDPropertyFlag
import org.franca.deploymodel.dsl.fDeploy.FDPropertySet
import org.franca.deploymodel.dsl.fDeploy.FDRootElement
import org.franca.deploymodel.dsl.fDeploy.FDSpecification
import org.franca.deploymodel.dsl.fDeploy.FDString
import org.franca.deploymodel.dsl.fDeploy.FDStruct
import org.franca.deploymodel.dsl.fDeploy.FDStructOverwrites
import org.franca.deploymodel.dsl.fDeploy.FDType
import org.franca.deploymodel.dsl.fDeploy.FDTypeOverwrites
import org.franca.deploymodel.dsl.fDeploy.FDTypeRef
import org.franca.deploymodel.dsl.fDeploy.FDTypedef
import org.franca.deploymodel.dsl.fDeploy.FDTypes
import org.franca.deploymodel.dsl.fDeploy.FDUnion
import org.franca.deploymodel.dsl.fDeploy.FDUnionOverwrites
import org.franca.deploymodel.dsl.fDeploy.FDValue
import org.franca.deploymodel.dsl.fDeploy.FDValueArray
import org.franca.deploymodel.dsl.fDeploy.FDeployPackage
import org.franca.deploymodel.dsl.validation.internal.ValidatorRegistry
import org.franca.deploymodel.extensions.ExtensionRegistry
import org.franca.deploymodel.extensions.IFDeployExtension

/**
 * This class contains custom validation rules for the Franca deployment DSL.</p> 
 *
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#validation
 * </p>
 */
class FDeployValidator extends AbstractFDeployValidator implements ValidationMessageReporter {
	public static final String UPPERCASE_PROPERTYNAME_QUICKFIX = "UPPERCASE_PROPERTYNAME_QUICKFIX"
	public static final String METHOD_ARGUMENT_QUICKFIX = "METHOD_ARGUMENT_QUICKFIX"
	public static final String METHOD_ARGUMENT_QUICKFIX_MESSAGE = "Method argument is missing for method "
	public static final String BROADCAST_ARGUMENT_QUICKFIX = "BROADCAST_ARGUMENT_QUICKFIX"
	public static final String BROADCAST_ARGUMENT_QUICKFIX_MESSAGE = "Broadcast argument is missing for broadcast "
	public static final String COMPOUND_FIELD_QUICKFIX = "COMPOUND_FIELD_QUICKFIX"
	public static final String COMPOUND_FIELD_QUICKFIX_MESSAGE = "Field is missing for compound "
	public static final String ENUMERATOR_ENUM_QUICKFIX = "ENUMERATOR_ENUM_QUICKFIX"
	public static final String ENUMERATOR_ENUM_QUICKFIX_MESSAGE = "Enumerator element is missing for enum "
	public static final String MANDATORY_PROPERTY_QUICKFIX = "MANDATORY_PROPERTIES_QUICKFIX"
	public static final String MANDATORY_PROPERTY_QUICKFIX_MESSAGE = "Mandatory properties are missing for element "
	public static final String DEPLOYMENT_ELEMENT_QUICKFIX = "DEPLOYMENT_ELEMENT_QUICKFIX"
	public static final String DEPLOYMENT_ELEMENT_QUICKFIX_MESSAGE = "Missing specification element "
	public static final String DEPLOYMENT_ELEMENT_RECURSIVE_QUICKFIX = "DEPLOYMENT_ELEMENT_RECURSIVE_QUICKFIX"
	public static final String DEPLOYMENT_ELEMENT_RECURSIVE_QUICKFIX_MESSAGE = "There are multiple issues with element "

	// delegate to FDeployValidator
	package FDeployValidatorAux deployValidator = new FDeployValidatorAux(this)

	// *****************************************************************************
	/** 
	 * Call external validators (those which have been installed via the Eclipse
	 * 'deploymentValidator' extension point).
	 */
	@Check def void checkExtensionValidators(FDModel model) {
		var CheckMode mode = getCheckMode()
		for (IFDeployExternalValidator validator : ValidatorRegistry::getValidatorMap().get(mode)) {
			validator.validateModel(model, getMessageAcceptor())
		}
	}

	// *****************************************************************************
	// basic checks
	@Check def void checkSpecNamesUnique(FDModel model) {
		ValidationHelpers::checkDuplicates(this, model.getSpecifications(),
			FDeployPackage.Literals::FD_SPECIFICATION__NAME, "specification name")
	}

	@Check def void checkPropertyHosts(FDDeclaration decl) {
		var FDPropertyHost host = decl.getHost()
		if (host.getBuiltIn() === null) {
			// this is a host from an extension, check if it is valid
			if (ExtensionRegistry::findHost(host.getName()) === null) {
				// didn't find host by name
				error('''Invalid property host '«»«host.getName()»'«»'''.toString, decl,
					FDeployPackage.Literals::FD_DECLARATION__HOST, -1)
			}
		}
	}

	@Check def void checkExtensionRoot(FDExtensionRoot root) {
		var String tag = root.getTag()
		var IFDeployExtension.RootDef rootDef = ExtensionRegistry::findRoot(tag)
		if (rootDef === null) {
			// didn't find root by tag
			error('''Invalid root '«»«tag»', no matching deployment extension has been configured'''.toString, root,
				FDeployPackage.Literals::FD_ABSTRACT_EXTENSION_ELEMENT__TAG, -1)
		} else {
			if (root.getName() !== null && !rootDef.mayHaveName()) {
				error('''Root '«»«tag»' must not have a name'''.toString, root,
					FDeployPackage.Literals::FD_ROOT_ELEMENT__NAME, -1)
			}
			if (rootDef.mustHaveName() && root.getName() === null) {
				error('''Root '«»«tag»' must have a name'''.toString, root,
					FDeployPackage.Literals::FD_ABSTRACT_EXTENSION_ELEMENT__TAG, -1)
			}
		}
	}

	@Check def void checkExtensionElement(FDExtensionElement elem) {
		// check if this element is structurally allowed below its parent element
		var String tag = elem.getTag()
		var FDAbstractExtensionElement parent = (elem.eContainer() as FDAbstractExtensionElement)
		var IFDeployExtension.AbstractElementDef parentDef = ExtensionRegistry::getElement(parent)
		if (!hasChild(parentDef, tag)) {
			// didn't find root by tag
			error('''Invalid element tag '«»«tag»' for parent '«»«parentDef.getTag()»'«»'''.toString, elem,
				FDeployPackage.Literals::FD_ABSTRACT_EXTENSION_ELEMENT__TAG, -1)
			// do no further checks
			return;
		}
		// this element is structurally allowed, check name
		var IFDeployExtension.AbstractElementDef elemDef = ExtensionRegistry::getElement(elem)
		if (elem.getName() !== null && !elemDef.mayHaveName()) {
			error('''Element '«»«tag»' must not have a name'''.toString, elem,
				FDeployPackage.Literals::FD_EXTENSION_ELEMENT__NAME, -1)
		}
		if (elemDef.mustHaveName() && elem.getName() === null) {
			error('''Element '«»«tag»' must have a name'''.toString, elem,
				FDeployPackage.Literals::FD_ABSTRACT_EXTENSION_ELEMENT__TAG, -1)
		}
	}

	def private boolean hasChild(IFDeployExtension.AbstractElementDef elemDef, String tag) {
		for (IFDeployExtension.AbstractElementDef c : elemDef.getChildren()) {
			if(c.getTag().equals(tag)) return true
		}
		return false
	}

	@Check def void checkRootElementNamesUnique(FDModel model) {
		ValidationHelpers::checkDuplicates(this, model.getDeployments(),
			FDeployPackage.Literals::FD_ROOT_ELEMENT__NAME, "definition name")
	}

	@Check def void checkRootElement(FDRootElement elem) {
		deployValidator.checkRootElement(elem)
	}

	@Check def void checkMethodArgs(FDMethod method) {
		if (method.getInArguments() !== null) {
			for (FDArgument arg : method.getInArguments().getArguments()) {
				if (!method.getTarget().getInArgs().contains(arg.getTarget())) {
					error('''Invalid input argument '«»«arg.getTarget().getName()»'«»'''.toString, arg,
						FDeployPackage.Literals::FD_ARGUMENT__TARGET, -1)
				}
			}
		}
		if (method.getOutArguments() !== null) {
			for (FDArgument arg : method.getOutArguments().getArguments()) {
				if (!method.getTarget().getOutArgs().contains(arg.getTarget())) {
					error('''Invalid output argument '«»«arg.getTarget().getName()»'«»'''.toString, arg,
						FDeployPackage.Literals::FD_ARGUMENT__TARGET, -1)
				}
			}
		}
	}

	@Check def void checkBroadcastArgs(FDBroadcast broadcast) {
		if (broadcast.getOutArguments() !== null) {
			for (FDArgument arg : broadcast.getOutArguments().getArguments()) {
				if (!broadcast.getTarget().getOutArgs().contains(arg.getTarget())) {
					error('''Invalid output argument '«»«arg.getTarget().getName()»'«»'''.toString, arg,
						FDeployPackage.Literals::FD_ARGUMENT__TARGET, -1)
				}
			}
		}
	}

	@Check def void checkDuplicateProperties(FDPropertySet properties) {
		var ValidationHelpers.NameList names = ValidationHelpers::createNameList()
		for (FDProperty p : properties.getItems()) {
			if (p.getDecl().eIsProxy()) { // ignore unresolved properties
			} else {
				names.add(p, p.getDecl().getName())
			}
		}
		ValidationHelpers::checkDuplicates(this, names, FDeployPackage.Literals::FD_PROPERTY__DECL, "property")
	}

	// *****************************************************************************
	// validate specifications
	@Check def void checkPropertyName(FDPropertyDecl prop) {
		if (!Character::isUpperCase(prop.getName().charAt(0))) {
			error("Property names must begin with an uppercase character",
				FDeployPackage.Literals::FD_PROPERTY_DECL__NAME, UPPERCASE_PROPERTYNAME_QUICKFIX, prop.getName())
		}
	}

	@Check def void checkClashingProperties(FDSpecification spec) {
		deployValidator.checkClashingProperties(spec)
	}

	@Check def void checkBaseSpec(FDSpecification spec) {
		var FDSpecification cycleSpec = deployValidator.getCyclicBaseSpec(spec)
		if (cycleSpec !== null) {
			error('''Inheritance cycle for specification «cycleSpec.getName()»'''.toString, cycleSpec,
				FDeployPackage.Literals::FD_SPECIFICATION__BASE, -1)
			return;
		}
	}

	// *****************************************************************************
	// check for missing properties
	@Check def void checkPropertiesComplete(FDExtensionRoot elem) {
		// check own properties
		var FDSpecification spec = FDModelUtils::getRootElement(elem).getSpec()
		checkSpecificationElementProperties(spec, elem, FDeployPackage.Literals::FD_ROOT_ELEMENT__NAME, spec.getName())
		// check child elements recursively
		var FDSpecificationExtender specHelper = new FDSpecificationExtender(spec)
		for (FDExtensionElement child : elem.getElements()) {
			checkExtensionElement(spec, child)
		}
	}

	def private void checkExtensionElement(FDSpecification spec, FDExtensionElement elem) {
		// check own properties
		checkSpecificationElementProperties(spec, elem, FDeployPackage.Literals::FD_ABSTRACT_EXTENSION_ELEMENT__TAG,
			spec.getName())
		// check child elements recursively
		for (FDExtensionElement child : elem.getElements()) {
			checkExtensionElement(spec, child)
		}
	}

	@Check def void checkPropertiesComplete(FDTypes elem) {
		// check own properties
		var FDSpecification spec = FDModelUtils::getRootElement(elem).getSpec()
		checkSpecificationElementProperties(spec, elem, FDeployPackage.Literals::FD_TYPES__TARGET, spec.getName())
		// check child elements recursively
		var FDSpecificationExtender specHelper = new FDSpecificationExtender(spec)
		var PropertyDefChecker checker = new PropertyDefChecker(specHelper)
		var FDMapper mapper = new FDMapper(elem)
		var List<FType> targetTypes = elem.getTarget().getTypes()
		checkLocalTypes(targetTypes, specHelper, checker, mapper, spec, FDeployPackage.Literals::FD_TYPES__TARGET)
		deployValidator.checkUsedTypes(elem, targetTypes, checker)
	}

	@Check def void checkPropertiesComplete(FDInterface elem) {
		var int lowerLevelErrors = 0
		// check own properties
		var FDSpecification spec = FDModelUtils::getRootElement(elem).getSpec()
		if (checkSpecificationElementProperties(spec, elem, FDeployPackage.Literals::FD_INTERFACE__TARGET,
			spec.getName())) {
			lowerLevelErrors++
		}

		// check child elements recursively
		var FDSpecificationExtender specHelper = new FDSpecificationExtender(spec)
		var PropertyDefChecker checker = new PropertyDefChecker(specHelper)
		var FDMapper mapper = new FDMapper(elem)
		var FInterface target = elem.getTarget()
		for (FAttribute tc : target.getAttributes()) {
			var FDAttribute c = (mapper.getFDElement(tc) as FDAttribute)
			if (c === null) {
				if (checker.mustBeDefined(tc)) {
					error('''«DEPLOYMENT_ELEMENT_QUICKFIX_MESSAGE»'«»«tc.getName()»'«»'''.toString,
						FDeployPackage.Literals::FD_INTERFACE__TARGET, DEPLOYMENT_ELEMENT_QUICKFIX, tc.getName(),
						FrancaQuickFixConstants::ATTRIBUTE.toString())
					error('''«DEPLOYMENT_ELEMENT_RECURSIVE_QUICKFIX_MESSAGE»'«»«tc.getName()»'«»'''.toString,
						FDeployPackage.Literals::FD_INTERFACE__TARGET, DEPLOYMENT_ELEMENT_RECURSIVE_QUICKFIX,
						tc.getName(), FrancaQuickFixConstants::ATTRIBUTE.toString())
					lowerLevelErrors++
				}
			} else if (checkSpecificationElementProperties(spec, c, FDeployPackage.Literals::FD_ATTRIBUTE__TARGET,
				tc.getName())) {
				lowerLevelErrors++
			}
		}
		for (FMethod tc : target.getMethods()) {
			var FDMethod c = (mapper.getFDElement(tc) as FDMethod)
			if (c === null) {
				if (checker.mustBeDefined(tc)) {
					var String name = FrancaModelExtensions::getUniqueName(tc)
					error('''«DEPLOYMENT_ELEMENT_QUICKFIX_MESSAGE»'«»«name»'«»'''.toString,
						FDeployPackage.Literals::FD_INTERFACE__TARGET, DEPLOYMENT_ELEMENT_QUICKFIX, name,
						FrancaQuickFixConstants::METHOD.toString())
					error('''«DEPLOYMENT_ELEMENT_RECURSIVE_QUICKFIX_MESSAGE»'«»«name»'«»'''.toString,
						FDeployPackage.Literals::FD_INTERFACE__TARGET, DEPLOYMENT_ELEMENT_RECURSIVE_QUICKFIX, name,
						FrancaQuickFixConstants::METHOD.toString())
					lowerLevelErrors++
				}
			} else {
				var String name = FrancaModelExtensions::getUniqueName(tc)
				if (checkSpecificationElementProperties(spec, c, FDeployPackage.Literals::FD_METHOD__TARGET, name)) {
					lowerLevelErrors++
				}
				val checkIn = checkArgumentList(specHelper, checker, mapper, spec, tc.getInArgs(), c, "Input", FDeployPackage.Literals::FD_METHOD__TARGET)
				val checkOut = checkArgumentList(specHelper, checker, mapper, spec, tc.getOutArgs(), c, "Output", FDeployPackage.Literals::FD_METHOD__TARGET)
				if (checkIn || checkOut) {
					error('''«DEPLOYMENT_ELEMENT_RECURSIVE_QUICKFIX_MESSAGE»'«»«name»'«»'''.toString, c,
						FDeployPackage.Literals::FD_METHOD__TARGET, DEPLOYMENT_ELEMENT_RECURSIVE_QUICKFIX, name,
						FrancaQuickFixConstants::METHOD.toString())
					lowerLevelErrors++
				}
			}
		}
		for (FBroadcast tc : target.getBroadcasts()) {
			var FDBroadcast c = (mapper.getFDElement(tc) as FDBroadcast)
			if (c === null) {
				if (checker.mustBeDefined(tc)) {
					var String name = FrancaModelExtensions::getUniqueName(tc)
					error('''«DEPLOYMENT_ELEMENT_QUICKFIX_MESSAGE»'«»«name»'«»'''.toString,
						FDeployPackage.Literals::FD_INTERFACE__TARGET, DEPLOYMENT_ELEMENT_QUICKFIX, name,
						FrancaQuickFixConstants::BROADCAST.toString())
					error('''«DEPLOYMENT_ELEMENT_RECURSIVE_QUICKFIX_MESSAGE»'«»«name»'«»'''.toString,
						FDeployPackage.Literals::FD_INTERFACE__TARGET, DEPLOYMENT_ELEMENT_RECURSIVE_QUICKFIX, name,
						FrancaQuickFixConstants::BROADCAST.toString())
					lowerLevelErrors++
				}
			} else {
				var String name = FrancaModelExtensions::getUniqueName(tc)
				if (checkSpecificationElementProperties(spec, c, FDeployPackage.Literals::FD_BROADCAST__TARGET,
					name)) {
					lowerLevelErrors++
				}
				if (checkArgumentList(specHelper, checker, mapper, spec, tc.getOutArgs(), c, "Output",
					FDeployPackage.Literals::FD_BROADCAST__TARGET)) {
					error('''«DEPLOYMENT_ELEMENT_RECURSIVE_QUICKFIX_MESSAGE»'«»«name»'«»'''.toString, c,
						FDeployPackage.Literals::FD_BROADCAST__TARGET, DEPLOYMENT_ELEMENT_RECURSIVE_QUICKFIX, name,
						FrancaQuickFixConstants::BROADCAST.toString())
					lowerLevelErrors++
				}
			}
		}
		if (checkLocalTypes(target.getTypes(), specHelper, checker, mapper, spec,
			FDeployPackage.Literals::FD_INTERFACE__TARGET)) {
			lowerLevelErrors++
		}
		if (deployValidator.checkUsedTypes(elem, target.getTypes(), checker)) {
			lowerLevelErrors++
		}
		// show a global quickfix on the root element, if any error on the detail level occurred
		if (lowerLevelErrors > 0) {
			// Recursive quickfix can be added for the top level FDInterface element
			error('''«DEPLOYMENT_ELEMENT_RECURSIVE_QUICKFIX_MESSAGE»'«»«spec.getName()»'«»'''.toString, elem,
				FDeployPackage.Literals::FD_INTERFACE__TARGET, DEPLOYMENT_ELEMENT_RECURSIVE_QUICKFIX, spec.getName(),
				FrancaQuickFixConstants::INTERFACE.toString())
		}
	}

	/** 
	 * Checks the local types of an {@link FDSpecification} instance. 
	 * @return true if an error is present, false otherwise
	 */
	def private boolean checkLocalTypes(List<FType> types, FDSpecificationExtender specHelper,
		PropertyDefChecker checker, FDMapper mapper, FDSpecification spec, EStructuralFeature parentFeature) {
		var boolean hasError = false
		for (FType tc : types) {
			if (tc instanceof FArrayType) {
				var FDArray c = (mapper.getFDElement(tc) as FDArray)
				if (c === null) {
					if (checker.mustBeDefined((tc as FArrayType))) {
						error('''«DEPLOYMENT_ELEMENT_QUICKFIX_MESSAGE»'«»«tc.getName()»'«»'''.toString, parentFeature,
							DEPLOYMENT_ELEMENT_QUICKFIX, tc.getName(), FrancaQuickFixConstants::ARRAY.toString())
						error('''«DEPLOYMENT_ELEMENT_RECURSIVE_QUICKFIX_MESSAGE»'«»«tc.getName()»'«»'''.toString,
							parentFeature, DEPLOYMENT_ELEMENT_RECURSIVE_QUICKFIX, tc.getName(),
							FrancaQuickFixConstants::ARRAY.toString())
						hasError = true
					}
				} else {
					if (checkSpecificationElementProperties(spec, c, FDeployPackage.Literals::FD_ARRAY__TARGET, tc.getName()))
						hasError = true
				}
			} else if (tc instanceof FStructType) {
				var FDStruct c = (mapper.getFDElement(tc) as FDStruct)
				if (c === null) {
					if (checker.mustBeDefined((tc as FStructType))) {
						error('''«DEPLOYMENT_ELEMENT_QUICKFIX_MESSAGE»'«»«tc.getName()»'«»'''.toString, parentFeature,
							DEPLOYMENT_ELEMENT_QUICKFIX, tc.getName(), FrancaQuickFixConstants::STRUCT.toString())
						error('''«DEPLOYMENT_ELEMENT_RECURSIVE_QUICKFIX_MESSAGE»'«»«tc.getName()»'«»'''.toString,
							parentFeature, DEPLOYMENT_ELEMENT_RECURSIVE_QUICKFIX, tc.getName(),
							FrancaQuickFixConstants::STRUCT.toString())
						hasError = true
					}
				} else {
					if (checkSpecificationElementProperties(spec, c, FDeployPackage.Literals::FD_STRUCT__TARGET, tc.getName()))
						hasError = true
					if (checkFieldsList(specHelper, checker, mapper, spec, ((tc as FStructType)).getElements(), c,
						FDeployPackage.Literals::FD_STRUCT__TARGET, "Struct")) {
						error('''«DEPLOYMENT_ELEMENT_RECURSIVE_QUICKFIX_MESSAGE»'«»«tc.getName()»'«»'''.toString, c,
							FDeployPackage.Literals::FD_STRUCT__TARGET, DEPLOYMENT_ELEMENT_RECURSIVE_QUICKFIX,
							tc.getName(), FrancaQuickFixConstants::STRUCT.toString())
						hasError = true
					}
				}
			} else if (tc instanceof FUnionType) {
				var FDUnion c = (mapper.getFDElement(tc) as FDUnion)
				if (c === null) {
					if (checker.mustBeDefined((tc as FUnionType))) {
						error('''«DEPLOYMENT_ELEMENT_QUICKFIX_MESSAGE»'«»«tc.getName()»'«»'''.toString, parentFeature,
							DEPLOYMENT_ELEMENT_QUICKFIX, tc.getName(), FrancaQuickFixConstants::UNION.toString())
						error('''«DEPLOYMENT_ELEMENT_RECURSIVE_QUICKFIX_MESSAGE»'«»«tc.getName()»'«»'''.toString,
							parentFeature, DEPLOYMENT_ELEMENT_RECURSIVE_QUICKFIX, tc.getName(),
							FrancaQuickFixConstants::UNION.toString())
						hasError = true
					}
				} else {
					if (checkSpecificationElementProperties(spec, c, FDeployPackage.Literals::FD_UNION__TARGET, tc.getName()))
						hasError = true
					if (checkFieldsList(specHelper, checker, mapper, spec, ((tc as FUnionType)).getElements(), c,
						FDeployPackage.Literals::FD_UNION__TARGET, "Union")) {
						error('''«DEPLOYMENT_ELEMENT_RECURSIVE_QUICKFIX_MESSAGE»'«»«tc.getName()»'«»'''.toString, c,
							FDeployPackage.Literals::FD_UNION__TARGET, DEPLOYMENT_ELEMENT_RECURSIVE_QUICKFIX,
							tc.getName(), FrancaQuickFixConstants::UNION.toString())
						hasError = true
					}
				}
			} else if (tc instanceof FEnumerationType) {
				var FDEnumeration c = (mapper.getFDElement(tc) as FDEnumeration)
				if (c === null) {
					if (checker.mustBeDefined((tc as FEnumerationType))) {
						error('''«DEPLOYMENT_ELEMENT_QUICKFIX_MESSAGE»'«»«tc.getName()»'«»'''.toString, parentFeature,
							DEPLOYMENT_ELEMENT_QUICKFIX, tc.getName(), FrancaQuickFixConstants::ENUMERATION.toString())
						error('''«DEPLOYMENT_ELEMENT_RECURSIVE_QUICKFIX_MESSAGE»'«»«tc.getName()»'«»'''.toString,
							parentFeature, DEPLOYMENT_ELEMENT_RECURSIVE_QUICKFIX, tc.getName(),
							FrancaQuickFixConstants::ENUMERATION.toString())
						hasError = true
					}
				} else {
					if (checkSpecificationElementProperties(spec, c, FDeployPackage.Literals::FD_ENUMERATION__TARGET, tc.getName()))
						hasError = true
					if (checkEnumeratorsList(specHelper, mapper, spec, ((tc as FEnumerationType)).getEnumerators(), c,
						FDeployPackage.Literals::FD_ENUMERATION__TARGET)) {
						error('''«DEPLOYMENT_ELEMENT_RECURSIVE_QUICKFIX_MESSAGE»'«»«tc.getName()»'«»'''.toString, c,
							FDeployPackage.Literals::FD_ENUMERATION__TARGET, DEPLOYMENT_ELEMENT_RECURSIVE_QUICKFIX,
							tc.getName(), FrancaQuickFixConstants::ENUMERATION.toString())
						hasError = true
					}
				}
			} else if (tc instanceof FTypeDef) {
				var FDTypedef c = (mapper.getFDElement(tc) as FDTypedef)
				if (c === null) {
					if (checker.mustBeDefined((tc as FTypeDef))) {
						error('''«DEPLOYMENT_ELEMENT_QUICKFIX_MESSAGE»'«»«tc.getName()»'«»'''.toString, parentFeature,
							DEPLOYMENT_ELEMENT_QUICKFIX, tc.getName(), FrancaQuickFixConstants::TYPEDEF.toString())
						error('''«DEPLOYMENT_ELEMENT_RECURSIVE_QUICKFIX_MESSAGE»'«»«tc.getName()»'«»'''.toString,
							parentFeature, DEPLOYMENT_ELEMENT_RECURSIVE_QUICKFIX, tc.getName(),
							FrancaQuickFixConstants::TYPEDEF.toString())
						hasError = true
					}
				} else {
					if (checkSpecificationElementProperties(spec, c, FDeployPackage.Literals::FD_TYPEDEF__TARGET, tc.getName()))
						hasError = true
				}
			}
		}
		return hasError
	}

	/** 
	 * Checks the argument list of {@link FDMethod}s and {@link FDBroadcast}s.
	 * @return true if an error is present, false otherwise
	 */
	def private boolean checkArgumentList(FDSpecificationExtender specHelper, PropertyDefChecker checker,
		FDMapper mapper, FDSpecification spec, List<FArgument> args, FDElement parent, String tag,
		EStructuralFeature feature) {
			var boolean hasError = false
			for (FArgument tc : args) {
				var FDArgument c = (mapper.getFDElement(tc) as FDArgument)
				if (c === null) {
					if (checker.mustBeDefined(tc)) {
						var String opName = ""
						var String opType = ""
						var String quickfix = ""
						if (parent instanceof FDMethod) {
							opName = FrancaModelExtensions::getUniqueName(((parent as FDMethod)).getTarget())
							opType = "method"
							quickfix = METHOD_ARGUMENT_QUICKFIX
						}
						if (parent instanceof FDBroadcast) {
							opName = FrancaModelExtensions::getUniqueName(((parent as FDBroadcast)).getTarget())
							opType = "broadcast"
							quickfix = BROADCAST_ARGUMENT_QUICKFIX
						}
						error(
							'''Mandatory argument '«»«tc.getName()»' is missing for «opType» '«»«opName»'«»'''.toString,
							parent, feature, -1, quickfix, opName, tc.getName())
						hasError = true
					}
				} else {
					if (checkSpecificationElementProperties(spec, c, FDeployPackage.Literals::FD_ARGUMENT__TARGET, tc.getName()))
						hasError = true
				}
			}
			return hasError
		}

		/** 
		 * Checks the field list of {@link FDUnion}s and {@link FDStruct}s.
		 * @return true if an error is present, false otherwise
		 */
		def private boolean checkFieldsList(FDSpecificationExtender specHelper, PropertyDefChecker checker,
			FDMapper mapper, FDSpecification spec, List<FField> fields, FDElement parent, EStructuralFeature feature,
			String tag) {
			var boolean hasError = false
			for (FField tc : fields) {
				var FDField c = (mapper.getFDElement(tc) as FDField)
				if (c === null) {
					if (checker.mustBeDefined(tc)) {
						var String name = ""
						if (parent instanceof FDUnion) {
							name = ((parent as FDUnion)).getTarget().getName()
						} else if (parent instanceof FDStruct) {
							name = ((parent as FDStruct)).getTarget().getName()
						}
						error('''Mandatory field '«»«tc.getName()»' is missing for compound '«»«name»'«»'''.toString,
							parent, feature, -1, COMPOUND_FIELD_QUICKFIX, name, tc.getName())
						hasError = true
					}
				} else {
					if (checkSpecificationElementProperties(spec, c, FDeployPackage.Literals::FD_FIELD__TARGET, tc.getName()))
						hasError = true
				}
			}
			return hasError
		}

		/** 
		 * Checks the enumerator list of {@link FDEnumerator}s.
		 * @return true if an error is present, false otherwise
		 */
		def private boolean checkEnumeratorsList(FDSpecificationExtender specHelper, FDMapper mapper,
			FDSpecification spec, List<FEnumerator> enumerators, FDElement parent, EStructuralFeature feature) {
			var boolean hasError = false
			for (FEnumerator tc : enumerators) {
				var FDEnumValue c = (mapper.getFDElement(tc) as FDEnumValue)
				if (c === null) {
					if (specHelper.isMandatory(FDPropertyHost::builtIn(FDBuiltInPropertyHost::ENUMERATORS))) {
						error(
							'''Mandatory enumerator '«»«tc.getName()»' is missing for enumeration '«»«((parent as FDEnumeration)).getTarget().getName()»'«»'''.
								toString, parent, feature, -1, ENUMERATOR_ENUM_QUICKFIX,
							((parent as FDEnumeration)).getTarget().getName(), tc.getName())
						hasError = true
					}
				} else {
					if (checkSpecificationElementProperties(spec, c, FDeployPackage.Literals::FD_ENUM_VALUE__TARGET, tc.getName()))
						hasError = true
				}
			}
			return hasError
		}

		// *****************************************************************************
		/** 
		 * Checks whether all of the mandatory properties of the given {@link FDSpecification} instance are present. 
		 * @param spec the deployment specification element
		 * @param elem the given element
		 * @param feature the corresponding feature instance
		 * @param elementName the name of the element for the quickfix message
		 * @return true if there was an error (missing property), false otherwise
		 */
		def private boolean checkSpecificationElementProperties(FDSpecification spec, FDElement elem,
			EStructuralFeature feature, String elementName) {
			var List<FDPropertyDecl> decls = PropertyMappings::getAllPropertyDecls(spec, elem)
			var List<String> missing = Lists::newArrayList()
			for (FDPropertyDecl decl : decls) {
				if (PropertyMappings::isMandatory(decl)) {
					if (!contains(elem.getProperties().getItems(), decl)) {
						missing.add(decl.getName())
					}
				}
			}
			if (!missing.isEmpty()) {
				error('''«MANDATORY_PROPERTY_QUICKFIX_MESSAGE»'«»«elementName»'«»'''.toString, elem, feature, -1,
					MANDATORY_PROPERTY_QUICKFIX, elementName)
				// error(MANDATORY_PROPERTY_QUICKFIX_MESSAGE + "'" + elementName + "'", elem, feature, -1);
				return true
			}
			return false
		}

		def private boolean contains(List<FDProperty> properties, FDPropertyDecl decl) {
			for (FDProperty p : properties) {
				if (p.getDecl() === decl) {
					return true
				}
			}
			return false
		}

		// *****************************************************************************
		// overwrite sections in deployment definitions 
		@Check def void checkOverwriteSections(FDTypeOverwrites elem) {
			var EObject parent = elem.eContainer()
			if (parent instanceof FDOverwriteElement) {
				var FType targetType = FDModelUtils::getOverwriteTargetType((parent as FDOverwriteElement))
				if (targetType === null) {
					error("Cannot determine target type of overwrite section", parent,
						FDeployPackage.Literals::FD_OVERWRITE_ELEMENT__OVERWRITES)
				} else {
					if (elem instanceof FDPlainTypeOverwrites) { // FDPlainTypeOverwrites is always ok
					} else {
						if (targetType instanceof FStructType) {
							if (!(elem instanceof FDStructOverwrites)) {
								error("Invalid overwrite tag, use '#struct'", parent,
									FDeployPackage.Literals::FD_OVERWRITE_ELEMENT__OVERWRITES)
							}
						} else if (targetType instanceof FUnionType) {
							if (!(elem instanceof FDUnionOverwrites)) {
								error("Invalid overwrite tag, use '#union'", parent,
									FDeployPackage.Literals::FD_OVERWRITE_ELEMENT__OVERWRITES)
							}
						} else if (targetType instanceof FEnumerationType) {
							if (!(elem instanceof FDEnumerationOverwrites)) {
								error("Invalid overwrite tag, use '#enumeration'", parent,
									FDeployPackage.Literals::FD_OVERWRITE_ELEMENT__OVERWRITES)
							}
						}
					}
				}
			}
		}

		// *****************************************************************************
		// type system
		@Check def void checkExtensionTyoe(FDExtensionType type) {
			var String name = type.getName()
			var IFDeployExtension.TypeDef typeDef = ExtensionRegistry::findType(name)
			if (typeDef === null) {
				// didn't find type by name
				error('''Invalid type '«»«name»', no matching deployment extension has been configured'''.toString,
					type, FDeployPackage.Literals::FD_EXTENSION_TYPE__NAME, -1)
			}
		}

		@Check def void checkPropertyFlagType(FDPropertyFlag flag) {
			if(flag.getDefault() === null) return;
			var FDPropertyDecl decl = (flag.eContainer() as FDPropertyDecl)
			var FDTypeRef typeRef = decl.getType()
			var FDComplexValue value = flag.getDefault()
			if (value.getSingle() !== null) {
				if(typeRef.getArray() !== null) error("Default must be an array!",
					FDeployPackage.Literals::FD_PROPERTY_FLAG__DEFAULT) else checkValueType(typeRef, value.getSingle(),
					flag, FDeployPackage.Literals::FD_PROPERTY_FLAG__DEFAULT, -1)
			} else if (value.getArray() !== null) {
				if (typeRef.getArray() === null) {
					error("Default must be a single type, not an array!",
						FDeployPackage.Literals::FD_PROPERTY_FLAG__DEFAULT)
				} else
					checkValueArrayType(typeRef, value.getArray())
			}
		}

		@Check def void checkPropertyValueType(FDProperty prop) {
			var FDTypeRef typeRef = prop.getDecl().getType()
			var FDComplexValue value = prop.getValue()
			if (value.getSingle() !== null) {
				if(typeRef.getArray() !== null) error("Invalid type, expected array!",
					FDeployPackage.Literals::FD_PROPERTY__VALUE) else checkValueType(typeRef, value.getSingle(), prop,
					FDeployPackage.Literals::FD_PROPERTY__VALUE, -1)
			} else if (value.getArray() !== null) {
				if(typeRef.getArray() === null) error("Invalid array type, expected single value!",
					FDeployPackage.Literals::FD_PROPERTY__VALUE) else checkValueArrayType(typeRef, value.getArray())
			}
		}

		def private void checkValueType(FDTypeRef typeRef, FDValue value, EObject src, EReference literal, int index) {
			if (typeRef.getComplex() === null) {
				// this is a predefined type
				val predefined = typeRef.predefined.value
				switch (predefined) {
					case FDPredefinedTypeId.INTEGER_VALUE: {
						if (! (value instanceof FDInteger)) {
							error("Invalid type, expected Integer constant", src, literal, index)
						}
					}
					case FDPredefinedTypeId.STRING_VALUE: {
						if (! (value instanceof FDString)) {
							error("Invalid type, expected String constant", src, literal, index)
						}
					}
					case FDPredefinedTypeId.BOOLEAN_VALUE: {
						if (! (value instanceof FDBoolean)) {
							error("Invalid type, expected 'true' or 'false'", src, literal, index)
						}
					}
					case FDPredefinedTypeId.INTERFACE_VALUE: {
						if (! (value instanceof FDInterfaceRef)) {
							error("Invalid type, expected reference to Franca interface", src, literal, index)
						}
					}
				}
			} else {
				var FDType type = typeRef.getComplex()
				if (type instanceof FDEnumType) {
					if (!(FDModelUtils::isEnumerator(value))) {
						error("Invalid type, expected enumerator", src, literal, index)
					}
				}
			}
		}

		def private void checkValueArrayType(FDTypeRef typeRef, FDValueArray array) {
			var int i = 0
			for (FDValue value : array.getValues()) {
				checkValueType(typeRef, value, array, FDeployPackage.Literals::FD_VALUE_ARRAY__VALUES, i)
				i++
			}
		}

		// *****************************************************************************
		// ValidationMessageReporter interface
		override void reportError(String message, EObject object, EStructuralFeature feature) {
			error(message, object, feature, ValidationMessageAcceptor::INSIGNIFICANT_INDEX)
		}

		override void reportError(String message, EObject object, EStructuralFeature feature, int idx) {
			error(message, object, feature, idx)
		}

		override void reportWarning(String message, EObject object, EStructuralFeature feature) {
			warning(message, object, feature, ValidationMessageAcceptor::INSIGNIFICANT_INDEX)
		}

}
