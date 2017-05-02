/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.deploymodel.dsl.ui.quickfix

import java.util.List
import java.util.Set
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.ui.editor.model.edit.IModificationContext
import org.eclipse.xtext.ui.editor.quickfix.DefaultQuickfixProvider
import org.eclipse.xtext.ui.editor.quickfix.Fix
import org.eclipse.xtext.ui.editor.quickfix.IssueResolutionAcceptor
import org.eclipse.xtext.util.Arrays
import org.eclipse.xtext.validation.Issue
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
import org.franca.core.franca.FModelElement
import org.franca.core.franca.FStructType
import org.franca.core.franca.FType
import org.franca.core.franca.FTypeDef
import org.franca.core.franca.FUnionType
import org.franca.deploymodel.core.FDModelUtils
import org.franca.deploymodel.core.PropertyMappings
import org.franca.deploymodel.dsl.fDeploy.FDArgumentList
import org.franca.deploymodel.dsl.fDeploy.FDBroadcast
import org.franca.deploymodel.dsl.fDeploy.FDComplexValue
import org.franca.deploymodel.dsl.fDeploy.FDElement
import org.franca.deploymodel.dsl.fDeploy.FDEnumValue
import org.franca.deploymodel.dsl.fDeploy.FDEnumeration
import org.franca.deploymodel.dsl.fDeploy.FDInterface
import org.franca.deploymodel.dsl.fDeploy.FDMethod
import org.franca.deploymodel.dsl.fDeploy.FDProperty
import org.franca.deploymodel.dsl.fDeploy.FDPropertyDecl
import org.franca.deploymodel.dsl.fDeploy.FDStruct
import org.franca.deploymodel.dsl.fDeploy.FDTypes
import org.franca.deploymodel.dsl.fDeploy.FDUnion
import org.franca.deploymodel.dsl.fDeploy.FDeployFactory
import org.franca.deploymodel.dsl.validation.FDeployJavaValidator
import org.franca.deploymodel.dsl.validation.FrancaQuickFixConstants

import static extension org.franca.deploymodel.dsl.ui.quickfix.FDeployQuickfixProviderUtil.*
import static extension org.franca.deploymodel.dsl.validation.FrancaQuickFixConstants.*

/** 
 * A collection of quick fixes for Franca Deployment Definitions.
 * 
 * @author Tamas Szabo, Klaus Birken (itemis AG)
 */
class FDeployQuickfixProvider extends DefaultQuickfixProvider {
	@Fix(FDeployJavaValidator.UPPERCASE_PROPERTYNAME_QUICKFIX)
	def void setUppercasePropertyName(Issue issue, IssueResolutionAcceptor acceptor) {
		val data = issue.getData().get(0)
		val description = '''Set first character to uppercase for property «data»'''
		acceptor.accept(issue, description, description, "",
			[ EObject obj, IModificationContext context |
				if (obj instanceof FDPropertyDecl) {
					if (obj.type !== null) {
						var newName = obj.name.toFirstUpper
						obj.setName(newName)
					}

				}
			])
	}

	@Fix(FDeployJavaValidator.DEPLOYMENT_ELEMENT_RECURSIVE_QUICKFIX)
	def void applyRecursiveFix(Issue issue,
		IssueResolutionAcceptor acceptor) {
		val FrancaQuickFixConstants type = FrancaQuickFixConstants.valueOf(issue.getData().get(1))
		val String elementName = if((type === FrancaQuickFixConstants.INTERFACE)) null else issue.getData().get(0)
		val String description = '''Fix all issues for element '«issue.getData().get(0)»'«»'''
		acceptor.accept(issue, description, description, "",
			[ EObject obj, IModificationContext context |
				if (obj instanceof FDInterface) {
					applyFixForInterfaceInternal(obj, type, elementName, true)
				} else if (obj instanceof FDTypes) {
					applyFixForTypesInternal(obj, type, elementName, true)
				} else if (obj instanceof FDElement) {
					applyFixForElementInternal(obj, true)
				}
			])
	}

	@Fix(FDeployJavaValidator.DEPLOYMENT_ELEMENT_QUICKFIX)
	def void applyFixForInterface(Issue issue,
		IssueResolutionAcceptor acceptor) {
		val String elementName = issue.getData().get(0)
		val type = valueOf(issue.getData().get(1))
		val String description = '''Add missing «type.toString().toLowerCase()» '«elementName»'«»'''
		acceptor.accept(issue, description, description, "",
			[ EObject obj, IModificationContext context |
				if (obj instanceof FDInterface) {
					applyFixForInterfaceInternal(obj, type, elementName, false)
				} else if (obj instanceof FDTypes) {
					applyFixForTypesInternal(obj, type, elementName, false)
				}
			])
	}

