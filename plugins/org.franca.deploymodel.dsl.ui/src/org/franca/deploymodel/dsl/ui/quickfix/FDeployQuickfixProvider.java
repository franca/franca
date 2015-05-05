package org.franca.deploymodel.dsl.ui.quickfix;

import java.util.HashSet;
import java.util.List;
import java.util.Set;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.xtext.ui.editor.model.edit.IModificationContext;
import org.eclipse.xtext.ui.editor.model.edit.ISemanticModification;
import org.eclipse.xtext.ui.editor.quickfix.DefaultQuickfixProvider;
import org.eclipse.xtext.ui.editor.quickfix.Fix;
import org.eclipse.xtext.ui.editor.quickfix.IssueResolutionAcceptor;
import org.eclipse.xtext.util.Arrays;
import org.eclipse.xtext.validation.Issue;
import org.franca.core.franca.FArgument;
import org.franca.core.franca.FArrayType;
import org.franca.core.franca.FAttribute;
import org.franca.core.franca.FBroadcast;
import org.franca.core.franca.FEnumerationType;
import org.franca.core.franca.FEnumerator;
import org.franca.core.franca.FField;
import org.franca.core.franca.FInterface;
import org.franca.core.franca.FMethod;
import org.franca.core.franca.FModelElement;
import org.franca.core.franca.FStructType;
import org.franca.core.franca.FType;
import org.franca.core.franca.FUnionType;
import org.franca.deploymodel.core.FDModelUtils;
import org.franca.deploymodel.core.PropertyMappings;
import org.franca.deploymodel.dsl.fDeploy.FDArgument;
import org.franca.deploymodel.dsl.fDeploy.FDArgumentList;
import org.franca.deploymodel.dsl.fDeploy.FDBroadcast;
import org.franca.deploymodel.dsl.fDeploy.FDElement;
import org.franca.deploymodel.dsl.fDeploy.FDEnumValue;
import org.franca.deploymodel.dsl.fDeploy.FDEnumeration;
import org.franca.deploymodel.dsl.fDeploy.FDField;
import org.franca.deploymodel.dsl.fDeploy.FDInterface;
import org.franca.deploymodel.dsl.fDeploy.FDMethod;
import org.franca.deploymodel.dsl.fDeploy.FDProperty;
import org.franca.deploymodel.dsl.fDeploy.FDPropertyDecl;
import org.franca.deploymodel.dsl.fDeploy.FDRootElement;
import org.franca.deploymodel.dsl.fDeploy.FDStruct;
import org.franca.deploymodel.dsl.fDeploy.FDTypes;
import org.franca.deploymodel.dsl.fDeploy.FDUnion;
import org.franca.deploymodel.dsl.fDeploy.FDeployFactory;
import org.franca.deploymodel.dsl.validation.FDeployJavaValidator;
import org.franca.deploymodel.dsl.validation.FrancaQuickFixConstants;

/**
 * A collection of quick fixes for Franca Deployment Definitions.
 * 
 * @author Tamas Szabo (itemis AG)
 *
 */
public class FDeployQuickfixProvider extends DefaultQuickfixProvider {

	@Fix(FDeployJavaValidator.UPPERCASE_PROPERTYNAME_QUICKFIX)
	public void setUppercasePropertyName(final Issue issue,
			IssueResolutionAcceptor acceptor) {
		final String data = issue.getData()[0];
		acceptor.accept(issue, "Set first character to uppercase for property "
				+ data,
				"Set first character to uppercase for property " + data, "",
				new ISemanticModification() {
					public void apply(EObject obj, IModificationContext context) {
						if (obj instanceof FDPropertyDecl) {
							FDPropertyDecl elem = (FDPropertyDecl) obj;
							if (((FDPropertyDecl) obj).getType() != null) {
								String newName = String.format("%c%s",
										Character.toUpperCase(elem.getName()
												.charAt(0)), (elem.getName()
												.length() == 1 ? "" : elem
												.getName().substring(1)));
								elem.setName(newName);
							}
						}
					}
				});
	}
	
