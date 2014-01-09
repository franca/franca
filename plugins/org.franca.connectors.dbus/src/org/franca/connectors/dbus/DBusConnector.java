/*******************************************************************************
 * Copyright (c) 2013 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.connectors.dbus;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.util.Collections;
import java.util.HashMap;
import java.util.Set;

import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;
import org.eclipse.emf.ecore.xmi.XMLResource;
import org.eclipse.emf.ecore.xmi.impl.URIHandlerImpl;
import org.franca.core.framework.IFrancaConnector;
import org.franca.core.framework.IModelContainer;
import org.franca.core.framework.IssueReporter;
import org.franca.core.framework.TransformationIssue;
import org.franca.core.franca.FModel;
import org.franca.core.utils.FileHelper;

import com.google.inject.Guice;
import com.google.inject.Injector;

import model.emf.dbusxml.DbusxmlPackage;
import model.emf.dbusxml.DocumentRoot;
import model.emf.dbusxml.NodeType;
import model.emf.dbusxml.util.DbusxmlResourceFactoryImpl;
import model.emf.dbusxml.util.DbusxmlResourceImpl;

public class DBusConnector implements IFrancaConnector {

	private Injector injector;

	private String fileExtension = "xml";

	private Set<TransformationIssue> lastTransformationIssues = null;

	/** constructor */
	public DBusConnector () {
		injector = Guice.createInjector(new DBusConnectorModule());
	}
	
	@Override
	public IModelContainer loadModel (String filename) {
		NodeType model = loadDBusModel(createConfiguredResourceSet(), filename);
		if (model==null) {
			System.out.println("Error: Could not load DBus interface from file " + filename);
		} else {
			System.out.println("Loaded DBus interface " + model.getName());
		}
		return new DBusModelContainer(model); 
	}

	@Override
	public boolean saveModel (IModelContainer model, String filename) {
		if (! (model instanceof DBusModelContainer)) {
			return false;
		}

		String fn = filename;
		if (! filename.endsWith("." + fileExtension)) {
			fn += "." + fileExtension;
		}
		
		DBusModelContainer mc = (DBusModelContainer) model;
		return saveDBusModel(createConfiguredResourceSet(), mc.model(), fn);
	}

	
	@Override
	public FModel toFranca (IModelContainer model) {
		if (! (model instanceof DBusModelContainer)) {
			return null;
		}
		
		DBus2FrancaTransformation trafo = injector.getInstance(DBus2FrancaTransformation.class);
		DBusModelContainer dbus = (DBusModelContainer)model;
		FModel fmodel = trafo.transform(dbus.model());
		lastTransformationIssues = trafo.getTransformationIssues();
		System.out.println(IssueReporter.getReportString(lastTransformationIssues));

		return fmodel;
	}

	@Override
	public IModelContainer fromFranca (FModel fmodel) {
		Franca2DBusTransformation trafo = injector.getInstance(Franca2DBusTransformation.class);
		NodeType dbus = trafo.transform(fmodel);
		lastTransformationIssues = trafo.getTransformationIssues();
		System.out.println(IssueReporter.getReportString(lastTransformationIssues));

		return new DBusModelContainer(dbus);
	}
	
	public Set<TransformationIssue> getLastTransformationIssues() {
		return lastTransformationIssues;
	}
	
	private ResourceSet createConfiguredResourceSet() {
		// create new resource set
		ResourceSet resourceSet = new ResourceSetImpl();
		
		// register the appropriate resource factory to handle all file extensions for Dbus
		resourceSet.getResourceFactoryRegistry().getExtensionToFactoryMap().put("xml", new DbusxmlResourceFactoryImpl());
		resourceSet.getPackageRegistry().put(DbusxmlPackage.eNS_URI, DbusxmlPackage.eINSTANCE);
		
		return resourceSet;
	}
	

	/**
	 * We need to provide a different behavior for URI resolving during load
	 * of D-Bus Introspection XML files. This is because the noNamespaceSchemaLocation
	 * attribute "introspect.xsd" will be used as a key to find the corresponding
	 * EMF package name. If we load an Introspection file with an absolute path, the 
	 * resolving would destroy this key and the EMF package is no more found.  
	 */
	private static class DBusURIHandler extends URIHandlerImpl {
		@Override
		public URI resolve(URI uri) {
			// don't resolve
			return uri;
		}
	}
	
	private static NodeType loadDBusModel (ResourceSet resourceSet, String fileName) {
		URI uri = FileHelper.createURI(fileName);
//		URI uri = null;
//		// try creating file URI first
//		try {
//			uri = URI.createFileURI(fileName);
//		} catch (IllegalArgumentException e) {
//			// didn't work out, try generic URI
//			uri = URI.createURI(fileName);
//		}
		Resource resource = resourceSet.createResource(uri);

		HashMap<String,Object> options = new HashMap<String,Object>();
		options.put(XMLResource.OPTION_EXTENDED_META_DATA, Boolean.TRUE);
		options.put(XMLResource.OPTION_SCHEMA_LOCATION, "introspect.xsd");
		options.put(XMLResource.OPTION_URI_HANDLER, new DBusURIHandler());
		try {
			resource.load(options);
		} catch (IOException e) {
			e.printStackTrace();
			//return null;
		}

		if (resource.getContents().isEmpty())
			return null;

		return ((DocumentRoot)resource.getContents().get(0)).getNode();
	}


	private static boolean saveDBusModel (ResourceSet resourceSet, NodeType model, String fileName) {
		URI fileUri = URI.createFileURI(new File(fileName).getAbsolutePath());
		DbusxmlResourceImpl res = (DbusxmlResourceImpl) resourceSet.createResource(fileUri);
		res.setEncoding("UTF-8");
				
		res.getContents().add(model);
		try {
			res.save(Collections.EMPTY_MAP);
	        System.out.println("Created DBus Introspection file " + fileName);
	        
	        //FIXME, 'cause I am a very dirty hack :)
	        addStyleSheet(new File(fileName));
	        
		} catch (IOException e) {
			e.printStackTrace();
			return false;
		}

		return true;
	}
	
	private static void addStyleSheet(File inFile) throws IOException {
		
	     // temp file
	     File outFile = new File("helpfile.tmp");
	     
	     // input
	     FileInputStream fis  = new FileInputStream(inFile);
	     BufferedReader in = new BufferedReader
	         (new InputStreamReader(fis));

	     // output         
	     FileOutputStream fos = new FileOutputStream(outFile);
	     PrintWriter out = new PrintWriter(fos);

	     String thisLine = "";

	     while ((thisLine = in.readLine()) != null) {
	    	 out.println(thisLine);
	    	 if(thisLine.startsWith("<?xml version")) {
	    		 out.println("<?xml-stylesheet type=\"text/xsl\" href=\"introspect.xsl\"?>");
	    	 }
	     }
	     
	    out.flush();
	    out.close();
		in.close();
	    
	    inFile.delete();
	    outFile.renameTo(inFile);		
		
	}
	
}