	@Fix(FDeployJavaValidator.MANDATORY_PROPERTY_QUICKFIX)
	def void applyFixForElement(Issue issue,
		IssueResolutionAcceptor acceptor) {
		val String elementName = issue.getData().get(0)
		val String description = '''Add all missing mandatory properties for element '«elementName»'«»'''
		acceptor.accept(issue, description, description, "",
			[ EObject obj, IModificationContext context |
				if (obj instanceof FDElement) {
					applyFixForElementInternal(obj, false)
				}
			])
	}

	@Fix(FDeployJavaValidator.METHOD_ARGUMENT_QUICKFIX)
	def void applyFixForMethod(Issue issue,
		IssueResolutionAcceptor acceptor) {
		val String opName = issue.getData().get(0)
		val String argumentName = issue.getData().get(1)
		val String description = '''Add missing argument '«argumentName»' for method '«opName»'«»'''
		acceptor.accept(issue, description, description, "",
			[ EObject obj, IModificationContext context |
				if (obj instanceof FDMethod) {
					applyFixForMethodInternal(obj, false, argumentName)
				}
			])
	}

	@Fix(FDeployJavaValidator.BROADCAST_ARGUMENT_QUICKFIX)
	def void applyFixForBroadcast(Issue issue,
		IssueResolutionAcceptor acceptor) {
		val String opName = issue.getData().get(0)
		val String argumentName = issue.getData().get(1)
		val String description = '''Add missing argument '«argumentName»' for broadcast '«opName»'«»'''
		acceptor.accept(issue, description, description, "",
			[ EObject obj, IModificationContext context |
				if (obj instanceof FDBroadcast) {
					applyFixForBroadcastInternal(obj, false, argumentName)
				}
			])
	}

	@Fix(FDeployJavaValidator.COMPOUND_FIELD_QUICKFIX)
	def void applyFixForCompound(Issue issue,
		IssueResolutionAcceptor acceptor) {
		val String compoundName = issue.getData().get(0)
		val String fieldName = issue.getData().get(1)
		val String description = '''Add missing field '«fieldName»' for compound '«compoundName»'«»'''
		acceptor.accept(issue, description, description, "",
			[ EObject obj, IModificationContext context |
				if (obj instanceof FDUnion) {
					applyFixForUnionInternal(obj, false, fieldName)
				} else if (obj instanceof FDStruct) {
					applyFixForStructInternal(obj, false, fieldName)
				}
			])
	}

	@Fix(FDeployJavaValidator.ENUMERATOR_ENUM_QUICKFIX)
	def void applyFixForEnumeration(Issue issue,
		IssueResolutionAcceptor acceptor) {
		val String enumeratorName = issue.getData().get(0)
		val String enumName = issue.getData().get(1)
		val String description = '''Add all enumerator '«enumName»' for enumeration '«enumeratorName»'«»'''
		acceptor.accept(issue, description, description, "",
			[ EObject obj, IModificationContext context |
				if (obj instanceof FDEnumeration) {
					applyFixForEnumerationInternal(obj, false, enumName)
				}
			])
	}

	def private void applyFixForMethodInternal(FDMethod method, boolean isRecursive, String... args) {
		if(method.getTarget().getInArgs().size() > 0 && method.getInArguments() === null) method.setInArguments(
			FDeployFactory.eINSTANCE.createFDArgumentList())
		applyFixForArgList(method.getInArguments(), method.getTarget().getInArgs(), isRecursive, args)
		if(method.getTarget().getOutArgs().size() > 0 && method.getOutArguments() === null) method.setOutArguments(
			FDeployFactory.eINSTANCE.createFDArgumentList())
		applyFixForArgList(method.getOutArguments(), method.getTarget().getOutArgs(), isRecursive, args)
	}

	def private void applyFixForBroadcastInternal(FDBroadcast broadcast, boolean isRecursive, String... args) {
		if(broadcast.getTarget().getOutArgs().size() > 0 && broadcast.getOutArguments() === null) broadcast.
			setOutArguments(FDeployFactory.eINSTANCE.createFDArgumentList())
		applyFixForArgList(broadcast.getOutArguments(), broadcast.getTarget().getOutArgs(), isRecursive, args)
	}

	def private void applyFixForArgList(FDArgumentList fdArglist, List<FArgument> fArglist, boolean isRecursive,
		String... args) {
		for (FArgument arg : fArglist) {
			if (args.length === 0 || Arrays.contains(args, arg.name)) {
				var fdArg = getArgument(fdArglist, arg)
				if (fdArg === null) {
					fdArg = FDeployFactory.eINSTANCE.createFDArgument.init
					fdArg.setTarget(arg)
					fdArglist.getArguments().add(fdArg)
				}
				if (isRecursive) {
					applyFixForElementInternal(fdArg, isRecursive)
				}
			}
		}
	}

