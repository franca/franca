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
import org.franca.core.franca.FModel;
import org.franca.core.utils.FileHelper;
import org.franca.core.utils.ModelPersistenceHandler;

import com.google.inject.Inject;
import com.google.inject.Provider;

/**
 * Manager for loading and saving Franca models from file system. 
 * It supports models which are distributed over several files.
 * The implementation is dependency-injection-aware.
 * 
 * @author kbirken
 *
 */
public class FrancaPersistenceManager {

	private static final String FRANCA_FILE_EXTENSION = "fidl";

	@Inject
	private Provider<ResourceSet> resourceSetProvider;
	
	public static String getFileExtension() {
		return FRANCA_FILE_EXTENSION;
	}

	/**
	 * Load Franca IDL model file (*.fidl) and all imported files recursively.
	 * 
	 * @param filename  name of Franca file (suffix .fidl is optional)
	 * 
	 * @return the root entity of the Franca IDL model
	 * 
	 * @deprecated Use loadModel(URI uri, URI root) instead.
	 */
	public FModel loadModel(String filename) {
		try {
			URI uri = FileHelper.createURI(filename);
			URI fileURI = ModelPersistenceHandler.normalizeURI(uri);
		
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
	 * @param uri   URI for Franca file
	 * @param root  the root of the model (needed for loading multiple file models)
	 *              This has to be an absolute, hierarchical URI.
	 * 
	 * @return the root entity of the Franca model
	 */
	public FModel loadModel(URI uri, URI root) {
		ModelPersistenceHandler persistenceHandler = createModelPersistenceHandler(resourceSetProvider.get());
		return (FModel) persistenceHandler.loadModel(uri, root);
	}

	/**
	 * Load Franca IDL model file (*.fidl) and all imported files recursively.
	 * 
	 * @param filename  name of Franca file (suffix .fidl is optional)
	 * @param cwd       if not null work relatively to this path
	 * @return
	 * 
	 * @deprecated Use loadModel(URI uri, URI root) instead.
	 */
	private FModel loadModel(String filename, String cwd) {
		String fn = filename;

		if (fn == null)
			return null;
		if (!fn.endsWith("." + FRANCA_FILE_EXTENSION)) {
			fn += "." + FRANCA_FILE_EXTENSION;
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
		URI uri = FileHelper.createURI(filename);
		
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
		if (!fn.endsWith("." + FRANCA_FILE_EXTENSION)) {
			fn += "." + FRANCA_FILE_EXTENSION;
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

	// TODO: refactor MPH in order to avoid this function
	private ModelPersistenceHandler createModelPersistenceHandler (ResourceSet resourceSet) {
		ModelPersistenceHandler.registerFileExtensionHandler(
				FRANCA_FILE_EXTENSION,
				new FrancaImportsProvider());

		ModelPersistenceHandler persistenceHandler = new ModelPersistenceHandler(resourceSet);
		return persistenceHandler;
	}
}
