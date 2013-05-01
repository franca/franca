/*******************************************************************************
 * Copyright (c) 2012 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.connectors.dbus.ui.actions;

import model.emf.dbusxml.NodeType;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.jface.action.IAction;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.ui.IObjectActionDelegate;
import org.eclipse.ui.IWorkbenchPart;
import org.eclipse.ui.console.MessageConsoleStream;
import org.franca.connectors.dbus.DBusConnector;
import org.franca.connectors.dbus.DBusModelContainer;
import org.franca.connectors.dbus.util.XMLRootCheck;
import org.franca.core.dsl.FrancaPersistenceManager;
import org.franca.core.dsl.ui.util.SpecificConsole;
import org.franca.core.franca.FModel;

import com.google.inject.Inject;


public class CreateFrancaFromDBusXMLAction implements IObjectActionDelegate {

	private IStructuredSelection selection = null;
	
	@Inject FrancaPersistenceManager saver;

	@Override
	public void run(IAction action) {
    	SpecificConsole myConsole = new SpecificConsole("Franca");
        final MessageConsoleStream out = myConsole.getOut();
        final MessageConsoleStream err = myConsole.getErr();
		
        if (selection!=null) {
            if (selection.size()!=1) {
            	err.println("Please select exactly one file with extension 'xml'!");
                return;
            }

            IFile file = (IFile)selection.getFirstElement();
            if (! isDBusIntrospectionFile(file)) {
    			err.println("The selected file is not D-Bus Introspection XML format!");
    			return;
            }
            String dbusFile = file.getLocationURI().toString();
            String outputDir = file.getParent().getLocation().toString();

    		// load D-Bus Introspection XML file
            out.println("Loading D-Bus Introspection XML file '" + dbusFile + "' ...");
    		DBusConnector conn = new DBusConnector();
    		DBusModelContainer dbus = (DBusModelContainer)conn.loadModel(dbusFile);
    		if (dbus==null) {
    			err.println("Couldn't load D-Bus Introspection XML file '" + dbusFile + "'.");
    			return;
    		}
    		NodeType node = dbus.model();
    		if (node==null) {
    			err.println("Error during load of D-Bus Introspection XML file '" + dbusFile + "'.");
    			return;
    		}
    		out.println("D-Bus Introspection XML: loaded node '" + node.getName() + "'");
    		
    		// transform DBus Introspection XML to Franca
    		out.println("Transforming to Franca IDL model ...");
    		FModel fmodel = null;
    		try {
    			fmodel = conn.toFranca(dbus);
    		} catch (Exception e) {
    			err.println("Exception during transformation: " + e.toString());
    			for(StackTraceElement f : e.getStackTrace()) {
    				err.println("\tat " + f.toString());
    			}
    			err.println("Internal transformation error, aborting.");
				return;
    		}
    		
    		// save Franca fidl file
    		int ext = file.getName().lastIndexOf("." + file.getFileExtension());
    		String outfile = file.getName().substring(0, ext) + ".fidl";
    		String outpath = outputDir + "/" + outfile;
    		if (saver.saveModel(fmodel, outpath)) {
    			out.println("Saved Franca IDL file '" + outpath + "'.");
    		} else {
    			err.println("Franca IDL file couldn't be written to file '" + outpath + "'.");
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
	}

	@Override
	public void selectionChanged(IAction action, ISelection selection) {
        this.selection = (IStructuredSelection)selection;
	}

	@Override
	public void setActivePart(IAction action, IWorkbenchPart targetPart) {
		// TODO Auto-generated method stub
	}

	private boolean isDBusIntrospectionFile (IFile file) {
		String root = "";
		try {
			root = XMLRootCheck.determineRootElement(file.getContents());
		} catch (CoreException e) {
			return false;
		}
		return root.equals("node");
	}
}