	@Fix(FDeployJavaValidator.DEPLOYMENT_ELEMENT_RECURSIVE_QUICKFIX)
	public void applyRecursiveFix(final Issue issue, final IssueResolutionAcceptor acceptor) {
		final FrancaQuickFixConstants type = FrancaQuickFixConstants.valueOf(issue.getData()[1]);
		final String elementName = (type == FrancaQuickFixConstants.INTERFACE) ? null : issue.getData()[0];
		final String description = "Fix all issues for element '" + issue.getData()[0]	+ "'";

		acceptor.accept(issue, description, description, "",
				new ISemanticModification() {
					@Override
					public void apply(EObject obj, IModificationContext context) {
						if (obj instanceof FDInterface) {
							applyFixForInterfaceInternal((FDInterface) obj, type, elementName, true);
						}
						else if (obj instanceof FDTypes) {
							applyFixForTypesInternal((FDTypes) obj, type, elementName, true);
						}
						else if (obj instanceof FDElement) {
							applyFixForElementInternal((FDElement) obj, true);
						}
					}
		});		
	}
	
	@Fix(FDeployJavaValidator.DEPLOYMENT_ELEMENT_QUICKFIX)
	public void applyFixForInterface(final Issue issue, final IssueResolutionAcceptor acceptor) {
		final String elementName = issue.getData()[0];
		final FrancaQuickFixConstants type = FrancaQuickFixConstants.valueOf(issue.getData()[1]);
		final String description = "Add missing " + type.toString().toLowerCase() + " '" + elementName	+ "'";

		acceptor.accept(issue, description, description, "",
				new ISemanticModification() {
					@Override
					public void apply(EObject obj, IModificationContext context) {
						if (obj instanceof FDInterface) {
							FDInterface deploymentInterface = (FDInterface) obj;
							applyFixForInterfaceInternal(deploymentInterface, type, elementName, false);
						}
						else if (obj instanceof FDTypes) {
							applyFixForTypesInternal((FDTypes) obj, type, elementName, false); 			
						}
					}
		});		
	}
	
	@Fix(FDeployJavaValidator.MANDATORY_PROPERTY_QUICKFIX)
	public void applyFixForElement(final Issue issue, final IssueResolutionAcceptor acceptor) {
		final String elementName = issue.getData()[0];
		final String description = "Add all missing mandatory properties for element '"+elementName+"'";
		acceptor.accept(issue, description, description, "", new ISemanticModification() {
					public void apply(EObject obj, IModificationContext context) {
						if (obj instanceof FDElement) {
							FDElement elem = (FDElement) obj;
							applyFixForElementInternal(elem, false);
						}
					}
				});
	}
	
	@Fix(FDeployJavaValidator.METHOD_ARGUMENT_QUICKFIX)
	public void applyFixForMethod(final Issue issue, final IssueResolutionAcceptor acceptor) {
		final String opName = issue.getData()[0];
		final String argumentName = issue.getData()[1];
		final String description = "Add missing argument '"+argumentName + "' for method '"+opName+"'";
		acceptor.accept(issue, description, description, "",
				new ISemanticModification() {
					@Override
					public void apply(EObject obj, IModificationContext context) {
						if (obj instanceof FDMethod) {
							applyFixForMethodInternal((FDMethod) obj, false, argumentName);
						}
					}
				});
	}
	
	@Fix(FDeployJavaValidator.BROADCAST_ARGUMENT_QUICKFIX)
	public void applyFixForBroadcast(final Issue issue, final IssueResolutionAcceptor acceptor) {
		final String opName = issue.getData()[0];
		final String argumentName = issue.getData()[1];
		final String description = "Add missing argument '"+argumentName + "' for broadcast '"+opName+"'";
		acceptor.accept(issue, description, description, "",
				new ISemanticModification() {
					@Override
					public void apply(EObject obj, IModificationContext context) {
						if (obj instanceof FDBroadcast) {
							applyFixForBroadcastInternal((FDBroadcast) obj, false, argumentName);
						}
					}
				});
	}
	
	@Fix(FDeployJavaValidator.COMPOUND_FIELD_QUICKFIX)
	public void applyFixForCompound(final Issue issue, final IssueResolutionAcceptor acceptor) {
		final String compoundName = issue.getData()[0];
		final String fieldName = issue.getData()[1];
		final String description = "Add missing field '" + fieldName + "' for compound '"+compoundName+"'";
		acceptor.accept(issue, description, description, "",
				new ISemanticModification() {
					@Override
					public void apply(EObject obj, IModificationContext context) {
						if (obj instanceof FDUnion) {
							applyFixForUnionInternal((FDUnion) obj, false, fieldName);
						}
						else if (obj instanceof FDStruct) {
							applyFixForStructInternal((FDStruct) obj, false, fieldName);
						}
					}
				});
	}
	
