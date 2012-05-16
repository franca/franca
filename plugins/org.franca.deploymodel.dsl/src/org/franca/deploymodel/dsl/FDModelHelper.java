/*******************************************************************************
* Copyright (c) 2012 Harman International (http://www.harman.com).
* All rights reserved. This program and the accompanying materials
* are made available under the terms of the Eclipse Public License v1.0
* which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/epl-v10.html
*******************************************************************************/
package org.franca.deploymodel.dsl;

import java.io.File;
import java.io.IOException;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Set;

import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.xtext.Constants;
import org.franca.core.dsl.FrancaIDLStandaloneSetup;
import org.franca.core.framework.FrancaHelpers;
import org.franca.core.framework.ModelFileFinder;
import org.franca.core.franca.FTypeRef;
import org.franca.deploymodel.dsl.fDeploy.FDArgument;
import org.franca.deploymodel.dsl.fDeploy.FDArray;
import org.franca.deploymodel.dsl.fDeploy.FDAttribute;
import org.franca.deploymodel.dsl.fDeploy.FDBroadcast;
import org.franca.deploymodel.dsl.fDeploy.FDDeclaration;
import org.franca.deploymodel.dsl.fDeploy.FDElement;
import org.franca.deploymodel.dsl.fDeploy.FDEnumValue;
import org.franca.deploymodel.dsl.fDeploy.FDEnumeration;
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
import org.franca.deploymodel.dsl.fDeploy.FDStructField;

import com.google.common.collect.Lists;
import com.google.common.collect.Sets;
import com.google.inject.Inject;
import com.google.inject.Injector;
import com.google.inject.Provider;
import com.google.inject.name.Named;

public class FDModelHelper {
	
	@Inject 
	private Provider<ResourceSet> resourceSetProvider;
	
	@Inject @Named(Constants.FILE_EXTENSIONS)
	private String fileExtension;

	/**
	 * Load Franca Deployment model file (*.fdepl) and all imported files recursively.
	 * 
	 * @param fileName name of FDeploy file (suffix .fdepl is optional)
	 * @return the root entity of the FDeploy model
	 */
	public FDModel loadModel (String fileName) {
		String fn = fileName;
		if (! fileName.endsWith("." + fileExtension)) {
			fileName += "." + fileExtension;
		}
		FDModel model = null;
		try {
			model = loadFDeployModel(fn);
		} catch (IOException e) {
			e.printStackTrace();
			return null;
		}
		
		if (model==null) {
			System.out.println("Error: Could not load Franca deployment model from file " + fn);
		} else {
			System.out.println("Loaded Franca deployment model " + fileName);
		}
		return model;
	}
	
	/**
	 * Save a Franca Deployment model to file (*.fdepl).
	 * 
	 * @param model the root of model to be saved
	 * @param fileName name of Franca deployment model file (suffix .fdepl is optional)
	 * @return true if save could be completed successfully
	 */
	public boolean saveModel (FDModel model, String fileName) {
		String fn = fileName;
		if (! fn.endsWith("." + fileExtension)) {
			fn += "." + fileExtension;
		}
		return saveFDeployModel(model, fn);
	}
	
	
	private FDModel loadFDeployModel (String fileName) throws IOException {
		
		// prepare ResourceSet
		ResourceSet resourceSet = resourceSetProvider.get();
		
		// add all existing resources to resourceSet
		File f = new File(fileName);
		String folderName = f.getParentFile().getAbsolutePath();
		//System.out.println("path: " + f.getParentFile().getAbsolutePath());
		List<String> extensions = Lists.newArrayList();
		extensions.add(fileExtension);
		extensions.add("fidl");
		List<String> modelFiles = new ModelFileFinder(extensions).getSourceFiles(folderName);
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
		
		return (FDModel)resource.getContents().get(0);
	}

	
	private boolean saveFDeployModel (FDModel model, String filename) {
		ResourceSet resourceSet = resourceSetProvider.get();
		URI fileUri = URI.createFileURI(new File(filename).getAbsolutePath());
		Resource res = resourceSet.createResource(fileUri);
		res.getContents().add(model);
		try {
			res.save(Collections.EMPTY_MAP);
	        System.out.println("Created Franca deployment model file " + filename);
		} catch (IOException e) {
			e.printStackTrace();
		}
		return true;
	}

	
	// singleton
	private static FDModelHelper instance = null;
	public static FDModelHelper instance() {
		if (instance==null) {
			// register the appropriate resource factory to handle all file extensions for the Franca core model
			new FrancaIDLStandaloneSetup().createInjectorAndDoEMFRegistration();

			Injector injector = new FDeployStandaloneSetup().createInjectorAndDoEMFRegistration();
			instance = injector.getInstance(FDModelHelper.class);
		}
		return instance;
	}


