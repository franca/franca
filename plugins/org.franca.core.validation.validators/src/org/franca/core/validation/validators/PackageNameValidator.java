package org.franca.core.validation.validators;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.runtime.IPath;
import org.eclipse.swt.widgets.Display;
import org.eclipse.ui.IEditorPart;
import org.eclipse.ui.IWorkbenchWindow;
import org.eclipse.ui.PlatformUI;
import org.eclipse.xtext.validation.ValidationMessageAcceptor;
import org.franca.core.dsl.validation.IFrancaExternalValidator;
import org.franca.core.franca.FModel;
import org.franca.core.franca.FrancaPackage;

public class PackageNameValidator implements IFrancaExternalValidator {

	private static String francaEditorId = "org.franca.core.dsl.FrancaIDL";

	private IWorkbenchWindow workbenchWindow;

	@Override
	public void validateModel(FModel model,
			ValidationMessageAcceptor messageAcceptor) {

		Display.getDefault().syncExec(new Runnable() {
			@Override
			public void run() {
				workbenchWindow = PlatformUI.getWorkbench()
						.getActiveWorkbenchWindow();
			}
		});

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
					messageAcceptor.acceptError(
							"The name of the container package and model package must be the same!",
							model, FrancaPackage.Literals.FMODEL__NAME, ValidationMessageAcceptor.INSIGNIFICANT_INDEX, null);
				}
			}
		}
	}

}