	@Fix(FDeployJavaValidator.ENUMERATOR_ENUM_QUICKFIX)
	public void applyFixForEnumeration(final Issue issue, final IssueResolutionAcceptor acceptor) {
		final String enumeratorName = issue.getData()[0];
		final String enumName = issue.getData()[1];
		final String description = "Add all enumerator '" + enumName + "' for enumeration '"+enumeratorName+"'";
		acceptor.accept(issue, description, description, "",
				new ISemanticModification() {
					@Override
					public void apply(EObject obj, IModificationContext context) {
						if (obj instanceof FDMethod) {
							applyFixForEnumerationInternal((FDEnumeration) obj, false, enumName);
						}
					}
				});
	}
	
	private void applyFixForMethodInternal(final FDMethod method, final boolean isRecursive, String... args) {
		if (method.getTarget().getInArgs().size()>0 && method.getInArguments()==null)
			method.setInArguments(FDeployFactory.eINSTANCE.createFDArgumentList());
		applyFixForArgList(method.getInArguments(), method.getTarget().getInArgs(), isRecursive, args);

		if (method.getTarget().getOutArgs().size()>0 && method.getOutArguments()==null)
			method.setOutArguments(FDeployFactory.eINSTANCE.createFDArgumentList());
		applyFixForArgList(method.getOutArguments(), method.getTarget().getOutArgs(), isRecursive, args);
	}
	
	private void applyFixForBroadcastInternal(final FDBroadcast broadcast, final boolean isRecursive, String... args) {
		if (broadcast.getTarget().getOutArgs().size()>0 && broadcast.getOutArguments()==null)
			broadcast.setOutArguments(FDeployFactory.eINSTANCE.createFDArgumentList());
		applyFixForArgList(broadcast.getOutArguments(), broadcast.getTarget().getOutArgs(), isRecursive, args);
	}

	private void applyFixForArgList(FDArgumentList fdArglist, List<FArgument> fArglist, final boolean isRecursive, String... args) {
		if (fArglist.size() > 0) {
			for (FArgument arg : fArglist) {
				if (args.length == 0 || Arrays.contains(args, arg.getName())) {
					FDArgument fdArg = FDeployQuickfixProviderUtil.getArgument(fdArglist, arg);
					if (fdArg == null) {
						fdArg = FDeployFactory.eINSTANCE.createFDArgument();
						fdArg.setTarget(arg);
						fdArglist.getArguments().add(fdArg);
					}
					if (isRecursive) {
						applyFixForElementInternal(fdArg, isRecursive);
					}
				}
			}
		}
	}
 	
	private void applyFixForUnionInternal(final FDUnion union, final boolean isRecursive, String... fields) {
		if (union.getTarget().getElements().size() > 0) {
			for (FField field : union.getTarget().getElements()) {
				if (fields.length == 0 || Arrays.contains(fields, field.getName())) {
					FDField fdField = FDeployQuickfixProviderUtil.getField(union.getFields(), field);
					if (fdField == null) {
						fdField = FDeployFactory.eINSTANCE.createFDField();
						fdField.setTarget(field);
						union.getFields().add(fdField);
					}
					if (isRecursive) {
						applyFixForElementInternal(fdField, isRecursive);
					}
				}
			}
		}
	}
	
	private void applyFixForStructInternal(final FDStruct struct, final boolean isRecursive, String... fields) {
		if (struct.getTarget().getElements().size() > 0) {
			for (FField field : struct.getTarget().getElements()) {
				if (fields.length == 0 || Arrays.contains(fields, field.getName())) {
					FDField fdField = FDeployQuickfixProviderUtil.getField(struct.getFields(), field);
					if (fdField == null) {
						fdField = FDeployFactory.eINSTANCE.createFDField();
						fdField.setTarget(field);
						struct.getFields().add(fdField);
					}
					if (isRecursive) {
						applyFixForElementInternal(fdField, isRecursive);
					}
				}
			}
		}
	}
	
