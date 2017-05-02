package org.franca.deploymodel.dsl.ui.quickfix

import java.util.HashSet
import java.util.List
import java.util.Set
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.ui.editor.model.edit.IModificationContext
import org.eclipse.xtext.ui.editor.model.edit.ISemanticModification
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
import org.franca.deploymodel.dsl.fDeploy.FDArgument
import org.franca.deploymodel.dsl.fDeploy.FDArgumentList
import org.franca.deploymodel.dsl.fDeploy.FDBroadcast
import org.franca.deploymodel.dsl.fDeploy.FDComplexValue
import org.franca.deploymodel.dsl.fDeploy.FDElement
import org.franca.deploymodel.dsl.fDeploy.FDEnumValue
import org.franca.deploymodel.dsl.fDeploy.FDEnumeration
import org.franca.deploymodel.dsl.fDeploy.FDField
import org.franca.deploymodel.dsl.fDeploy.FDInterface
import org.franca.deploymodel.dsl.fDeploy.FDMethod
import org.franca.deploymodel.dsl.fDeploy.FDProperty
import org.franca.deploymodel.dsl.fDeploy.FDPropertyDecl
import org.franca.deploymodel.dsl.fDeploy.FDRootElement
import org.franca.deploymodel.dsl.fDeploy.FDStruct
import org.franca.deploymodel.dsl.fDeploy.FDTypes
import org.franca.deploymodel.dsl.fDeploy.FDUnion
import org.franca.deploymodel.dsl.fDeploy.FDeployFactory
import org.franca.deploymodel.dsl.validation.FDeployJavaValidator
import org.franca.deploymodel.dsl.validation.FrancaQuickFixConstants

/** 
 * A collection of quick fixes for Franca Deployment Definitions.
 * 
 * @author Tamas Szabo (itemis AG)
 */
class FDeployQuickfixProvider extends DefaultQuickfixProvider {
	@Fix(FDeployJavaValidator.UPPERCASE_PROPERTYNAME_QUICKFIX)
	def void setUppercasePropertyName(Issue issue,
		IssueResolutionAcceptor acceptor) {
		val String data = issue.getData().get(0)
		acceptor.
			accept(
				issue, '''Set first character to uppercase for property «data»''', '''Set first character to uppercase for property «data»''',
				"", [ EObject obj, IModificationContext context |
					if (obj instanceof FDPropertyDecl) {
						var FDPropertyDecl elem = obj as FDPropertyDecl
						if ((obj as FDPropertyDecl).getType() !== null) {
							var String newName = String.format("%c%s", Character.toUpperCase(elem.getName().charAt(0)),(
								if(elem.getName().length() === 1) "" else elem.getName().substring(1) ))
							elem.setName(newName)
						}

					}
				])
	}

	@Fix(FDeployJavaValidator.DEPLOYMENT_ELEMENT_RECURSIVE_QUICKFIX)
	def void applyRecursiveFix(Issue issue,
		IssueResolutionAcceptor acceptor) {
		val FrancaQuickFixConstants type = FrancaQuickFixConstants.valueOf(issue.getData().get(1))
		val String elementName = if((type === FrancaQuickFixConstants.INTERFACE)) null else issue.getData().get(0)
		val String description = '''Fix all issues for element '«»«issue.getData().get(0)»'«»'''
		acceptor.accept(issue, description, description, "", [ EObject obj, IModificationContext context |
			if (obj instanceof FDInterface) {
				applyFixForInterfaceInternal(obj as FDInterface, type, elementName, true)
			} else if (obj instanceof FDTypes) {
				applyFixForTypesInternal(obj as FDTypes, type, elementName, true)
			} else if (obj instanceof FDElement) {
				applyFixForElementInternal(obj as FDElement, true)
			}
		])
	}

	@Fix(FDeployJavaValidator.DEPLOYMENT_ELEMENT_QUICKFIX)
	def void applyFixForInterface(Issue issue,
		IssueResolutionAcceptor acceptor) {
		val String elementName = issue.getData().get(0)
		val FrancaQuickFixConstants type = FrancaQuickFixConstants.valueOf(issue.getData().get(1))
		val String description = '''Add missing «type.toString().toLowerCase()» '«»«elementName»'«»'''
		acceptor.accept(issue, description, description, "", [ EObject obj, IModificationContext context |
			if (obj instanceof FDInterface) {
				var FDInterface deploymentInterface = obj as FDInterface
				applyFixForInterfaceInternal(deploymentInterface, type, elementName, false)
			} else if (obj instanceof FDTypes) {
				applyFixForTypesInternal(obj as FDTypes, type, elementName, false)
			}
		])
	}

