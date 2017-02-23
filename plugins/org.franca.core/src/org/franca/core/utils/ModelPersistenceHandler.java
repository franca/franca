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

import org.apache.log4j.Logger;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.franca.core.framework.IImportedModelProvider;

/**
 * Base class to deal with Eclipse mechanisms to load/save models.
 * 
 * @author FPicioroaga
 * 
 */
public class ModelPersistenceHandler {
	static final Logger logger = Logger.getLogger(ModelPersistenceHandler.class);

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
			//System.out.println("ModelPersistenceHandler: Loaded model from " + resource.getURI());
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
	 * Saves a model to a file. If cross-references are used in the model, then the
	 * model must be part of a ResourceSet containing all the other referenced models.</p>
	 * 
	 * @param filename the name of the file to be saved
	 * @param cwd a relative directory to save the file and its dependencies 
	 * @return true if the model was saved
	 */
	public boolean saveModel(EObject model, String filename, String cwd) {
		return saveModel(model, filename, cwd, null);
	}

	/**
	 * Saves a model to a file. If cross-references are used in the model, then the
	 * model must be part of a ResourceSet containing all the other referenced models.</p>
	 * 
	 * @param filename the name of the file to be saved
	 * @param cwd a relative directory to save the file and its dependencies 
	 * @param importedModels an interface which provides a referenced model from its importURI string
	 * @return true if the model was saved
	 */
	public boolean saveModel(EObject model, String filename, String cwd, IImportedModelProvider importedModels) {
		logger.info("Saving Franca model: root file is " + filename + ", " +
				(importedModels!=null ? importedModels.getNModels() : 0) + " imported models."
		);
		if (! initResourcesRecursively(model, filename, cwd, importedModels))
			return false;
		
		return saveModelRecursively(model, filename, cwd);
	}

	private boolean initResourcesRecursively(EObject model, String filename, String cwd, IImportedModelProvider importedModels) {
		URI fileURI = normalizeURI(URI.createURI(filename));
		URI cwdURI = normalizeURI(URI.createURI(cwd));

		URI toSaveURI = URI.createURI(cwdURI.toString() + fileURI.toString());
		Resource resource = model.eResource();
		
		if (resource == null) {
			// create a resource containing the model
//			logger.info("ModelPersistenceHandler: Creating new resource " + toSaveURI +
//					", #resources=" + resourceSet.getResources().size());
			resource = resourceSet.createResource(toSaveURI);
			resource.getContents().add(model);
		}

		// recursive call for all its imports
		for (Iterator<String> it = fileHandlerRegistry.get(fileURI.fileExtension()).importsIterator(model); it.hasNext();) {
			String importURI = it.next();
			URI importFileURI = URI.createFileURI(importURI);

			// resolve the relative path of the imports so that the correct path is obtained for loading the model
			URI resolve = importFileURI.resolve(cwdURI);
			String cwdNew = getCWDForImport(fileURI, cwdURI).toString();
//			logger.info("  Handling model import:" +
//					" importURI=" + importURI +
//					" fileURI=" + importFileURI +
//					" cwdNew=" + cwdNew
//			);
			EObject importedModel = importedModels!=null ? importedModels.getModel(importURI) : null;
			if (importedModel!=null) {
				//System.out.println("importedModel will be created - " + importURI);
				initResourcesRecursively(importedModel, importURI, cwdNew, importedModels);
			} else {
				logger.info("  Available resources:");
				for(Resource res : resourceSet.getResources()) {
					logger.info("    " + res.toString());
				}
				Resource actualResource = resourceSet.getResource(resolve, true);
				initResourcesRecursively(actualResource.getContents().get(0), importURI, cwdNew, importedModels);
			}
		}

		return true;
		
	}

	private boolean saveModelRecursively(EObject model, String filename, String cwd) {
		URI fileURI = normalizeURI(URI.createURI(filename));
		URI cwdURI = normalizeURI(URI.createURI(cwd));

		URI toSaveURI = URI.createURI(cwdURI.toString() + fileURI.toString());
		Resource resource = model.eResource();

		// here we assume that each model has a proper resource 
		if (resource== null) {
			logger.error("Model without resource, aborting (" + toSaveURI + ")");
			return false;
		}

		// change the ResourceSet to this one
		//resourceSet.getResources().add(resource);
		URI existingURI = resource.getURI();
		// and save the model using the new URI
		resource.setURI(toSaveURI);
//		logger.info("ModelPersistenceHandler: Saving model as resource " + toSaveURI);
		if (! existingURI.equals(toSaveURI)) {
			//logger.info("    previous URI was different: " + existingURI);
			resourceSet.getURIConverter().getURIMap().put(existingURI, toSaveURI);
		}
		
		// recursive call for all its imports
		for (Iterator<String> it = fileHandlerRegistry.get(fileURI.fileExtension()).importsIterator(model); it.hasNext();) {
			String importURI = it.next();
			URI createFileURI = URI.createFileURI(importURI);
			/**
			 * 
			 * resolve the relative path of the imports so that the correct path is obtained for loading the model
			 */
			URI resolve = createFileURI.resolve(cwdURI);
			Resource actualResource = resourceSet.getResource(resolve,true);
			saveModelRecursively(actualResource.getContents().get(0), importURI, getCWDForImport(fileURI, cwdURI).toString());
		}

		// save the model
		try {
			resource.save(Collections.EMPTY_MAP);
		} catch (IOException e) {
			e.printStackTrace();
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
