/*******************************************************************************
 * Copyright (c) 2012 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.deploymodel.dsl;

import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.franca.core.dsl.FrancaIDLStandaloneSetup;
import org.franca.core.dsl.FrancaImportsProvider;
import org.franca.core.dsl.FrancaPersistenceManager;
import org.franca.core.utils.FileHelper;
import org.franca.core.utils.ModelPersistenceHandler;
import org.franca.deploymodel.dsl.fDeploy.FDModel;

import com.google.inject.Inject;
import com.google.inject.Provider;

/**
 * Manager for loading and saving Franca deployment models from file system. 
 * It supports models which are distributed over several files.
 * The implementation is dependency-injection-aware.
 * 
 * @author kbirken
 *
 */
public class FDeployPersistenceManager {

	private final String fileExtension = "fdepl";

	@Inject
	private Provider<ResourceSet> resourceSetProvider;

//	public String getFileExtension() {
//		return fileExtension;
//	}

	public FDeployPersistenceManager() {
		// register the appropriate resource factory to handle all file extensions
		// for the Franca core model
		new FrancaIDLStandaloneSetup().createInjectorAndDoEMFRegistration();
	}

	/**
	 * Load Franca Deployment model file (*.fdepl) and all imported files recursively.
	 * 
	 * @param filename  name of FDeploy file (suffix .fdepl is optional)
	 * 
	 * @return the root entity of the FDeploy model
	 */
	public FDModel loadModel(String filename) {
		URI uri =FileHelper.createURI(filename);
		
		if (uri.segmentCount() > 1) {
			return loadModel(uri.lastSegment(), uri.trimSegments(1).toString() + "/");
		} else {
			return loadModel(filename, "");
		}
	}

	/**
	 * Load Franca Deployment model file (*.fdepl) and all imported files recursively.
	 * 
	 * @param uri   URI for Franca deployment file
	 * @param root  the root of the model (needed for loading multiple file models)
	 *              This has to be an absolute, hierarchical URI.
	 * 
	 * @see ModelPersistenceHandler.loadModel, work relatively to a path
	 * @return the root entity of the FDeploy model
	 */
	public FDModel loadModel(URI uri, URI root) {
		ModelPersistenceHandler persistenceHandler = createModelPersistenceHandler(resourceSetProvider.get());
		return (FDModel) persistenceHandler.loadModel(uri, root);
	}

	/**
	 * Load Franca Deployment model file (*.fdepl) and all imported files recursively.
	 * 
	 * @param filename  name of FDeploy file (suffix .fdepl is optional)
	 * @param cwd       file path which is root for all relative paths
	 * 
	 * @see ModelPersistenceHandler.loadModel, work relatively to a path
	 * @return the root entity of the FDeploy model
	 * 
	 * @deprecated Use loadModel(URI uri, URI root) instead.
	 */
	public FDModel loadModel(String filename, String cwd) {
		String fn = filename;
		
		if (fn == null)
			return null;
		if (!fn.endsWith("." + fileExtension)) {
			fn += "." + fileExtension;
		}

		ModelPersistenceHandler persistenceHandler = createModelPersistenceHandler(resourceSetProvider.get());
		return (FDModel) persistenceHandler.loadModel(fn, cwd);
	}

	/**
	 * Save a Franca Deployment model to file (*.fdepl).
	 * 
	 * @param model     the root of model to be saved
	 * @param filename  name of Franca deployment model file (suffix .fdepl is optional)
	 * 
	 * @return true if save could be completed successfully
	 */
	public boolean saveModel(FDModel model, String filename) {
		URI uri = FileHelper.createURI(filename);
		
		if (uri.segmentCount() > 1) {
			return saveModel(model, uri.lastSegment(), uri.trimSegments(1).toString() + "/");
		} else {
			return saveModel(model, filename, "");
		}
	}

	/**
	 * Save a Franca Deployment model to file (*.fdepl).
	 * 
	 * @param model     the root of model to be saved
	 * @param filename  name of Franca deployment model file (suffix .fdepl is optional)
	 * @param cwd       file path which is root for all relative paths
	 * 
	 * @see ModelPersistenceHandler.saveModel, work relatively to a path
	 * @return true if save could be completed successfully
	 */
	public boolean saveModel(FDModel model, String filename, String cwd) {
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

		ModelPersistenceHandler persistenceHandler = createModelPersistenceHandler(resourceSet);
		return persistenceHandler.saveModel(model, fn, cwd);
	}

	
	// TODO: refactor MPH in order to avoid this function
	private ModelPersistenceHandler createModelPersistenceHandler (ResourceSet resourceSet) {
		ModelPersistenceHandler.registerFileExtensionHandler(
				fileExtension,
				new FDeployImportsProvider());
		ModelPersistenceHandler.registerFileExtensionHandler(
				FrancaPersistenceManager.FRANCA_FILE_EXTENSION,
				new FrancaImportsProvider());

		ModelPersistenceHandler persistenceHandler = new ModelPersistenceHandler(resourceSet);
		return persistenceHandler;
	}


}
