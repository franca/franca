/*******************************************************************************
* Copyright (c) 2012 Harman International (http://www.harman.com).
* All rights reserved. This program and the accompanying materials
* are made available under the terms of the Eclipse Public License v1.0
* which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/epl-v10.html
*******************************************************************************/
package org.franca.core.framework;

import java.io.File;
import java.io.IOException;
import java.util.Collections;
import java.util.List;

import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;
import org.franca.core.franca.FAttribute;
import org.franca.core.franca.FBroadcast;
import org.franca.core.franca.FInterface;
import org.franca.core.franca.FMethod;
import org.franca.core.franca.FModel;
import org.franca.core.franca.FStateGraph;
import org.franca.core.franca.FType;
import org.franca.core.franca.FrancaPackage;

import com.google.common.collect.Lists;


public class FrancaHelpers {
	// configuration data
	private ResourceSet resourceSet = null;

	private FrancaHelpers() {
		// register the appropriate resource factory to handle all file extensions for Franca
		@SuppressWarnings("unused")
		FrancaPackage fpackage = FrancaPackage.eINSTANCE;
		
		// now create resourceSet
		resourceSet = new ResourceSetImpl();
	}

	public boolean saveModel (FModel model, String fileName) {
		return saveFrancaModel(resourceSet, model, fileName + ".franca");
	}
	
	
	
	private static boolean saveFrancaModel (ResourceSet resourceSet, FModel model, String filename) {
		URI fileUri = URI.createFileURI(new File(filename).getAbsolutePath());
		Resource res = resourceSet.createResource(fileUri);
		if (res==null) {
	        System.err.println("Franca: model file cannot be saved (resource==null, filename is " + filename + ")");
			return false;
		}
		
		res.getContents().add(model);
		try {
			res.save(Collections.EMPTY_MAP);
	        System.out.println("Created franca model file " + filename);
		} catch (IOException e) {
			e.printStackTrace();
			return false;
		}

		return true;
	}

	
	// *****************************************************************************

	// helpers for model navigation
	
	public static FInterface getEnclosingInterface (EObject obj) {
		EObject x = obj;
		do {
			x = x.eContainer();
			if (x instanceof FInterface)
				return (FInterface)x;
		} while (x!=null);
		return null;
	}
	
	public static FStateGraph getStateGraph (EObject obj) {
		EObject x = obj;
		do {
			x = x.eContainer();
			if (x instanceof FStateGraph)
				return (FStateGraph)x;
		} while (x!=null);
		return null;
	}
	
	/** Get all attributes of an interface including the inherited ones */
	public static List<FAttribute> getAllAttributes (FInterface api) {
		List<FAttribute> elements = Lists.newArrayList();
		if (api.getBase()!=null) {
			elements.addAll(getAllAttributes(api.getBase()));
		}
		elements.addAll(api.getAttributes());
		return elements;
	}
	
	/** Get all methods of an interface including the inherited ones */
	public static List<FMethod> getAllMethods (FInterface api) {
		List<FMethod> elements = Lists.newArrayList();
		if (api.getBase()!=null) {
			elements.addAll(getAllMethods(api.getBase()));
		}
		elements.addAll(api.getMethods());
		return elements;
	}
	
	/** Get all broadcasts of an interface including the inherited ones */
	public static List<FBroadcast> getAllBroadcasts (FInterface api) {
		List<FBroadcast> elements = Lists.newArrayList();
		if (api.getBase()!=null) {
			elements.addAll(getAllBroadcasts(api.getBase()));
		}
		elements.addAll(api.getBroadcasts());
		return elements;
	}
	
	/** Get all broadcasts of an interface including the inherited ones */
	public static List<FType> getAllTypes (FInterface api) {
		List<FType> elements = Lists.newArrayList();
		if (api.getBase()!=null) {
			elements.addAll(getAllTypes(api.getBase()));
		}
		elements.addAll(api.getTypes());
		return elements;
	}
	
	/** Returns true if any of the base interfaces has a contract definition */
	public static Boolean hasBaseContract (FInterface api) {
		if (api.getBase()!=null) {
			return api.getBase().getContract()!=null || hasBaseContract(api.getBase());
		}
		return false;
	}
	

	// *****************************************************************************
	
	// singleton
	private static FrancaHelpers instance = null;
	public static FrancaHelpers instance() {
		if (instance==null) {
			instance = new FrancaHelpers();
		}
		return instance;
	}
}
