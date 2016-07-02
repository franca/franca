/*******************************************************************************
 * Copyright (c) 2016 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.connectors.protobuf.ui.handlers;

import java.io.File;

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
import org.eclipse.xtext.xbase.lib.ListExtensions;
import org.franca.connectors.protobuf.ProtobufConnector;
import org.franca.connectors.protobuf.ProtobufModelContainer;
import org.franca.core.dsl.FrancaPersistenceManager;
import org.franca.core.dsl.ui.util.SpecificConsole;
import org.franca.core.framework.FrancaModelContainer;
import org.franca.core.framework.IssueReporter;
import org.franca.core.franca.FModel;

import com.google.eclipse.protobuf.protobuf.Protobuf;
import com.google.inject.Inject;

public class CreateFrancaFromProtobufHandler extends AbstractHandler {
	
	@Inject FrancaPersistenceManager saver;
    	
	@Override
	public Object execute(ExecutionEvent event) throws ExecutionException {
		ISelection selection = HandlerUtil.getCurrentSelection(event);
		
        if (selection != null && selection instanceof IStructuredSelection) {
    		SpecificConsole myConsole = new SpecificConsole("Franca");
            final MessageConsoleStream out = myConsole.getOut();
            final MessageConsoleStream err = myConsole.getErr();
            
            if (selection.isEmpty()) {
            	err.println("Please select exactly one file with extension 'proto'!");
                return null;
            }

            IFile file = (IFile) ((IStructuredSelection) selection).getFirstElement();
            String protoFile = file.getLocationURI().toString();
            String outputDir = file.getParent().getLocation().toString();

    		// load Google Protobuf file
            out.println("Loading Google Protobuf file '" + protoFile + "' ...");
            ProtobufConnector conn = new ProtobufConnector();
            ProtobufModelContainer protos = (ProtobufModelContainer)conn.loadModel(protoFile);
//        	if (protos==null) {
//    			err.println("Couldn't load Google Protobuf file '" + protoFile + "'.");
//    			return null;
//    		}
            for (Protobuf pm : ListExtensions.reverseView(protos.models())) {
            	String filename = protos.getFilename(pm) + ".proto";
	    		if (pm==null) {
	    			err.println("Error during load of Protobuf file '" + filename + "'.");
	    			return null;
	    		}
	    		out.println("Google Protobuf: loaded proto file " + filename);
    		
	    		// transform Google Protobuf to Franca
	    		out.println("Transforming to Franca IDL model ...");
	    		FrancaModelContainer result = null;
	    		try {
	    			result = conn.toFranca(protos);
	    			out.println(IssueReporter.getReportString(conn.getLastTransformationIssues()));    			
	    		} catch (Exception e) {
	    			// print stack trace to stdout to ease debugging
	    			e.printStackTrace();
	    			
	    			// print explanation and stack trace to console
	    			err.println("Exception during transformation: " + e.toString());
	    			for(StackTraceElement f : e.getStackTrace()) {
	    				err.println("\tat " + f.toString());
	    			}
	    			err.println("Internal transformation error, aborting.");
					return null;
	    		}
    		
	    		// save Franca fidl file(s)
	    		int ext = file.getName().lastIndexOf("." + file.getFileExtension());
	    		try {
	    			// save all transformed files
		    		String outfile = result.modelName() +
		    				"." + FrancaPersistenceManager.FRANCA_FILE_EXTENSION;
		    		String outpath = outputDir + File.separator + outfile;
	    			if (saver.saveModel(result.model(), outpath, result)) {
		    			out.println("Saved Franca IDL file '" + outpath + "'.");
		    		} else {
		    			err.println("Franca IDL model couldn't be written to file '" + outpath + "'.");
	    			}
	    		} catch (Exception e) {
	    			err.println("Exception while persisting result model to file: " + e.toString());
	    			for(StackTraceElement f : e.getStackTrace()) {
	    				err.println("\tat " + f.toString());
	    			}
	    			err.println("Internal transformation error, aborting.");
					return null;
	    		}
            }

    		// refresh IDE (in order to make new files visible)
            IProject project = file.getProject();
            try {
    			project.refreshLocal(IResource.DEPTH_INFINITE, null);;
			} catch (CoreException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
        }
		return null;
	}
}
