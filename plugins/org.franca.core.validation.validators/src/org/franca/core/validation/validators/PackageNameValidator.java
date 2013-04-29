package org.franca.core.validation.validators;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.runtime.IPath;
import org.eclipse.swt.widgets.Display;
import org.eclipse.ui.IEditorPart;
import org.eclipse.ui.IWorkbenchWindow;
import org.eclipse.ui.PlatformUI;
import org.eclipse.xtext.diagnostics.Severity;
import org.eclipse.xtext.validation.CheckType;
import org.eclipse.xtext.validation.Issue;
import org.franca.core.franca.FModel;
import org.franca.core.validation.runtime.IFrancaValidator;

public class PackageNameValidator implements IFrancaValidator {

	private static String francaEditorId = "org.franca.core.dsl.FrancaIDL";
	
	private IWorkbenchWindow workbenchWindow;
	
	@Override
	public Collection<Issue> validateModel(FModel model) {	
		Display.getDefault().syncExec(new Runnable() {
			@Override
			public void run() {
				workbenchWindow = PlatformUI.getWorkbench().getActiveWorkbenchWindow();
			}
		});
		
		List<Issue> issues = new ArrayList<Issue>();
		
		if (workbenchWindow != null) {
			IEditorPart editor = workbenchWindow.getActivePage().getActiveEditor();
			
			if (editor.getEditorSite().getId().equals(francaEditorId)) {
				IFile file = (IFile) editor.getEditorInput().getAdapter(IFile.class);
				IPath relativePath = file.getProjectRelativePath();
				String[] tokens = relativePath.toString().split("/");
				
				StringBuilder sb = new StringBuilder();
				if (tokens.length > 2) {
					for (int i = 1;i<tokens.length-1;i++) {
						sb.append(tokens[i]);
						if (i != tokens.length - 2) {
							sb.append(".");
						}
					}
				}
				
				if (!sb.toString().equals(model.getName())) {
					Issue.IssueImpl issue = new Issue.IssueImpl();
					issue.setUriToProblem(model.eResource().getURI());
					issue.setMessage("The name of the container package and model package must be the same!");
					issue.setSyntaxError(false);
					issue.setType(CheckType.NORMAL);
					issue.setSeverity(Severity.ERROR);
					issues.add(issue);
				}
			}
		}
		
		return issues;
	}

}