	private void applyFixForEnumerationInternal(final FDEnumeration enumeration, final boolean isRecursive, String... enumerators) {
		if (enumeration.getTarget().getEnumerators().size() > 0) {
			for (FEnumerator e : enumeration.getTarget().getEnumerators()) {
				if (enumerators.length == 0 || Arrays.contains(enumerators, e.getName())) {
					FDEnumValue fdEnum = FDeployQuickfixProviderUtil.getEnumerator(enumeration.getEnumerators(), e);
					if (fdEnum == null) {
						fdEnum = FDeployFactory.eINSTANCE.createFDEnumValue();
						fdEnum.setTarget(e);
						enumeration.getEnumerators().add(fdEnum);
					}
					if (isRecursive) {
						applyFixForElementInternal(fdEnum, isRecursive);
					}
				}
			}
		}
	}
	
	/**
	 * Applies quick fix for an {@link FDElement}: adds the mandatory properties and 
	 * in case of a recursive fix {@link FDMethod}s, {@link FDUnion}s, {@link FDStruct}s and {@link FDEnumeration}s 
	 * will be also fixed with nested elements/arguments.
	 * 
	 * @param element the element
	 * @param isRecursive true if the fix should be applied recursively, false otherwise
	 */
	private void applyFixForElementInternal(final FDElement element, final boolean isRecursive) {
		FDRootElement root = FDModelUtils.getRootElement(element);
		List<FDPropertyDecl> decls = PropertyMappings.getAllPropertyDecls(root.getSpec(), element);
		for (FDPropertyDecl decl : decls) {
			if (! FDeployQuickfixProviderUtil.hasPropertyDeclaration(
					element.getProperties().getItems(), decl) && PropertyMappings.isMandatory(decl)) {
				FDProperty prop = FDeployFactory.eINSTANCE.createFDProperty();
				prop.setDecl(decl);
				prop.setValue(FDeployQuickfixProviderUtil.generateDefaultValue(element, decl.getType()));
				element.getProperties().getItems().add(prop);
			}
		}
		
		if (isRecursive) {
			if (element instanceof FDMethod) {
				applyFixForMethodInternal((FDMethod) element, isRecursive);
			}
			if (element instanceof FDBroadcast) {
				applyFixForBroadcastInternal((FDBroadcast) element, isRecursive);
			}
			else if (element instanceof FDUnion) {
				applyFixForUnionInternal((FDUnion) element, isRecursive);
			}
			else if (element instanceof FDStruct) {
				applyFixForStructInternal((FDStruct) element, isRecursive);
			}
			else if (element instanceof FDEnumeration) {
				applyFixForEnumerationInternal((FDEnumeration) element, isRecursive);		
			}
		}
	}

