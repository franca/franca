package org.franca.connectors.c_header.ui.handlers;

import org.eclipse.cdt.internal.core.model.TranslationUnit;
import org.eclipse.core.commands.AbstractHandler;
import org.eclipse.core.commands.ExecutionEvent;
import org.eclipse.core.commands.ExecutionException;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.ui.console.MessageConsoleStream;
import org.eclipse.ui.handlers.HandlerUtil;
import org.franca.connectors.c_header.CHeaderConnector;
import org.franca.connectors.c_header.CHeaderModelContainer;
import org.franca.core.dsl.FrancaPersistenceManager;
import org.franca.core.dsl.ui.util.SpecificConsole;
import org.franca.core.franca.FModel;

import com.google.inject.Inject;

@SuppressWarnings("restriction")
public class GenerateFrancaFromCHeaderHandler extends AbstractHandler {

	@Inject
	private FrancaPersistenceManager saver;

	@Override
	public Object execute(ExecutionEvent event) throws ExecutionException {
		ISelection selection = HandlerUtil.getCurrentSelection(event);

		if (selection != null && selection instanceof IStructuredSelection) {
			SpecificConsole myConsole = new SpecificConsole("Franca");
			final MessageConsoleStream out = myConsole.getOut();
			final MessageConsoleStream err = myConsole.getErr();

			if (selection.isEmpty()) {
				err.println("Please select exactly one C header file!");
				return null;
			}

			Object firstElement = ((IStructuredSelection) selection).getFirstElement();
			IFile file = null;
			if (firstElement instanceof TranslationUnit) {
				TranslationUnit translationUnit = (TranslationUnit) firstElement;
				file = translationUnit.getFile();
			}
			else if (firstElement instanceof IFile) {
				file = (IFile) firstElement;
			}
			
			if (file == null) {
				err.println("Error occurred during file loading!");
				return null;
			}
			
			String headerFile = file.getLocationURI().toString();
			String outputDir = file.getParent().getLocation().toString();

			out.println("Loading C header file '" + headerFile + "' ...");
			CHeaderConnector connector = new CHeaderConnector();
			CHeaderModelContainer headerModelContainer = (CHeaderModelContainer) connector
					.loadModel(headerFile);
			if (headerModelContainer == null) {
				err.println("Couldn't load C header file '" + headerFile + "'.");
			} else {
				FModel fmodel = connector.toFranca(headerModelContainer);
				int ext = file.getName().lastIndexOf(
						"." + file.getFileExtension());
				String outfile = file.getName().substring(0, ext) + ".fidl";
				String outpath = outputDir + "/" + outfile;
				if (saver.saveModel(fmodel, outpath)) {
					out.println("Saved Franca IDL file '" + outpath + "'.");
				} else {
					err.println("Franca IDL file couldn't be written to file '"	+ outpath + "'.");
				}

				// refresh IDE (in order to make new files visible)
				IProject project = file.getProject();
				try {
					project.refreshLocal(IResource.DEPTH_INFINITE, null);
					;
				} catch (CoreException e) {

					e.printStackTrace();
				}
			}
		}
		return null;
	}
}