	@Fix(FDeployJavaValidator.MANDATORY_PROPERTY_QUICKFIX)
	def void applyFixForElement(Issue issue,
		IssueResolutionAcceptor acceptor) {
		val String elementName = issue.getData().get(0)
		val String description = '''Add all missing mandatory properties for element '«»«elementName»'«»'''
		acceptor.accept(issue, description, description, "", [ EObject obj, IModificationContext context |
			if (obj instanceof FDElement) {
				var FDElement elem = obj as FDElement
				applyFixForElementInternal(elem, false)
			}
		])
	}

	@Fix(FDeployJavaValidator.METHOD_ARGUMENT_QUICKFIX)
	def void applyFixForMethod(Issue issue,
		IssueResolutionAcceptor acceptor) {
		val String opName = issue.getData().get(0)
		val String argumentName = issue.getData().get(1)
		val String description = '''Add missing argument '«»«argumentName»' for method '«»«opName»'«»'''
		acceptor.accept(issue, description, description, "", [ EObject obj, IModificationContext context |
			if (obj instanceof FDMethod) {
				applyFixForMethodInternal(obj as FDMethod, false, argumentName)
			}
		])
	}

	@Fix(FDeployJavaValidator.BROADCAST_ARGUMENT_QUICKFIX)
	def void applyFixForBroadcast(Issue issue,
		IssueResolutionAcceptor acceptor) {
		val String opName = issue.getData().get(0)
		val String argumentName = issue.getData().get(1)
		val String description = '''Add missing argument '«»«argumentName»' for broadcast '«»«opName»'«»'''
		acceptor.accept(issue, description, description, "", [ EObject obj, IModificationContext context |
			if (obj instanceof FDBroadcast) {
				applyFixForBroadcastInternal(obj as FDBroadcast, false, argumentName)
			}
		])
	}

	@Fix(FDeployJavaValidator.COMPOUND_FIELD_QUICKFIX)
	def void applyFixForCompound(Issue issue,
		IssueResolutionAcceptor acceptor) {
		val String compoundName = issue.getData().get(0)
		val String fieldName = issue.getData().get(1)
		val String description = '''Add missing field '«»«fieldName»' for compound '«»«compoundName»'«»'''
		acceptor.accept(issue, description, description, "", [ EObject obj, IModificationContext context |
			if (obj instanceof FDUnion) {
				applyFixForUnionInternal(obj as FDUnion, false, fieldName)
			} else if (obj instanceof FDStruct) {
				applyFixForStructInternal(obj as FDStruct, false, fieldName)
			}
		])
	}

