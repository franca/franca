/*******************************************************************************
 * Copyright (c) 2012 Harman International (http://www.harman.com).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.core.dsl;

import java.util.Iterator;

import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.xtext.Constants;
import org.franca.core.franca.FModel;
import org.franca.core.franca.Import;
import org.franca.core.utils.ImportsProvider;
import org.franca.core.utils.ModelPersistenceHandler;

import com.google.inject.Inject;
import com.google.inject.Injector;
import com.google.inject.Provider;
import com.google.inject.name.Named;

public class FrancaIDLHelpers implements ImportsProvider {

	@Inject
	private Provider<ResourceSet> resourceSetProvider;

	@Inject
	@Named(Constants.FILE_EXTENSIONS)
	private String fileExtension;

	public String getFileExtension() {
		return fileExtension;
	}

	/**
	 * Load Franca IDL model file (*.fidl) and all imported files recursively.
	 * 
	 * @param filename
	 *            name of Franca file (suffix .fidl is optional)
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
	 * Workaround: createFileURI is platform-dependent and doesn't work
	 * for absolute paths on Unix and MacOS. This function provides 
	 * createURI from file paths for Unix, MacOS and Windows.
	 */
	private URI createURI (String filename) {
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
		// ... otherwise it is a platform resource uri
		else {
			return URI.createPlatformResourceURI(filename, true);
		}
	}
	
	
	/**
	 * Recursive helper function.
	 * 
	 * @param model
	 * @param filename
	 * @param persistenceHandler
	 * @return
	 */
	public FModel loadModel(String filename, String cwd) {
		ModelPersistenceHandler persistenceHandler = new ModelPersistenceHandler(resourceSetProvider.get());
		String fn = filename;

		if (fn == null)
			return null;
		if (!fn.endsWith("." + fileExtension)) {
			fn += "." + fileExtension;
		}

		return (FModel) persistenceHandler.loadModel(fn, cwd);
	}

	/**
	 * Save a Franca IDL model to file (*.fidl).
	 * 
	 * @param model
	 *            the root of model to be saved
	 * @param filename
	 *            name of Franca file (suffix .fidl is optional)
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
	 * @param model
	 *            the root of model to be saved
	 * @param filename
	 *            name of Franca file (suffix .fidl is optional)
	 * @param cwd
	 *            if not null work relatively to this path
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
		ModelPersistenceHandler persistenceHandler = new ModelPersistenceHandler(resourceSet);

		return persistenceHandler.saveModel(model, fn, cwd);
	}

	// singleton
	private static FrancaIDLHelpers instance = null;

	public static FrancaIDLHelpers instance() {
		if (instance == null) {
			Injector injector = new FrancaIDLStandaloneSetup().createInjectorAndDoEMFRegistration();
			instance = injector.getInstance(FrancaIDLHelpers.class);
			ModelPersistenceHandler.registerFileExtensionHandler(instance.fileExtension, instance);
		}
		return instance;
	}

	public Iterator<String> importsIterator(EObject model) {
		if (!(model instanceof FModel))
			return null;
		final FModel idlModel = (FModel) model;
		
		return new Iterator<String>(){
			Iterator<Import> it = idlModel.getImports().iterator();

			public boolean hasNext() {
				return it.hasNext();
			}

			public String next() {
				return it.next().getImportURI();
			}

			public void remove() {
				//operation not allowed
			}
		};
	}
}
