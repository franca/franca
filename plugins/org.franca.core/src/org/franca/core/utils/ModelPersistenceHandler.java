/*******************************************************************************
 * Copyright (c) 2012 Harman International (http://www.harman.com).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.core.utils;

import java.io.IOException;
import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.emf.ecore.xmi.impl.XMIResourceFactoryImpl;

/**
 * Base class to deal with Eclipse mechanisms to load/save models.
 * 
 * @author FPicioroaga
 * 
 */
public class ModelPersistenceHandler {

	/**
	 * All models that have cross-references must exist in the same ResourceSet
	 */
	private ResourceSet resourceSet;
	
	/**
	 * Map used to handle generically different model files. 
	 */
	private static Map<String, ImportsProvider> fileHandlerRegistry = new HashMap<String, ImportsProvider>();


	/**
	 * Creating an object used to save or to load a set of related models from files.
	 * 
	 * @param newResourceSet
	 *            the resource set to save all the loaded files/ where all the models to be saved exist
	 * @param newPrependPath
	 *            a relative path to work in
	 */
	public ModelPersistenceHandler(ResourceSet newResourceSet) {
		resourceSet = newResourceSet;
	}

	public static void registerFileExtensionHandler(String extension, ImportsProvider importsProvider)
	{
		fileHandlerRegistry.put(extension, importsProvider);
	}
	
	/**
	 * 
	 * Load the model found in the fileName. Its dependencies can be loaded subsequently.
	 *
	 * @param uri       the URI to be loaded
	 * @param root      the root of the model (needed for loading multiple file models)
	 *                  This has to be an absolute, hierarchical URI.
	 * @return the root model
	 */
	public EObject loadModel(URI uri, URI root) {
		// resolve the input uri, in case it is a relative path
		URI absURI = uri.resolve(root);
		if (! uri.equals(absURI)) {
			// add this pair to URI converter so that others can get the URI by its relative path
			resourceSet.getURIConverter().getURIMap().put(uri, absURI);
		}
		
		// load root model
		Resource resource = null;
		try {
			resource = resourceSet.getResource(absURI, true);
			resource.load(Collections.EMPTY_MAP);
		} catch (IOException e) {
			e.printStackTrace();
			return null;
		}
		EObject model = resource.getContents().get(0);
		
		// load all its imports recursively
		for (Iterator<String> it = fileHandlerRegistry.get(absURI.fileExtension()).importsIterator(model); it.hasNext();) {
			String importURIStr = it.next();
			URI importURI = URI.createURI(importURIStr);
			URI resolvedURI = importURI.resolve(absURI);
			
			// add this pair to URI converter so that others can get the URI by its relative path
			resourceSet.getURIConverter().getURIMap().put(importURI, resolvedURI);
			
			loadModel(resolvedURI, root);
		}
		return model;
	}

	/**
	 * 
	 * Load the model found in the fileName. Its dependencies can be loaded subsequently.
	 *
	 * @param filename
	 *            the file to be loaded
	 * @return the root model
	 * 
	 * @deprecated Use loadModel(URI uri, URI root) instead.
	 */
	public EObject loadModel(String filename, String cwd) {
		URI fileURI = normalizeURI(URI.createURI(filename));
		URI cwdURI = normalizeURI(URI.createURI(cwd));
		return loadModel(fileURI, cwdURI);
	}

	/**
	 * Saves a model to a file. If cross-references are used in the model then the model must be part of a ResourceSet
	 * containing all the other referenced models.
	 * 
	 * @param filename
	 *            the name of the file to be saved
	 * @param cwd a relative directory to save the file and its dependencies 
	 * @return true if the model was saved
	 */
	public boolean saveModel(EObject model, String filename, String cwd) {
		URI fileURI = normalizeURI(URI.createURI(filename));
		URI cwdURI = normalizeURI(URI.createURI(cwd));
		URI existingURI = null;
		URI toSaveURI = URI.createURI(cwdURI.toString() + fileURI.toString());
		Resource resource = model.eResource();
		
		if (model.eResource() != null) {
			//change the ResourceSet to this one
			resourceSet.getResources().add(model.eResource());
			existingURI = model.eResource().getURI();
			//and save the model using the new URI
			model.eResource().setURI(toSaveURI);
			//System.out.println("(" + existingURI + "," + toSaveURI + ")");
			resourceSet.getURIConverter().getURIMap().put(existingURI, toSaveURI);
		} else {
			// create a resource containing the model
			/**
			 * added the file extension to the factory map so that it registers the extension to the resource factory
			 */
			resourceSet.getResourceFactoryRegistry().getExtensionToFactoryMap().put("fidl", new XMIResourceFactoryImpl());
			resource = resourceSet.createResource(toSaveURI);
			resource.getContents().add(model);
	
		}

		//save the root model
		try {
			
			resource.save(null);
		} catch (IOException e) {
			e.printStackTrace();
		}
		//and all its imports recursively
		for (Iterator<String> it = fileHandlerRegistry.get(fileURI.fileExtension()).importsIterator(model); it.hasNext();) {
			String importURI = it.next();
			URI createFileURI = URI.createFileURI(importURI);
			/**
			 * 
			 * resolve the relative path of the imports so that the correct path is obtained for loading the model
			 */
			URI resolve = createFileURI.resolve(cwdURI);
			Resource resource2 = resourceSet.getResource(resolve,true);
			saveModel(resource2.getContents().get(0), importURI, getCWDForImport(fileURI, cwdURI).toString());
		}

		return true;
	}

	public ResourceSet getResourceSet() {
		return resourceSet;
	}

	/**
	 * Calculates the new relative working directory for an import.
	 * 
	 * @param filename
	 * @param cwd
	 * @return
	 */
	public static URI getCWDForImport(URI filename, URI cwd) {
		URI relativeCWD = cwd;

		if (filename.isRelative()) {
			if (cwd.segmentCount() > 0 && filename.segmentCount() > 1) {
				relativeCWD = URI.createURI(cwd.toString() + "/" + filename.trimSegments(1).toString()) ;
			} else if (filename.segmentCount() > 1) {
				relativeCWD = filename.trimSegments(1);
			}
		}
		return relativeCWD;
	}

	/**
	 * Convert Windows path separator to Unix one used in URIs.
	 * 
	 * @param path
	 * @return
	 */
	public static URI normalizeURI(URI path)
	{
		if (path.isFile())
		{
			return URI.createURI(path.toString().replaceAll("\\\\", "/"));
		}
		return path;
	}
}