	// *****************************************************************************
	// model navigation

	public static FDModel getModel (EObject obj) {
		EObject x = obj;
		do {
			if (x instanceof FDModel)
				return (FDModel)x;
			x = x.eContainer();
		} while (x!=null);
		return null;
	}

	public static FDRootElement getRootElement (FDElement obj) {
		EObject x = obj;
		do {
			if (x instanceof FDRootElement)
				return (FDRootElement)x;
			x = x.eContainer();
		} while (x!=null);
		return null;
	}

	
	// *****************************************************************************

	public static final List<FDPropertyDecl> getAllPropertyDecls (FDSpecification spec, FDElement elem) {
		Set<FDPropertyHost> hosts = Sets.newHashSet(getMainHost(elem));

		FTypeRef typeRef = null;
		if (elem instanceof FDAttribute) {
			typeRef = ((FDAttribute) elem).getTarget().getType();
		} else if (elem instanceof FDArgument) {
			typeRef = ((FDArgument) elem).getTarget().getType();
		} else if (elem instanceof FDStructField) {
			typeRef = ((FDStructField) elem).getTarget().getType();
		}
		if (typeRef!=null) {
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
		
	public static final List<FDPropertyDecl> getAllPropertyDecls (FDSpecification spec, FDPropertyHost host) {
		Set<FDPropertyHost> hosts = Sets.newHashSet(host);
		return getAllPropertyDeclsHelper(spec, hosts);
	}

	
	private static final List<FDPropertyDecl> getAllPropertyDeclsHelper (FDSpecification spec, Set<FDPropertyHost> hosts)
	{
		List<FDPropertyDecl> properties = Lists.newArrayList();
		if (spec.getBase()!=null) {
			// get declarations from base spec recursively
			properties.addAll(getAllPropertyDeclsHelper(spec.getBase(), hosts));
		}
		
		// get all declarations selected by one member of hosts set
		for(FDDeclaration decl : spec.getDeclarations()) {
			if (hosts.contains(decl.getHost())) {
				properties.addAll(decl.getProperties());
			}
		}
		
		return properties;
	}
	
	
	private static FDPropertyHost getMainHost (FDElement elem) {
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
		} else if (elem instanceof FDStructField) {
			return FDPropertyHost.STRUCT_FIELDS;
		} else if (elem instanceof FDEnumeration) {
			return FDPropertyHost.ENUMERATIONS;
		} else if (elem instanceof FDEnumValue) {
			return FDPropertyHost.ENUMERATORS;
		}
		
		return null;
	}
	

	// *****************************************************************************
	
	public static boolean hasMandatoryProperties (List<FDPropertyDecl> decls) {
		for(FDPropertyDecl decl : decls) {
			if (isMandatory(decl))
				return true;
		}
		return false;
	}
	
	public static boolean isMandatory (FDPropertyDecl decl) {
		for(FDPropertyFlag flag : decl.getFlags()) {
			if (flag.getOptional()!=null || flag.getDefault()!=null) {
				// property declaration is either optional or has a default
				return false;
			}
		}
		return true;
	}
}
