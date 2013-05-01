
package org.franca.deploymodel.dsl.ui.quickfix;

import java.util.List;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.xtext.ui.editor.model.edit.IModificationContext;
import org.eclipse.xtext.ui.editor.model.edit.ISemanticModification;
import org.eclipse.xtext.ui.editor.quickfix.DefaultQuickfixProvider;
import org.eclipse.xtext.ui.editor.quickfix.Fix;
import org.eclipse.xtext.ui.editor.quickfix.IssueResolutionAcceptor;
import org.eclipse.xtext.validation.Issue;
import org.franca.deploymodel.core.FDModelUtils;
import org.franca.deploymodel.core.PropertyMappings;
import org.franca.deploymodel.dsl.FDModelHelper;
import org.franca.deploymodel.dsl.fDeploy.FDBoolean;
import org.franca.deploymodel.dsl.fDeploy.FDComplexValue;
import org.franca.deploymodel.dsl.fDeploy.FDElement;
import org.franca.deploymodel.dsl.fDeploy.FDEnum;
import org.franca.deploymodel.dsl.fDeploy.FDEnumType;
import org.franca.deploymodel.dsl.fDeploy.FDInteger;
import org.franca.deploymodel.dsl.fDeploy.FDPredefinedTypeId;
import org.franca.deploymodel.dsl.fDeploy.FDProperty;
import org.franca.deploymodel.dsl.fDeploy.FDPropertyDecl;
import org.franca.deploymodel.dsl.fDeploy.FDRootElement;
import org.franca.deploymodel.dsl.fDeploy.FDString;
import org.franca.deploymodel.dsl.fDeploy.FDTypeRef;
import org.franca.deploymodel.dsl.fDeploy.FDValue;
import org.franca.deploymodel.dsl.fDeploy.FDValueArray;
import org.franca.deploymodel.dsl.fDeploy.FDeployFactory;
import org.franca.deploymodel.dsl.validation.FDeployJavaValidator;

public class FDeployQuickfixProvider extends DefaultQuickfixProvider {

	@Fix(FDeployJavaValidator.MISSING_MANDATORY_PROPERTIES)
	public void addMandatoryProperty(final Issue issue, IssueResolutionAcceptor acceptor) {
		final String missingProps = issue.getData()[0];
		final String[] missing = missingProps.split(", ");
		final String ending = missing.length==1 ? "y" : "ies";
		acceptor.accept(issue,
				"Add missing mandatory propert" + ending,
				"Add all missing mandatory propert" + ending + " (" + missing + ")",
				"", new ISemanticModification() {
			public void apply(EObject obj, IModificationContext context) {
				if (obj instanceof FDElement) {
					FDElement elem = (FDElement)obj;

					FDRootElement root = FDModelUtils.getRootElement(elem);
					List<FDPropertyDecl> decls = PropertyMappings.getAllPropertyDecls(root.getSpec(), elem);
					for(String missingProp : missing) {
						for(FDPropertyDecl decl : decls) {
							if (decl.getName().equals(missingProp)) {
								FDProperty prop = FDeployFactory.eINSTANCE.createFDProperty();
								prop.setDecl(decl);
								prop.setValue(generateDummyValue(decl.getType()));
								elem.getProperties().add(prop);
							}
						}
					}
				}
			}
		});
	}

	
	private static FDComplexValue generateDummyValue (FDTypeRef typeRef) {
		FDValue simple = null;
		if (typeRef.getComplex()==null) {
			switch (typeRef.getPredefined().getValue()) {
			case FDPredefinedTypeId.BOOLEAN_VALUE:
				FDBoolean boolVal = FDeployFactory.eINSTANCE.createFDBoolean();
				boolVal.setValue("false");
				simple = boolVal;
				break;
			case FDPredefinedTypeId.INTEGER_VALUE:
				FDInteger intVal = FDeployFactory.eINSTANCE.createFDInteger();
				intVal.setValue(0);
				simple = intVal;
				break;
			case FDPredefinedTypeId.STRING_VALUE:
				FDString strVal = FDeployFactory.eINSTANCE.createFDString();
				strVal.setValue("");
				simple = strVal;
				break;
			}
		} else {
			if (typeRef.getComplex() instanceof FDEnumType) {
				FDEnumType enumeration = (FDEnumType)typeRef.getComplex();
				FDEnum enumVal = FDeployFactory.eINSTANCE.createFDEnum();
				enumVal.setValue(enumeration.getEnumerators().get(0));
				simple = enumVal;
			}
		}
		
		if (simple!=null) {
			FDComplexValue ret = FDeployFactory.eINSTANCE.createFDComplexValue();
			if (typeRef.getArray()==null) {
				ret.setSingle(simple);
			} else {
				FDValueArray arrayVal = FDeployFactory.eINSTANCE.createFDValueArray();
				arrayVal.getValues().add(simple);
				ret.setArray(arrayVal);
			}
			return ret;
		}
		
		return null;
	}
	
//	@Fix(FDeployJavaValidator.MISSING_MANDATORY_PROPERTY)
//	public void capitalizeName(final Issue issue, IssueResolutionAcceptor acceptor) {
//		acceptor.accept(issue, "Capitalize name", "Capitalize the name.", "upcase.png", new IModification() {
//			public void apply(IModificationContext context) throws BadLocationException {
//				IXtextDocument xtextDocument = context.getXtextDocument();
//				String firstLetter = xtextDocument.get(issue.getOffset(), 1);
//				xtextDocument.replace(issue.getOffset(), 1, firstLetter.toUpperCase());
//			}
//		});
//	}

}
