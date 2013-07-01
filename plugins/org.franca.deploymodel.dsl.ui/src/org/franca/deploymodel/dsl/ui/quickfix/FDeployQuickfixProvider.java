package org.franca.deploymodel.dsl.ui.quickfix;

import java.util.List;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.xtext.ui.editor.model.edit.IModificationContext;
import org.eclipse.xtext.ui.editor.model.edit.ISemanticModification;
import org.eclipse.xtext.ui.editor.quickfix.DefaultQuickfixProvider;
import org.eclipse.xtext.ui.editor.quickfix.Fix;
import org.eclipse.xtext.ui.editor.quickfix.IssueResolutionAcceptor;
import org.eclipse.xtext.util.Arrays;
import org.eclipse.xtext.validation.Issue;
import org.franca.core.franca.FArgument;
import org.franca.core.franca.FEnumerator;
import org.franca.core.franca.FField;
import org.franca.deploymodel.core.FDModelUtils;
import org.franca.deploymodel.core.PropertyMappings;
import org.franca.deploymodel.dsl.fDeploy.FDArgument;
import org.franca.deploymodel.dsl.fDeploy.FDElement;
import org.franca.deploymodel.dsl.fDeploy.FDEnumValue;
import org.franca.deploymodel.dsl.fDeploy.FDEnumeration;
import org.franca.deploymodel.dsl.fDeploy.FDField;
import org.franca.deploymodel.dsl.fDeploy.FDInterface;
import org.franca.deploymodel.dsl.fDeploy.FDMethod;
import org.franca.deploymodel.dsl.fDeploy.FDProperty;
import org.franca.deploymodel.dsl.fDeploy.FDPropertyDecl;
import org.franca.deploymodel.dsl.fDeploy.FDStruct;
import org.franca.deploymodel.dsl.fDeploy.FDUnion;
import org.franca.deploymodel.dsl.fDeploy.FDeployFactory;
import org.franca.deploymodel.dsl.validation.FDeployJavaValidator;
import org.franca.deploymodel.dsl.validation.FrancaQuickFixConstants;

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
		final String elementName = issue.getData()[0];
		final String description = "Fix all issues within '" + elementName	+ "'";

		acceptor.accept(issue, description, description, "",
				new ISemanticModification() {
					@Override
					public void apply(EObject obj, IModificationContext context) {
						if (obj instanceof FDInterface) {
							applyFixForInterfaceInternal((FDInterface) obj, FrancaQuickFixConstants.valueOf(issue.getData()[1]), elementName, true);
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
		final String methodName = issue.getData()[0];
		final String argumentName = issue.getData()[1];
		final String description = "Add missing argument '"+argumentName + "' for method '"+methodName+"'";
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
		if (method.getTarget().getInArgs().size() > 0) {
			for (FArgument arg : method.getTarget().getInArgs()) {
				if (args.length == 0 || Arrays.contains(args, arg.getName())) {
					if (method.getInArguments() == null) {
						method.setInArguments(FDeployFactory.eINSTANCE.createFDArgumentList());
					}
					FDArgument fdArg = FDeployQuickfixProviderUtil.getArgument(method.getInArguments(), arg);
					if (fdArg == null) {
						fdArg = FDeployFactory.eINSTANCE.createFDArgument();
						fdArg.setTarget(arg);
						method.getInArguments().getArguments().add(fdArg);
					}
					if (isRecursive) {
						applyFixForElementInternal(fdArg, isRecursive);
					}
				}
			}
		}
		if (method.getTarget().getOutArgs().size() > 0) {
			for (FArgument arg : method.getTarget().getOutArgs()) {
				if (args.length == 0 || Arrays.contains(args, arg.getName())) {
					if (method.getOutArguments() == null) {
						method.setOutArguments(FDeployFactory.eINSTANCE.createFDArgumentList());
					}
					FDArgument fdArg = FDeployQuickfixProviderUtil.getArgument(method.getOutArguments(), arg);
					if (fdArg == null) {
						fdArg = FDeployFactory.eINSTANCE.createFDArgument();
						fdArg.setTarget(arg);
						method.getOutArguments().getArguments().add(fdArg);
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
	
	private void applyFixForElementInternal(final FDElement element, final boolean isRecursive) {
		List<FDPropertyDecl> decls = PropertyMappings.getAllPropertyDecls(FDModelUtils.getRootElement(element).getSpec(), element);
		for (FDPropertyDecl decl : decls) {
			if (!FDeployQuickfixProviderUtil.hasPropertyDeclaration(element.getProperties(), decl) && PropertyMappings.isMandatory(decl)) {
				FDProperty prop = FDeployFactory.eINSTANCE.createFDProperty();
				prop.setDecl(decl);
				prop.setValue(FDeployQuickfixProviderUtil.generateDefaultValue(element, decl.getType()));
				element.getProperties().add(prop);
			}
		}
		
		if (isRecursive) {
			if (element instanceof FDMethod) {
				applyFixForMethodInternal((FDMethod) element, isRecursive);
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

	private void applyFixForInterfaceInternal(final FDInterface deploymentInterface, final FrancaQuickFixConstants type, String elementName, final boolean isRecursive) {
		FDElement deploymentElement = null;

		if (type == FrancaQuickFixConstants.ATTRIBUTE) {
			deploymentElement = FDeployQuickfixProviderUtil.getOrCreateAttribute(deploymentInterface, elementName);
		} 
		else if (type == FrancaQuickFixConstants.METHOD) {
			deploymentElement = FDeployQuickfixProviderUtil.getOrCreateMethod(deploymentInterface, elementName);
		} 
		else if (type == FrancaQuickFixConstants.BROADCAST) {
			deploymentElement = FDeployQuickfixProviderUtil.getOrCreateBroadcast(deploymentInterface, elementName);
		} 
		else if (type == FrancaQuickFixConstants.ARRAY) {
			deploymentElement = FDeployQuickfixProviderUtil.getOrCreateArray(deploymentInterface, elementName);
		} 
		else if (type == FrancaQuickFixConstants.STRUCT) {
			deploymentElement = FDeployQuickfixProviderUtil.getOrCreateStruct(deploymentInterface, elementName);
		} 
		else if (type == FrancaQuickFixConstants.ENUMERATION) {
			deploymentElement = FDeployQuickfixProviderUtil.getOrCreateEnumeration(deploymentInterface, elementName);
		} 
		else if (type == FrancaQuickFixConstants.UNION) {
			deploymentElement = FDeployQuickfixProviderUtil.getOrCreateUnion(deploymentInterface, elementName);
		}
		if (isRecursive && deploymentElement != null) {
			applyFixForElementInternal(deploymentElement, isRecursive);
		}

	}
}