	def private void applyFixForUnionInternal(FDUnion union, boolean isRecursive, String... fields) {
		for (FField field : union.getTarget().getElements()) {
			if (fields.length === 0 || Arrays.contains(fields, field.getName())) {
				var fdField = getField(union.getFields(), field)
				if (fdField === null) {
					fdField = FDeployFactory.eINSTANCE.createFDField.init
					fdField.setTarget(field)
					union.getFields().add(fdField)
				}
				if (isRecursive) {
					applyFixForElementInternal(fdField, isRecursive)
				}
			}
		}
	}

	def private void applyFixForStructInternal(FDStruct struct, boolean isRecursive, String... fields) {
		for (FField field : struct.getTarget().getElements()) {
			if (fields.length === 0 || Arrays.contains(fields, field.name)) {
				var fdField = getField(struct.getFields(), field)
				if (fdField === null) {
					fdField = FDeployFactory.eINSTANCE.createFDField.init
					fdField.setTarget(field)
					struct.getFields().add(fdField)
				}
				if (isRecursive) {
					applyFixForElementInternal(fdField, isRecursive)
				}
			}
		}
	}

	def private void applyFixForEnumerationInternal(FDEnumeration enumeration, boolean isRecursive, String... enumerators) {
		for (FEnumerator e : enumeration.getTarget().getEnumerators()) {
			if (enumerators.length === 0 || Arrays.contains(enumerators, e.name)) {
				var FDEnumValue fdEnum = getEnumerator(enumeration.enumerators, e)
				if (fdEnum === null) {
					fdEnum = FDeployFactory.eINSTANCE.createFDEnumValue.init
					fdEnum.setTarget(e)
					enumeration.getEnumerators().add(fdEnum)
				}
				if (isRecursive) {
					applyFixForElementInternal(fdEnum, isRecursive)
				}
			}
		}
	}

	/** 
	 * Applies quick fix for an {@link FDElement}: adds the mandatory properties and 
	 * in case of a recursive fix {@link FDMethod}s, {@link FDUnion}s, {@link FDStruct}s and {@link FDEnumeration}s 
	 * will be also fixed with nested elements/arguments.
	 * @param element the element
	 * @param isRecursive true if the fix should be applied recursively, false otherwise
	 */
	def private void applyFixForElementInternal(FDElement element, boolean isRecursive) {
		val root = FDModelUtils.getRootElement(element)
		if (root === null) {
			throw new RuntimeException('''Cannot find root element for element «element»''')
		}
		val decls = PropertyMappings.getAllPropertyDecls(root.spec, element)
		for (FDPropertyDecl decl : decls) {
			if (!hasPropertyDeclaration(element.properties.items, decl) && PropertyMappings.isMandatory(decl)) {
				var FDProperty prop = FDeployFactory.eINSTANCE.createFDProperty
				prop.setDecl(decl)
				var FDComplexValue defaultVal = DefaultValueProvider.generateDefaultValue(element, decl.type)
				if (defaultVal !== null) {
					prop.setValue(defaultVal)
					element.properties.items.add(prop)
				} else {
					// if no default value could be generated, we skip setting this property
					// note that the quickfix probably will not be successful (and the validation error will remain)
				}
			}

		}
		if (isRecursive) {
			switch(element) {
				FDMethod: applyFixForMethodInternal(element, isRecursive)
				FDBroadcast: applyFixForBroadcastInternal(element, isRecursive)
				FDUnion: applyFixForUnionInternal(element, isRecursive)
				FDStruct: applyFixForStructInternal(element, isRecursive)
				FDEnumeration: applyFixForEnumerationInternal(element, isRecursive)
				default: { } // ignore
			}
		}
	}

