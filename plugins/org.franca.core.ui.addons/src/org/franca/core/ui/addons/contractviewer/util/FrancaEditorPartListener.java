package org.franca.core.ui.addons.contractviewer.util;

import org.eclipse.core.resources.IFile;
import org.eclipse.ui.IPartListener;
import org.eclipse.ui.IWorkbenchPart;
import org.eclipse.xtext.ui.editor.XtextEditor;
import org.franca.core.ui.addons.contractviewer.FrancaContractVisualizerView;

public class FrancaEditorPartListener implements IPartListener {

	private static String francaEditorId = "org.franca.core.dsl.FrancaIDL";

	@Override
	public void partActivated(IWorkbenchPart part) {
		handleContractRegistration(part);
	}

	@Override
	public void partBroughtToTop(IWorkbenchPart part) {

	}

	@Override
	public void partClosed(IWorkbenchPart part) {
		handleContractUnregistration(part);
	}

	@Override
	public void partDeactivated(IWorkbenchPart part) {
		
	}

	@Override
	public void partOpened(IWorkbenchPart part) {
		
	}
	
	private void handleContractUnregistration(IWorkbenchPart part) {
		if (part instanceof XtextEditor) {
			XtextEditor editor = (XtextEditor) part;

			if (editor.getEditorSite().getId().equals(francaEditorId)) {
				FrancaContractVisualizerView view = FrancaContractVisualizerView.getInstance();
				if (view != null) {
					view.clear();
					view.updateModel();
				}
			}
		}
	}

	private void handleContractRegistration(IWorkbenchPart part) {
		if (part instanceof XtextEditor) {
			XtextEditor editor = (XtextEditor) part;

			if (editor.getEditorSite().getId().equals(francaEditorId)) {
				Object adapted = editor.getEditorInput().getAdapter(IFile.class);
				FrancaContractVisualizerView view = FrancaContractVisualizerView.getInstance();
				if (!editor.equals(view.getActiveEditor()) && adapted != null && view != null) {
					IFile file = (IFile) adapted;
					view.setActiveEditor(editor);
					view.setActiveFile(file);
					view.updateModel();
				}
			}
		}
	}
}
