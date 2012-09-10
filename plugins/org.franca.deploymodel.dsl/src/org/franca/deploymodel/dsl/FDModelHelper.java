/*******************************************************************************
 * Copyright (c) 2012 Harman International (http://www.harman.com).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.deploymodel.dsl;

import java.util.Iterator;
import java.util.List;
import java.util.Set;

import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.xtext.Constants;
import org.franca.core.dsl.FrancaIDLHelpers;
import org.franca.core.dsl.FrancaIDLStandaloneSetup;
import org.franca.core.framework.FrancaHelpers;
import org.franca.core.franca.FTypeRef;
import org.franca.core.utils.ImportsProvider;
import org.franca.core.utils.ModelPersistenceHandler;
import org.franca.deploymodel.dsl.fDeploy.FDArgument;
import org.franca.deploymodel.dsl.fDeploy.FDArray;
import org.franca.deploymodel.dsl.fDeploy.FDAttribute;
import org.franca.deploymodel.dsl.fDeploy.FDBroadcast;
import org.franca.deploymodel.dsl.fDeploy.FDDeclaration;
import org.franca.deploymodel.dsl.fDeploy.FDElement;
import org.franca.deploymodel.dsl.fDeploy.FDEnumValue;
import org.franca.deploymodel.dsl.fDeploy.FDEnumeration;
import org.franca.deploymodel.dsl.fDeploy.FDField;
import org.franca.deploymodel.dsl.fDeploy.FDInterface;
import org.franca.deploymodel.dsl.fDeploy.FDInterfaceInstance;
import org.franca.deploymodel.dsl.fDeploy.FDMethod;
import org.franca.deploymodel.dsl.fDeploy.FDModel;
import org.franca.deploymodel.dsl.fDeploy.FDPropertyDecl;
import org.franca.deploymodel.dsl.fDeploy.FDPropertyFlag;
import org.franca.deploymodel.dsl.fDeploy.FDPropertyHost;
import org.franca.deploymodel.dsl.fDeploy.FDProvider;
import org.franca.deploymodel.dsl.fDeploy.FDRootElement;
import org.franca.deploymodel.dsl.fDeploy.FDSpecification;
import org.franca.deploymodel.dsl.fDeploy.FDStruct;
import org.franca.deploymodel.dsl.fDeploy.Import;

import com.google.common.collect.Lists;
import com.google.common.collect.Sets;
import com.google.inject.Inject;
import com.google.inject.Injector;
import com.google.inject.Provider;
import com.google.inject.name.Named;

public class FDModelHelper implements ImportsProvider {

	@Inject
	@Named(Constants.FILE_EXTENSIONS)
	private String fileExtension;

	public String getFileExtension() {
		return fileExtension;
	}

	@Inject
	private Provider<ResourceSet> resourceSetProvider;

	/**
	 * Load Franca Deployment model file (*.fdepl) and all imported files recursively.
	 * 
	 * @param filename
	 *            name of FDeploy file (suffix .fdepl is optional)
	 * @return the root entity of the FDeploy model
	 */
	public FDModel loadModel(String filename) {
		URI uri = URI.createURI(filename);
		
		if (uri.segmentCount() > 1) {
			return loadModel(uri.lastSegment(), uri.trimSegments(1).toString() + "/");
		} else {
			return loadModel(filename, "");
		}
	}

	/**
	 * Load Franca Deployment model file (*.fdepl) and all imported files recursively.
	 * 
	 * @param filename
	 *            name of FDeploy file (suffix .fdepl is optional)
	 * @param cwd
	 * @see ModelPersistenceHandler.loadModel, work relatively to a path
	 * @return the root entity of the FDeploy model
	 */
	public FDModel loadModel(String filename, String cwd) {
		ModelPersistenceHandler persistenceHandler = new ModelPersistenceHandler(resourceSetProvider.get());
		String fn = filename;
		
		if (fn == null)
			return null;
		if (!fn.endsWith("." + fileExtension)) {
			fn += "." + fileExtension;
		}

		return (FDModel) persistenceHandler.loadModel(fn, cwd);
	}

	/**
	 * Save a Franca Deployment model to file (*.fdepl).
	 * 
	 * @param model
	 *            the root of model to be saved
	 * @param filename
	 *            name of Franca deployment model file (suffix .fdepl is optional)
	 * @return true if save could be completed successfully
	 */
	public boolean saveModel(FDModel model, String filename) {
		URI uri = URI.createURI(filename);
		
		if (uri.segmentCount() > 1) {
			return saveModel(model, uri.lastSegment(), uri.trimSegments(1).toString() + "/");
		} else {
			return saveModel(model, filename, "");
		}
	}

	/**
	 * Save a Franca Deployment model to file (*.fdepl).
	 * 
	 * @param model
	 *            the root of model to be saved
	 * @param filename
	 *            name of Franca deployment model file (suffix .fdepl is optional)
	 * @param cwd
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
		ModelPersistenceHandler persistenceHandler = new ModelPersistenceHandler(resourceSet);

		return persistenceHandler.saveModel(model, fn, cwd);
	}

	// singleton
	private static FDModelHelper instance = null;

	public static FDModelHelper instance() {
		if (instance == null) {
			// register the appropriate resource factory to handle all file extensions for the Franca core model
			new FrancaIDLStandaloneSetup().createInjectorAndDoEMFRegistration();

			Injector injector = new FDeployStandaloneSetup().createInjectorAndDoEMFRegistration();
			instance = injector.getInstance(FDModelHelper.class);
			ModelPersistenceHandler.registerFileExtensionHandler(instance.fileExtension, instance);
			ModelPersistenceHandler.registerFileExtensionHandler(FrancaIDLHelpers.instance().getFileExtension(), FrancaIDLHelpers.instance());
		}
		return instance;
	}

	// *****************************************************************************
	// model navigation

	public static FDModel getModel(EObject obj) {
		EObject x = obj;
		do {
			if (x instanceof FDModel)
				return (FDModel) x;
			x = x.eContainer();
		} while (x != null);
		return null;
	}

	public static FDRootElement getRootElement(FDElement obj) {
		EObject x = obj;
		do {
			if (x instanceof FDRootElement)
				return (FDRootElement) x;
			x = x.eContainer();
		} while (x != null);
		return null;
	}

	// *****************************************************************************

	public static final List<FDPropertyDecl> getAllPropertyDecls(FDSpecification spec, FDElement elem) {
		Set<FDPropertyHost> hosts = Sets.newHashSet(getMainHost(elem));

		FTypeRef typeRef = null;
		if (elem instanceof FDAttribute) {
			typeRef = ((FDAttribute) elem).getTarget().getType();
		} else if (elem instanceof FDArgument) {
			typeRef = ((FDArgument) elem).getTarget().getType();
		} else if (elem instanceof FDField) {
			typeRef = ((FDField) elem).getTarget().getType();
		}
		if (typeRef != null) {
			if (FrancaHelpers.isInteger(typeRef))
				hosts.add(FDPropertyHost.INTEGERS);
			else if (FrancaHelpers.isFloatingPoint(typeRef))
				hosts.add(FDPropertyHost.FLOATS);
			else if (FrancaHelpers.isString(typeRef))
				hosts.add(FDPropertyHost.STRINGS);
		}

		// if looking for INTEGERS or FLOATS, we also look for NUMBERS
		if (hosts.contains(FDPropertyHost.INTEGERS) || hosts.contains(FDPropertyHost.FLOATS))
			hosts.add(FDPropertyHost.NUMBERS);

		return getAllPropertyDeclsHelper(spec, hosts);
	}

	public static final List<FDPropertyDecl> getAllPropertyDecls(FDSpecification spec, FDPropertyHost host) {
		Set<FDPropertyHost> hosts = Sets.newHashSet(host);
		return getAllPropertyDeclsHelper(spec, hosts);
	}

	private static final List<FDPropertyDecl> getAllPropertyDeclsHelper(FDSpecification spec, Set<FDPropertyHost> hosts) {
		List<FDPropertyDecl> properties = Lists.newArrayList();
		if (spec.getBase() != null) {
			// get declarations from base spec recursively
			properties.addAll(getAllPropertyDeclsHelper(spec.getBase(), hosts));
		}

		// get all declarations selected by one member of hosts set
		for (FDDeclaration decl : spec.getDeclarations()) {
			if (hosts.contains(decl.getHost())) {
				properties.addAll(decl.getProperties());
			}
		}

		return properties;
	}

	private static FDPropertyHost getMainHost(FDElement elem) {
		if (elem instanceof FDProvider) {
			return FDPropertyHost.PROVIDERS;
		} else if (elem instanceof FDInterfaceInstance) {
			return FDPropertyHost.INSTANCES;
		} else if (elem instanceof FDInterface) {
			return FDPropertyHost.INTERFACES;
		} else if (elem instanceof FDAttribute) {
			return FDPropertyHost.ATTRIBUTES;
		} else if (elem instanceof FDMethod) {
			return FDPropertyHost.METHODS;
		} else if (elem instanceof FDBroadcast) {
			return FDPropertyHost.BROADCASTS;
		} else if (elem instanceof FDArgument) {
			return FDPropertyHost.ARGUMENTS;
		} else if (elem instanceof FDArray) {
			return FDPropertyHost.ARRAYS;
		} else if (elem instanceof FDField) {
			if (elem.eContainer() instanceof FDStruct)
				return FDPropertyHost.STRUCT_FIELDS;
			else // FDUnion
				return FDPropertyHost.UNION_FIELDS;
		} else if (elem instanceof FDEnumeration) {
			return FDPropertyHost.ENUMERATIONS;
		} else if (elem instanceof FDEnumValue) {
			return FDPropertyHost.ENUMERATORS;
		}

		return null;
	}

	// *****************************************************************************

	public static boolean hasMandatoryProperties(List<FDPropertyDecl> decls) {
		for (FDPropertyDecl decl : decls) {
			if (isMandatory(decl))
				return true;
		}
		return false;
	}

	public static boolean isMandatory(FDPropertyDecl decl) {
		for (FDPropertyFlag flag : decl.getFlags()) {
			if (flag.getOptional() != null || flag.getDefault() != null) {
				// property declaration is either optional or has a default
				return false;
			}
		}
		return true;
	}

	public Iterator<String> importsIterator(EObject model) {
		if (!(model instanceof FDModel))
			return null;
		final FDModel fdModel = (FDModel) model;
		
		return new Iterator<String>(){
			Iterator<Import> it = fdModel.getImports().iterator();

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