	@Fix(FDeployJavaValidator.ENUMERATOR_ENUM_QUICKFIX)
	def void applyFixForEnumeration(Issue issue,
		IssueResolutionAcceptor acceptor) {
		val String enumeratorName = issue.getData().get(0)
		val String enumName = issue.getData().get(1)
		val String description = '''Add all enumerator '«»«enumName»' for enumeration '«»«enumeratorName»'«»'''
		acceptor.accept(issue, description, description, "", [ EObject obj, IModificationContext context |
			if (obj instanceof FDMethod) {
				applyFixForEnumerationInternal(obj as FDEnumeration, false, enumName)
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
		if (fArglist.size() > 0) {
			for (FArgument arg : fArglist) {
				if (args.length === 0 || Arrays.contains(args, arg.getName())) {
					var FDArgument fdArg = FDeployQuickfixProviderUtil.getArgument(fdArglist, arg)
					if (fdArg === null) {
						fdArg = FDeployFactory.eINSTANCE.createFDArgument()
						init(fdArg)
						fdArg.setTarget(arg)
						fdArglist.getArguments().add(fdArg)
					}
					if (isRecursive) {
						applyFixForElementInternal(fdArg, isRecursive)
					}

				}

			}

		}

	}

	def private void applyFixForUnionInternal(FDUnion union, boolean isRecursive, String... fields) {
		if (union.getTarget().getElements().size() > 0) {
			for (FField field : union.getTarget().getElements()) {
				if (fields.length === 0 || Arrays.contains(fields, field.getName())) {
					var FDField fdField = FDeployQuickfixProviderUtil.getField(union.getFields(), field)
					if (fdField === null) {
						fdField = FDeployFactory.eINSTANCE.createFDField()
						init(fdField)
						fdField.setTarget(field)
						union.getFields().add(fdField)
					}
					if (isRecursive) {
						applyFixForElementInternal(fdField, isRecursive)
					}

				}

			}

		}

	}

	def private void applyFixForStructInternal(FDStruct struct, boolean isRecursive, String... fields) {
		if (struct.getTarget().getElements().size() > 0) {
			for (FField field : struct.getTarget().getElements()) {
				if (fields.length === 0 || Arrays.contains(fields, field.getName())) {
					var FDField fdField = FDeployQuickfixProviderUtil.getField(struct.getFields(), field)
					if (fdField === null) {
						fdField = FDeployFactory.eINSTANCE.createFDField()
						init(fdField)
						fdField.setTarget(field)
						struct.getFields().add(fdField)
					}
					if (isRecursive) {
						applyFixForElementInternal(fdField, isRecursive)
					}

				}

			}

		}

	}

	def private void applyFixForEnumerationInternal(FDEnumeration enumeration, boolean isRecursive,
		String... enumerators) {
		if (enumeration.getTarget().getEnumerators().size() > 0) {
			for (FEnumerator e : enumeration.getTarget().getEnumerators()) {
				if (enumerators.length === 0 || Arrays.contains(enumerators, e.getName())) {
					var FDEnumValue fdEnum = FDeployQuickfixProviderUtil.getEnumerator(enumeration.getEnumerators(), e)
					if (fdEnum === null) {
						fdEnum = FDeployFactory.eINSTANCE.createFDEnumValue()
						init(fdEnum)
						fdEnum.setTarget(e)
						enumeration.getEnumerators().add(fdEnum)
					}
					if (isRecursive) {
						applyFixForElementInternal(fdEnum, isRecursive)
					}

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
		var FDRootElement root = FDModelUtils.getRootElement(element)
		if (root === null) {
			throw new RuntimeException('''Cannot find root element for element «element»''')
		}
		var List<FDPropertyDecl> decls = PropertyMappings.getAllPropertyDecls(root.getSpec(), element)
		for (FDPropertyDecl decl : decls) {
			if (!FDeployQuickfixProviderUtil.hasPropertyDeclaration(element.getProperties().getItems(), decl) &&
				PropertyMappings.isMandatory(decl)) {
				var FDProperty prop = FDeployFactory.eINSTANCE.createFDProperty()
				prop.setDecl(decl)
				var FDComplexValue defaultVal = DefaultValueProvider.generateDefaultValue(element, decl.getType())
				if (defaultVal !== null) {
					prop.setValue(defaultVal)
					element.getProperties().getItems().add(prop)
				} else {
					// if no default value could be generated, we skip setting this property
					// note that the quickfix probably will not be successful (and the validation error will remain)
				}
			}

		}
		if (isRecursive) {
			if (element instanceof FDMethod) {
				applyFixForMethodInternal(element as FDMethod, isRecursive)
			}
			if (element instanceof FDBroadcast) {
				applyFixForBroadcastInternal(element as FDBroadcast, isRecursive)
			} else if (element instanceof FDUnion) {
				applyFixForUnionInternal(element as FDUnion, isRecursive)
			} else if (element instanceof FDStruct) {
				applyFixForStructInternal(element as FDStruct, isRecursive)
			} else if (element instanceof FDEnumeration) {
				applyFixForEnumerationInternal(element as FDEnumeration, isRecursive)
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
		if (type === FrancaQuickFixConstants.INTERFACE) {
			// add mandatory properties for the interface itself
			applyFixForElementInternal(deploymentInterface, true)
		}
		var Set<FDElement> elements = new HashSet<FDElement>()
		// add all required elements for the deployment interface
		var FInterface target = deploymentInterface.getTarget()
		// attributes
		if (elementName === null) {
			for (FAttribute tc : target.getAttributes()) {
				elements.add(FDeployQuickfixProviderUtil.getOrCreateAttribute(deploymentInterface, tc.getName()))
			}

		} else if (type === FrancaQuickFixConstants.ATTRIBUTE) {
			elements.add(FDeployQuickfixProviderUtil.getOrCreateAttribute(deploymentInterface, elementName))
		}
		// methods
		if (elementName === null) {
			for (FMethod tc : target.getMethods()) {
				var String name = FrancaModelExtensions.getUniqueName(tc)
				elements.add(FDeployQuickfixProviderUtil.getOrCreateMethod(deploymentInterface, name))
			}

		} else if (type === FrancaQuickFixConstants.METHOD) {
			elements.add(FDeployQuickfixProviderUtil.getOrCreateMethod(deploymentInterface, elementName))
		}
		// broadcasts
		if (elementName === null) {
			for (FBroadcast tc : target.getBroadcasts()) {
				var String name = FrancaModelExtensions.getUniqueName(tc)
				elements.add(FDeployQuickfixProviderUtil.getOrCreateBroadcast(deploymentInterface, name))
			}

		} else if (type === FrancaQuickFixConstants.BROADCAST) {
			elements.add(FDeployQuickfixProviderUtil.getOrCreateBroadcast(deploymentInterface, elementName))
		}
		for (FType tc : target.getTypes()) {
			if (tc instanceof FArrayType) {
				if (elementName === null) {
					elements.add(FDeployQuickfixProviderUtil.getOrCreateArray(deploymentInterface, tc.getName()))
				} else if (type === FrancaQuickFixConstants.ARRAY && tc.getName().equals(elementName)) {
					elements.add(FDeployQuickfixProviderUtil.getOrCreateArray(deploymentInterface, elementName))
				}

			} else if (tc instanceof FStructType) {
				if (elementName === null) {
					elements.add(FDeployQuickfixProviderUtil.getOrCreateStruct(deploymentInterface, tc.getName()))
				} else if (type === FrancaQuickFixConstants.STRUCT && tc.getName().equals(elementName)) {
					elements.add(FDeployQuickfixProviderUtil.getOrCreateStruct(deploymentInterface, elementName))
				}

			} else if (tc instanceof FUnionType) {
				if (elementName === null) {
					elements.add(FDeployQuickfixProviderUtil.getOrCreateUnion(deploymentInterface, tc.getName()))
				} else if (type === FrancaQuickFixConstants.UNION && tc.getName().equals(elementName)) {
					elements.add(FDeployQuickfixProviderUtil.getOrCreateUnion(deploymentInterface, elementName))
				}

			} else if (tc instanceof FEnumerationType) {
				if (elementName === null) {
					elements.add(FDeployQuickfixProviderUtil.getOrCreateEnumeration(deploymentInterface, tc.getName()))
				} else if (type === FrancaQuickFixConstants.ENUMERATION && tc.getName().equals(elementName)) {
					elements.add(FDeployQuickfixProviderUtil.getOrCreateEnumeration(deploymentInterface, elementName))
				}

			} else if (tc instanceof FTypeDef) {
				if (elementName === null) {
					elements.add(FDeployQuickfixProviderUtil.getOrCreateTypedef(deploymentInterface, tc.getName()))
				} else if (type === FrancaQuickFixConstants.TYPEDEF && tc.getName().equals(elementName)) {
					elements.add(FDeployQuickfixProviderUtil.getOrCreateTypedef(deploymentInterface, elementName))
				}

			}

		}
		if (isRecursive) {
			for (FDElement element : elements) {
				applyFixForElementInternal(element, isRecursive)
			}

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
	def private void applyFixForTypesInternal(FDTypes types, FrancaQuickFixConstants type, String elementName,
		boolean isRecursive) {
		var FDElement deploymentElement = null
		if (type === FrancaQuickFixConstants.ARRAY) {
			deploymentElement = FDeployQuickfixProviderUtil.getOrCreateArray(types, elementName)
		} else if (type === FrancaQuickFixConstants.STRUCT) {
			deploymentElement = FDeployQuickfixProviderUtil.getOrCreateStruct(types, elementName)
		} else if (type === FrancaQuickFixConstants.ENUMERATION) {
			deploymentElement = FDeployQuickfixProviderUtil.getOrCreateEnumeration(types, elementName)
		} else if (type === FrancaQuickFixConstants.UNION) {
			deploymentElement = FDeployQuickfixProviderUtil.getOrCreateUnion(types, elementName)
		} else if (type === FrancaQuickFixConstants.TYPEDEF) {
			deploymentElement = FDeployQuickfixProviderUtil.getOrCreateTypedef(types, elementName)
		}
		if (isRecursive && deploymentElement !== null) {
			applyFixForElementInternal(deploymentElement, isRecursive)
		}

	}

	def private static void init(FDElement elem) {
		elem.setProperties(FDeployFactory.eINSTANCE.createFDPropertySet())
	}

}
