package org.franca.connectors.c_header.ui.handlers;

import java.util.Collection;

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
import org.eclipse.xtext.validation.Issue;
import org.franca.connectors.c_header.CHeaderConnector;
import org.franca.connectors.c_header.CHeaderModelContainer;
import org.franca.core.dsl.FrancaPersistenceManager;
import org.franca.core.dsl.ui.util.SpecificConsole;
import org.franca.core.franca.FModel;
import org.franca.core.utils.FrancaRecursiveValidator;

import com.google.inject.Inject;

public class GenerateCHeaderFromFrancaHandler extends AbstractHandler {

	@Inject 
	private FrancaPersistenceManager loader;
	
	@Inject 
	private FrancaRecursiveValidator validator;
	
	@SuppressWarnings("deprecation")
	@Override
	public Object execute(ExecutionEvent event) throws ExecutionException {
		ISelection selection = HandlerUtil.getCurrentSelection(event);

		if (selection != null && selection instanceof IStructuredSelection) {
			SpecificConsole myConsole = new SpecificConsole("Franca");
			final MessageConsoleStream out = myConsole.getOut();
			final MessageConsoleStream err = myConsole.getErr();

			if (selection.isEmpty()) {
				err.println("Please select exactly one file with extension 'fidl'!");
				return null;
			}

			IFile file = (IFile) ((IStructuredSelection) selection).getFirstElement();
			String fidlFile = file.getLocationURI().toString();
			String outputDir = file.getParent().getLocation().toString();

			// load Franca IDL file
			out.println("Loading Franca IDL file '" + fidlFile + "' ...");
			FModel fmodel = loader.loadModel(fidlFile);
			if (fmodel == null) {
				err.println("Couldn't load Franca IDL file '" + fidlFile + "'.");
				return null;
			}
			out.println("Franca IDL: package '" + fmodel.getName() + "'");

			// validate resource
			Collection<Issue> issues = validator.validate(fmodel.eResource());
			int nErrors = 0;
			for (Issue issue : issues) {
				switch (issue.getSeverity()) {
				case INFO:
				case WARNING:
					out.println(issue.toString());
					break;
				case ERROR:
					err.println(issue.toString());
					nErrors++;
					break;
				default:
					break;
				}
			}
			if (nErrors > 0) {
				err.println("Aborting due to validation errors!");
				return null;
			}

			out.println("Transforming to C Header file ...");
			CHeaderConnector headerConnector = new CHeaderConnector();
			CHeaderModelContainer header = null;
			try {
				header = (CHeaderModelContainer) headerConnector.fromFranca(fmodel);
			} catch (Exception e) {
				err.println("Exception during transformation: " + e.toString());
				for (StackTraceElement f : e.getStackTrace()) {
					err.println("\tat " + f.toString());
				}
				err.println("Internal transformation error, aborting.");
				return null;
			}

			// save C header file
			int ext = file.getName().lastIndexOf("." + file.getFileExtension());
			String outfile = file.getName().substring(0, ext) + "test.h";
			String outpath = outputDir + "/" + outfile;
			if (headerConnector.saveModel(header, outpath)) {
				out.println("Saved C Header file '" + outpath + "'.");
			} else {
				err.println("C Header couldn't be written to file '" + outpath + "'.");
			}

			// refresh IDE (in order to make new files visible)
			IProject project = file.getProject();
			try {
				project.refreshLocal(IResource.DEPTH_INFINITE, null);
			} catch (CoreException e) {
				e.printStackTrace();
			}
		}
		return null;
	}

}