	/** 
	 * Provides quickfix for the given {@link FDInterface} element (this is required because a non-existing deployment element can be only created through the parent 
	 * deployment interface).
	 * <br/><br/>
	 * The type indicates the deployment element to fix (it can be the interface itself). 
	 * Fixing the issues for a non-existing deployment element can be done only by providing the appropriate type and element name. In this case the 
	 * required element will be created and supplied with the default values. In case of a deployment interface, the element name should be null, which will indicate 
	 * that all necessary elements should be added (and if required, fixed recursively).
	 * <br/><br/>
	 * If the value of the isRecursive flag is set to true, the quick fix will be applied recursively, that is, all issues with the created element(s) will be fixed too. 
	 * @param deploymentInterface the deployment interface to fix
	 * @param type the type of the {@link FDElement}
	 * @param elementName the name of the corresponding {@link FModelElement} or null in case of a deployment interface
	 * @param isRecursive true if the fix should be applied recursively, false otherwise
	 */
	def private void applyFixForInterfaceInternal(FDInterface deploymentInterface, FrancaQuickFixConstants type,
		String elementName, boolean isRecursive) {
		if (type === INTERFACE) {
			// add mandatory properties for the interface itself
			applyFixForElementInternal(deploymentInterface, true)
		}
		val Set<FDElement> elements = newHashSet
		// add all required elements for the deployment interface
		val FInterface target = deploymentInterface.target
		// attributes
		if (elementName === null) {
			for (FAttribute tc : target.attributes) {
				elements.add(getOrCreateAttribute(deploymentInterface, tc.name))
			}

		} else if (type === ATTRIBUTE) {
			elements.add(getOrCreateAttribute(deploymentInterface, elementName))
		}
		// methods
		if (elementName === null) {
			for (FMethod tc : target.methods) {
				val name = FrancaModelExtensions.getUniqueName(tc)
				elements.add(getOrCreateMethod(deploymentInterface, name))
			}

		} else if (type === METHOD) {
			elements.add(getOrCreateMethod(deploymentInterface, elementName))
		}
		// broadcasts
		if (elementName === null) {
			for (FBroadcast tc : target.broadcasts) {
				val name = FrancaModelExtensions.getUniqueName(tc)
				elements.add(getOrCreateBroadcast(deploymentInterface, name))
			}

		} else if (type === BROADCAST) {
			elements.add(getOrCreateBroadcast(deploymentInterface, elementName))
		}
		for (FType tc : target.types) {
			if (tc instanceof FArrayType) {
				if (elementName === null) {
					elements.add(getOrCreateArray(deploymentInterface, tc.name))
				} else if (type === ARRAY && tc.name.equals(elementName)) {
					elements.add(getOrCreateArray(deploymentInterface, elementName))
				}

			} else if (tc instanceof FStructType) {
				if (elementName === null) {
					elements.add(getOrCreateStruct(deploymentInterface, tc.name))
				} else if (type === STRUCT && tc.name.equals(elementName)) {
					elements.add(getOrCreateStruct(deploymentInterface, elementName))
				}

			} else if (tc instanceof FUnionType) {
				if (elementName === null) {
					elements.add(getOrCreateUnion(deploymentInterface, tc.name))
				} else if (type === UNION && tc.name.equals(elementName)) {
					elements.add(getOrCreateUnion(deploymentInterface, elementName))
				}

			} else if (tc instanceof FEnumerationType) {
				if (elementName === null) {
					elements.add(getOrCreateEnumeration(deploymentInterface, tc.name))
				} else if (type === ENUMERATION && tc.name.equals(elementName)) {
					elements.add(getOrCreateEnumeration(deploymentInterface, elementName))
				}

			} else if (tc instanceof FTypeDef) {
				if (elementName === null) {
					elements.add(getOrCreateTypedef(deploymentInterface, tc.name))
				} else if (type === TYPEDEF && tc.name.equals(elementName)) {
					elements.add(getOrCreateTypedef(deploymentInterface, elementName))
				}

			}

		}
		if (isRecursive) {
			elements.forEach[applyFixForElementInternal(isRecursive)]
		}
	}

	/** 
	 * Provides quickfix for the given {@link FDTypes} element. The elementName indicates the name of the corresponding {@link FModelElement} to add (this is the target of the {@link FDElement} that will be created).  
	 * The type will be used to identify the {@link FDElement}'s type to add.
	 * <br/><br/>
	 * If the value of the isRecursive flag is set to true, the quick fix will be applied recursively, that is, all issues with the created element will be fixed too. 
	 * @param types the types to fix
	 * @param type the type of the {@link FDElement}
	 * @param elementName the name of the corresponding {@link FModelElement}
	 * @param isRecursive true if the fix should be applied recursively, false otherwise
	 */
	def private void applyFixForTypesInternal(FDTypes types, FrancaQuickFixConstants type, String elementName, boolean isRecursive) {
		val FDElement deploymentElement = 
			switch(type) {
				case ARRAY: getOrCreateArray(types, elementName)
				case STRUCT: getOrCreateStruct(types, elementName)
				case ENUMERATION: getOrCreateEnumeration(types, elementName)
				case UNION: getOrCreateUnion(types, elementName)
				case TYPEDEF: getOrCreateTypedef(types, elementName)
				default: null
			}

		if (isRecursive && deploymentElement !== null) {
			applyFixForElementInternal(deploymentElement, isRecursive)
		}

	}

	def private static <T extends FDElement> init(T elem) {
		elem.setProperties(FDeployFactory.eINSTANCE.createFDPropertySet)
		elem
	}

}
