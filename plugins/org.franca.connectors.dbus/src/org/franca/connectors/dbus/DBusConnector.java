/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.connectors.dbus;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.PrintWriter;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Set;

import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;
import org.eclipse.emf.ecore.xmi.XMLResource;
import org.eclipse.emf.ecore.xmi.impl.URIHandlerImpl;
import org.franca.core.framework.AbstractFrancaConnector;
import org.franca.core.framework.FrancaModelContainer;
import org.franca.core.framework.IModelContainer;
import org.franca.core.framework.IssueReporter;
import org.franca.core.framework.TransformationIssue;
import org.franca.core.franca.FModel;
import org.franca.core.utils.FileHelper;
import org.franca.core.utils.IntegerTypeConverter;

import com.google.common.collect.Lists;
import com.google.inject.Guice;
import com.google.inject.Injector;

import model.emf.dbusxml.DbusxmlPackage;
import model.emf.dbusxml.DocumentRoot;
import model.emf.dbusxml.NodeType;
import model.emf.dbusxml.util.DbusxmlResourceFactoryImpl;
import model.emf.dbusxml.util.DbusxmlResourceImpl;

public class DBusConnector extends AbstractFrancaConnector {

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
			out.println("Error: Could not load DBus interface from file " + filename);
		} else {
			out.println("Loaded DBus interface " + model.getName());
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
		return saveDBusModel(createConfiguredResourceSet(), mc.model(), mc.getComments(), fn);
	}

	
	@Override
	public FrancaModelContainer toFranca (IModelContainer model) {
		if (! (model instanceof DBusModelContainer)) {
			return null;
		}
		
		DBus2FrancaTransformation trafo = injector.getInstance(DBus2FrancaTransformation.class);
		DBusModelContainer dbus = (DBusModelContainer)model;
		FModel fmodel = trafo.transform(dbus.model());
		
		lastTransformationIssues = trafo.getTransformationIssues();
		out.println(IssueReporter.getReportString(lastTransformationIssues));

		return new FrancaModelContainer(fmodel);
	}

	@Override
	public IModelContainer fromFranca (FModel fmodel) {
		// ranged integer conversion from Franca to D-Bus as a preprocessing step
		IntegerTypeConverter.removeRangedIntegers(fmodel, true);

		// do the actual transformation
		Franca2DBusTransformation trafo = injector.getInstance(Franca2DBusTransformation.class);
		NodeType dbus = trafo.transform(fmodel);
		
		// report issues
		lastTransformationIssues = trafo.getTransformationIssues();
		out.println(IssueReporter.getReportString(lastTransformationIssues));

		// create the model container and add some comments to the model
		DBusModelContainer mc = new DBusModelContainer(dbus);
		mc.addComment("<!-- This D-Bus Introspection model has been created from a Franca IDL file. -->");
		Resource res = fmodel.eResource();
		if (res!=null && res.getURI()!=null)
			mc.addComment("<!-- Input file: '" + res.getURI().lastSegment() + "' -->");

		return mc;
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


	private boolean saveDBusModel (ResourceSet resourceSet, NodeType model, Iterable<String> comments, String fileName) {
		URI fileUri = URI.createFileURI(new File(fileName).getAbsolutePath());
		DbusxmlResourceImpl res = (DbusxmlResourceImpl) resourceSet.createResource(fileUri);
		res.setEncoding("UTF-8");
				
		res.getContents().add(model);
		try {
			res.save(Collections.EMPTY_MAP);
	        out.println("Created DBus Introspection file " + fileName);
	        
	        List<String> additionalLines = Lists.newArrayList();
	        
	        // add "xml-stylesheet" tag to output xml file
	        additionalLines.add("<?xml-stylesheet type=\"text/xsl\" href=\"introspect.xsl\"?>");

	        // add comment lines
	        for(String c : comments)
	        	additionalLines.add(c);

	        addLinesToXML(new File(fileName), additionalLines);
	        
		} catch (IOException e) {
			e.printStackTrace();
			return false;
		}

		return true;
	}
	
	/**
	 * Add some lines to a given XML file. 
	 * 
	 * The lines will be inserted directly below the first line in the XML.
	 * The first line has to be a "xml version" tag.
	 *  
	 * @param inFile the XML file which should be changed
	 * @param lines the set of lines which should be inserted into the file
	 * @throws IOException
	 */
	private static void addLinesToXML(File inFile, Iterable<String> lines) throws IOException {
		// compile string which is to be inserted
		StringBuilder sb = new StringBuilder();
		sb.append("$1");
		for(String l : lines) {
			sb.append("\n" + l);
		}
		
		// read the file and insert the string which we have built before
		String content = contents(inFile);
		content = content.replaceAll("(<\\?xml version.*\\?>)", sb.toString());

		// write the file again
		FileOutputStream fos = new FileOutputStream(inFile);
		PrintWriter out = new PrintWriter(fos);
		out.print(content);
		out.flush();
		out.close();
	}

	private static String contents (File file) throws IOException {
		InputStream in = new FileInputStream(file);
		byte[] b  = new byte[(int) file.length()];
		int len = b.length;
		int total = 0;

		while (total < len) {
		  int result = in.read(b, total, len - total);
		  if (result == -1) {
		    break;
		  }
		  total += result;
		}
		in.close();
		return new String(b);
	}
}

