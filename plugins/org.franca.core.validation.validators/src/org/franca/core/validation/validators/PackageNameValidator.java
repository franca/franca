package org.franca.core.validation.validators;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.List;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.runtime.IPath;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.swt.widgets.Display;
import org.eclipse.ui.IEditorPart;
import org.eclipse.ui.IWorkbenchWindow;
import org.eclipse.ui.PlatformUI;
import org.eclipse.xtext.diagnostics.Severity;
import org.franca.core.franca.FModel;
import org.franca.core.franca.FrancaPackage;
import org.franca.core.validation.runtime.IFrancaValidator;
import org.franca.core.validation.runtime.Issue;

public class PackageNameValidator implements IFrancaValidator {

	private static String francaEditorId = "org.franca.core.dsl.FrancaIDL";

	private IWorkbenchWindow workbenchWindow;

	@Override
	public Collection<Issue> validateModel(Resource resource) {
		FModel model = null;
		for (EObject obj : resource.getContents()) {
			if (obj instanceof FModel) {
				model = (FModel) obj;
			}
		}

		if (model != null) {
			Display.getDefault().syncExec(new Runnable() {
				@Override
				public void run() {
					workbenchWindow = PlatformUI.getWorkbench()
							.getActiveWorkbenchWindow();
				}
			});

			List<Issue> issues = new ArrayList<Issue>();

			if (workbenchWindow != null) {
				IEditorPart editor = workbenchWindow.getActivePage()
						.getActiveEditor();

				if (editor.getEditorSite().getId().equals(francaEditorId)) {
					IFile file = (IFile) editor.getEditorInput().getAdapter(
							IFile.class);
					IPath relativePath = file.getProjectRelativePath();
					String[] tokens = relativePath.toString().split("/");

					StringBuilder sb = new StringBuilder();
					if (tokens.length > 2) {
						for (int i = 1; i < tokens.length - 1; i++) {
							sb.append(tokens[i]);
							if (i != tokens.length - 2) {
								sb.append(".");
							}
						}
					}

					if (!sb.toString().equals(model.getName())) {
						issues.add(new Issue("The name of the container package and model package must be the same!", model, FrancaPackage.Literals.FMODEL__NAME, Severity.ERROR));
					}
				}
			}

			return issues;
		}
		return Collections.emptyList();
	}

}