	/**
	 * Provides quickfix for the given {@link FDInterface} element (this is required because a non-existing deployment element can be only created through the parent 
	 * deployment interface).
	 * 
	 * <br/><br/>
	 * The type indicates the deployment element to fix (it can be the interface itself). 
	 * Fixing the issues for a non-existing deployment element can be done only by providing the appropriate type and element name. In this case the 
	 * required element will be created and supplied with the default values. In case of a deployment interface, the element name should be null, which will indicate 
	 * that all necessary elements should be added (and if required, fixed recursively).
	 * 
	 * <br/><br/>
	 * If the value of the isRecursive flag is set to true, the quick fix will be applied recursively, that is, all issues with the created element(s) will be fixed too. 
	 * 
	 * @param deploymentInterface the deployment interface to fix
	 * @param type the type of the {@link FDElement}
	 * @param elementName the name of the corresponding {@link FModelElement} or null in case of a deployment interface
	 * @param isRecursive true if the fix should be applied recursively, false otherwise
	 */
	private void applyFixForInterfaceInternal(final FDInterface deploymentInterface, final FrancaQuickFixConstants type, String elementName, final boolean isRecursive) {
		if (type == FrancaQuickFixConstants.INTERFACE) {
			//add mandatory properties for the interface itself
			applyFixForElementInternal(deploymentInterface, true);
		}
		
		Set<FDElement> elements = new HashSet<FDElement>();
		
		//add all required elements for the deployment interface
		FInterface target = deploymentInterface.getTarget();
		
		//attributes
		if (elementName == null) {
			for(FAttribute tc : target.getAttributes()) {
				elements.add(FDeployQuickfixProviderUtil.getOrCreateAttribute(deploymentInterface, tc.getName()));
			}
		}
		else if (type == FrancaQuickFixConstants.ATTRIBUTE) {
			elements.add(FDeployQuickfixProviderUtil.getOrCreateAttribute(deploymentInterface, elementName));
		}
		
		//methods
		if (elementName == null) {
			for(FMethod tc : target.getMethods()) {
				elements.add(FDeployQuickfixProviderUtil.getOrCreateMethod(deploymentInterface, tc.getName()));
			}
		}
		else if (type == FrancaQuickFixConstants.METHOD) {
			elements.add(FDeployQuickfixProviderUtil.getOrCreateMethod(deploymentInterface, elementName));
		}

		//broadcasts
		if (elementName == null) {
			for(FBroadcast tc : target.getBroadcasts()) {
				elements.add(FDeployQuickfixProviderUtil.getOrCreateBroadcast(deploymentInterface, tc.getName()));
			}
		}
		else if (type == FrancaQuickFixConstants.BROADCAST) {
			elements.add(FDeployQuickfixProviderUtil.getOrCreateBroadcast(deploymentInterface, elementName));
		}
		
		for(FType tc : target.getTypes()) {
			if (tc instanceof FArrayType) {
				if (elementName == null) {
					elements.add(FDeployQuickfixProviderUtil.getOrCreateArray(deploymentInterface, tc.getName()));
				}
				else if (type == FrancaQuickFixConstants.ARRAY && tc.getName().equals(elementName)) {
					elements.add(FDeployQuickfixProviderUtil.getOrCreateArray(deploymentInterface, elementName));
				}
			} else if (tc instanceof FStructType) {
				if (elementName == null) {
					elements.add(FDeployQuickfixProviderUtil.getOrCreateStruct(deploymentInterface, tc.getName()));
				}
				else if (type == FrancaQuickFixConstants.STRUCT && tc.getName().equals(elementName)) {
					elements.add(FDeployQuickfixProviderUtil.getOrCreateStruct(deploymentInterface, elementName));
				}
			} else if (tc instanceof FUnionType) {
				if (elementName == null) {
					elements.add(FDeployQuickfixProviderUtil.getOrCreateUnion(deploymentInterface, tc.getName()));
				}
				else if (type == FrancaQuickFixConstants.UNION && tc.getName().equals(elementName)) {
					elements.add(FDeployQuickfixProviderUtil.getOrCreateUnion(deploymentInterface, elementName));
				}
			} else if (tc instanceof FEnumerationType) {
				if (elementName == null) {
					elements.add(FDeployQuickfixProviderUtil.getOrCreateEnumeration(deploymentInterface, tc.getName()));
				}
				else if (type == FrancaQuickFixConstants.ENUMERATION && tc.getName().equals(elementName)) {
					elements.add(FDeployQuickfixProviderUtil.getOrCreateEnumeration(deploymentInterface, elementName));
				}
			}
		}

		if (isRecursive) {
			for (FDElement element : elements) {
				applyFixForElementInternal(element, isRecursive);
			}
		}
	}
	
	/**
	 * Provides quickfix for the given {@link FDTypes} element. The elementName indicates the name of the corresponding {@link FModelElement} to add (this is the target of the 
	 * {@link FDElement} that will be created).  
	 * The type will be used to identify the {@link FDElement}'s type to add.
	 * <br/><br/>
	 * If the value of the isRecursive flag is set to true, the quick fix will be applied recursively, that is, all issues with the created element will be fixed too. 
	 * 
	 * @param types the types to fix
	 * @param type the type of the {@link FDElement}
	 * @param elementName the name of the corresponding {@link FModelElement}
	 * @param isRecursive true if the fix should be applied recursively, false otherwise
	 */
	private void applyFixForTypesInternal(final FDTypes types, final FrancaQuickFixConstants type, String elementName, final boolean isRecursive) {
		FDElement deploymentElement = null;

		if (type == FrancaQuickFixConstants.ARRAY) {
			deploymentElement = FDeployQuickfixProviderUtil.getOrCreateArray(types, elementName);
		} 
		else if (type == FrancaQuickFixConstants.STRUCT) {
			deploymentElement = FDeployQuickfixProviderUtil.getOrCreateStruct(types, elementName);
		} 
		else if (type == FrancaQuickFixConstants.ENUMERATION) {
			deploymentElement = FDeployQuickfixProviderUtil.getOrCreateEnumeration(types, elementName);
		} 
		else if (type == FrancaQuickFixConstants.UNION) {
			deploymentElement = FDeployQuickfixProviderUtil.getOrCreateUnion(types, elementName);
		}
		if (isRecursive && deploymentElement != null) {
			applyFixForElementInternal(deploymentElement, isRecursive);
		}

	}
	
}
