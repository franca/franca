/*******************************************************************************
 * Copyright (c) 2012 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.connectors.dbus.ui.handlers;

import model.emf.dbusxml.NodeType;

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
import org.franca.connectors.dbus.DBusConnector;
import org.franca.connectors.dbus.DBusModelContainer;
import org.franca.connectors.dbus.util.XMLRootCheck;
import org.franca.core.dsl.FrancaPersistenceManager;
import org.franca.core.dsl.ui.util.SpecificConsole;
import org.franca.core.framework.IssueReporter;
import org.franca.core.franca.FModel;

import com.google.inject.Inject;

public class CreateFrancaFromDBusXMLHandler extends AbstractHandler {
	
	@Inject FrancaPersistenceManager saver;
    	
	private boolean isDBusIntrospectionFile (IFile file) {
		String root = "";
		try {
			root = XMLRootCheck.determineRootElement(file.getContents());
		} catch (CoreException e) {
			return false;
		}
		return root.equals("node");
	}

	@Override
	public Object execute(ExecutionEvent event) throws ExecutionException {
		ISelection selection = HandlerUtil.getCurrentSelection(event);
		
        if (selection != null && selection instanceof IStructuredSelection) {
    		SpecificConsole myConsole = new SpecificConsole("Franca");
            final MessageConsoleStream out = myConsole.getOut();
            final MessageConsoleStream err = myConsole.getErr();
            
            if (selection.isEmpty()) {
            	err.println("Please select exactly one file with extension 'xml'!");
                return null;
            }

            IFile file = (IFile) ((IStructuredSelection) selection).getFirstElement();
            if (! isDBusIntrospectionFile(file)) {
    			err.println("The selected file is not D-Bus Introspection XML format!");
    			return null;
            }
            String dbusFile = file.getLocationURI().toString();
            String outputDir = file.getParent().getLocation().toString();

    		// load D-Bus Introspection XML file
            out.println("Loading D-Bus Introspection XML file '" + dbusFile + "' ...");
    		DBusConnector conn = new DBusConnector();
    		DBusModelContainer dbus = (DBusModelContainer)conn.loadModel(dbusFile);
    		if (dbus==null) {
    			err.println("Couldn't load D-Bus Introspection XML file '" + dbusFile + "'.");
    			return null;
    		}
    		NodeType node = dbus.model();
    		if (node==null) {
    			err.println("Error during load of D-Bus Introspection XML file '" + dbusFile + "'.");
    			return null;
    		}
    		out.println("D-Bus Introspection XML: loaded node '" + node.getName() + "'");
    		
    		// transform DBus Introspection XML to Franca
    		out.println("Transforming to Franca IDL model ...");
    		FModel fmodel = null;
    		try {
    			fmodel = conn.toFranca(dbus).model();
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
    		
    		// save Franca fidl file
    		int ext = file.getName().lastIndexOf("." + file.getFileExtension());
    		String outfile = file.getName().substring(0, ext) + ".fidl";
    		String outpath = outputDir + "/" + outfile;
    		try {
	    		if (saver.saveModel(fmodel, outpath)) {
	    			out.println("Saved Franca IDL file '" + outpath + "'.");
	    		} else {
	    			err.println("Franca IDL file couldn't be written to file '" + outpath + "'.");
	    		}
    		} catch (Exception e) {
    			err.println("Exception while persisting result model to file: " + e.toString());
    			for(StackTraceElement f : e.getStackTrace()) {
    				err.println("\tat " + f.toString());
    			}
    			err.println("Internal transformation error, aborting.");
				return null;
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

