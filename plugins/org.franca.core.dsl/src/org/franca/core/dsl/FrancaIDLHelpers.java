/*******************************************************************************
* Copyright (c) 2012 Harman International (http://www.harman.com).
* All rights reserved. This program and the accompanying materials
* are made available under the terms of the Eclipse Public License v1.0
* which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/epl-v10.html
*******************************************************************************/
package org.franca.core.dsl;

import java.io.File;
import java.io.IOException;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;

import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.xtext.Constants;
import org.franca.core.framework.ModelFileFinder;
import org.franca.core.franca.FModel;

import com.google.inject.Inject;
import com.google.inject.Injector;
import com.google.inject.Provider;
import com.google.inject.name.Named;


public class FrancaIDLHelpers {
	@Inject 
	private Provider<ResourceSet> resourceSetProvider;
	
	@Inject @Named(Constants.FILE_EXTENSIONS)
	private String fileExtension;

	public String getFileExtension()
	{
		return fileExtension;
	}
	
	/**
	 * Load Franca IDL model file (*.fidl) and all imported files recursively.
	 * 
	 * @param fileName name of Franca file (suffix .fidl is optional)
	 * @return the root entity of the Franca IDL model
	 */
	public FModel loadModel (String fileName) {
		String fn = fileName;
		if (! fileName.endsWith("." + fileExtension)) {
			fileName += "." + fileExtension;
		}
		FModel model = null;
		try {
			model = loadFrancaIDLModel(fn);
		} catch (IOException e) {
			e.printStackTrace();
			return null;
		}
		
		if (model==null) {
			System.out.println("Error: Could not load Franca interface from file " + fn);
		} else {
			System.out.println("Loaded Franca IDL model " + model.getName());
		}
		return model;
	}
	
	/**
	 * Save a Franca IDL model to file (*.fidl).
	 * 
	 * @param model the root of model to be saved
	 * @param fileName name of Franca file (suffix .fidl is optional)
	 * @return true if save could be completed successfully
	 */
	public boolean saveModel (FModel model, String fileName) {
		String fn = fileName;
		if (! fn.endsWith("." + fileExtension)) {
			fn += "." + fileExtension;
		}
		return saveFrancaIDLModel(model, fn);
	}
	
	private FModel loadFrancaIDLModel (String fileName)
			throws IOException {
		
		// prepare ResourceSet
		ResourceSet resourceSet = resourceSetProvider.get();
		
		// add all existing resources to resourceSet
		File f = new File(fileName);
		String folderName = null;
		if (f.getParentFile() != null)
		{
			folderName = f.getParentFile().getAbsolutePath();
		}
		else
		{
			folderName = ".";
		}
		List<String> modelFiles = new ModelFileFinder(fileExtension).getSourceFiles(folderName);
		for (String fn : modelFiles) {
			//System.out.println("- resource file " + fn);
			resourceSet.getResource(URI.createFileURI(fn), true);
		}

		// load actual resource
		Resource resource = resourceSet.getResource(URI.createFileURI(fileName), true);
		HashMap<String,Object> options = new HashMap<String,Object>();
		try {
			resource.load(options);
		} catch (IOException e) {
			e.printStackTrace();
			return null;
		}
		
		return (FModel)resource.getContents().get(0);
	}

	
	private boolean saveFrancaIDLModel (FModel model, String filename) {
		ResourceSet resourceSet = resourceSetProvider.get();
		URI fileUri = URI.createFileURI(new File(filename).getAbsolutePath());
		Resource res = resourceSet.createResource(fileUri);
		res.getContents().add(model);
		try {
			res.save(Collections.EMPTY_MAP);
	        System.out.println("Created Franca IDL file " + filename);
		} catch (IOException e) {
			e.printStackTrace();
		}
		return true;
	}

	
	// singleton
	private static FrancaIDLHelpers instance = null;
	public static FrancaIDLHelpers instance() {
		if (instance==null) {
			Injector injector = new FrancaIDLStandaloneSetup().createInjectorAndDoEMFRegistration();
			instance = injector.getInstance(FrancaIDLHelpers.class);
		}
		return instance;
	}
}
