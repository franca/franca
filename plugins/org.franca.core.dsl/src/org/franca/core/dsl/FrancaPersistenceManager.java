/*******************************************************************************
 * Copyright (c) 2012 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.core.dsl;

import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.xtext.Constants;
import org.franca.core.franca.FModel;
import org.franca.core.utils.ModelPersistenceHandler;

import com.google.inject.Inject;
import com.google.inject.Provider;
import com.google.inject.name.Named;

/**
 * Manager for loading and saving Franca models from file system. 
 * It supports models which are distributed over several files.
 * The implementation is dependency-injection-aware.
 * 
 * @author kbirken
 *
 */
public class FrancaPersistenceManager {

	@Inject
	@Named(Constants.FILE_EXTENSIONS)
	private String fileExtension;

	@Inject
	private Provider<ResourceSet> resourceSetProvider;
	
	public String getFileExtension() {
		return fileExtension;
	}

	/**
	 * Load Franca IDL model file (*.fidl) and all imported files recursively.
	 * 
	 * @param filename  name of Franca file (suffix .fidl is optional)
	 * 
	 * @return the root entity of the Franca IDL model
	 */
	public FModel loadModel(String filename) {
		try {
			URI fileURI = ModelPersistenceHandler.normalizeURI(createURI(filename));
		
			if (fileURI.segmentCount() > 1) {
				return loadModel(fileURI.lastSegment(), fileURI.trimSegments(1).toString() + "/");
			} else {
				return loadModel(filename, "");
			}
		} catch (Exception ex) {
			System.err.println("Error: " + ex.getMessage());
			return null;
		}
	}

	/**
	 * Load Franca IDL model file (*.fidl) and all imported files recursively.
	 * 
	 * @param filename  name of Franca file (suffix .fidl is optional)
	 * @param cwd       if not null work relatively to this path
	 * @return
	 */
	private FModel loadModel(String filename, String cwd) {
		String fn = filename;

		if (fn == null)
			return null;
		if (!fn.endsWith("." + fileExtension)) {
			fn += "." + fileExtension;
		}

		ModelPersistenceHandler persistenceHandler = createModelPersistenceHandler(resourceSetProvider.get());
		return (FModel) persistenceHandler.loadModel(fn, cwd);
	}

	/**
	 * Save a Franca IDL model to file (*.fidl).
	 * 
	 * @param model      the root of model to be saved
	 * @param filename   name of Franca file (suffix .fidl is optional)
	 * 
	 * @return true if save could be completed successfully
	 */
	public boolean saveModel(FModel model, String filename) {
		URI uri = URI.createURI(filename);
		
		if (uri.segmentCount() > 1) {
			return saveModel(model, uri.lastSegment(), uri.trimSegments(1).toString() + "/");
		} else {
			return saveModel(model, filename, "");
		}
	}
	
	/**
	 * Save a Franca IDL model to file (*.fidl).
	 * 
	 * @param model    the root of model to be saved
	 * @param filename name of Franca file (suffix .fidl is optional)
	 * @param cwd      if not null work relatively to this path
	 * 
	 * @return true if save could be completed successfully
	 */
	public boolean saveModel(FModel model, String filename, String cwd) {
		ResourceSet resourceSet = null;
		String fn = filename;
		
		if (fn == null)
			return false;
		if (!fn.endsWith("." + fileExtension)) {
			fn += "." + fileExtension;
		}
		if (model.eResource() == null) {
			// create a new ResourceSet for this new created model
			resourceSet = resourceSetProvider.get();
		} else {
			// use the existing ResourceSet associated to the model
			resourceSet = model.eResource().getResourceSet();
		}

		return createModelPersistenceHandler(resourceSet).saveModel(model, fn, cwd);
	}

	/**
	 * Workaround: createFileURI is platform-dependent and doesn't work
	 * for absolute paths on Unix and MacOS. This function provides 
	 * createURI from file paths for Unix, MacOS and Windows.
	 */
	private URI createURI(String filename) {
		URI uri = URI.createURI(filename);

		String os = System.getProperty("os.name");
		boolean isWindows = os.startsWith("Windows");
		boolean isUnix = !isWindows; // this might be too clumsy...
		if (uri.scheme() != null) {
			// If we are under Windows and s starts with x: it is an absolute path
			if (isWindows && uri.scheme().length() == 1) {
				return URI.createFileURI(filename);
			}
			// otherwise it is a proper URI
			else {
				return uri;
			}
		}
		// Handle paths that start with / under Unix e.g. /local/foo.txt
		else if (isUnix && filename.startsWith("/")) { 
			return URI.createFileURI(filename);
		}
		// otherwise it is a proper URI
		else {
			return uri;
		}
	}

	// TODO: refactor MPH in order to avoid this function
	private ModelPersistenceHandler createModelPersistenceHandler (ResourceSet resourceSet) {
		ModelPersistenceHandler.registerFileExtensionHandler(
				fileExtension,
				new FrancaImportsProvider());

		ModelPersistenceHandler persistenceHandler = new ModelPersistenceHandler(resourceSet);
		return persistenceHandler;
	}
}
