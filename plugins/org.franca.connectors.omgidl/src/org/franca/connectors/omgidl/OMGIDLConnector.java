/*******************************************************************************
 * Copyright (c) 2016 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.connectors.omgidl;

import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Set;

import org.csu.idl.idlmm.TranslationUnit;
import org.csu.idl.xtext.loader.ExtendedIDLLoader;
import org.csu.idl.xtext.loader.IDLLoader;
import org.eclipse.emf.common.util.URI;
import org.franca.core.framework.IFrancaConnector;
import org.franca.core.framework.IModelContainer;
import org.franca.core.framework.IssueReporter;
import org.franca.core.framework.TransformationIssue;
import org.franca.core.franca.FModel;
import org.franca.core.utils.FileHelper;

import com.google.inject.Guice;
import com.google.inject.Injector;

public class OMGIDLConnector implements IFrancaConnector {

	private Injector injector;

//	private String fileExtension = "idl";

	private Set<TransformationIssue> lastTransformationIssues = null;

	/** constructor */
	public OMGIDLConnector() {
		injector = Guice.createInjector(new OMGIDLConnectorModule());
	}
	
	@Override
	public IModelContainer loadModel(String filename) {
		TranslationUnit model = loadOMGIDLModel(filename);
		if (model==null) {
			System.out.println("Error: Could not load OMG IDL model from file " + filename);
		} else {
			System.out.println("Loaded OMG IDL interface " + model.getIdentifier());
		}
		return new OMGIDLModelContainer(model);
	}
	
	
	public Map<IModelContainer, String> loadModels(String filename) {
		Map<IModelContainer, String> map_ModelContainer_FileName = new LinkedHashMap<IModelContainer, String>();
		Map<TranslationUnit, String> map_TranslationUnit_FileName = loadOMGIDLModels(filename);
		for (TranslationUnit model : map_TranslationUnit_FileName.keySet() ) {
			if (model==null) {
				System.out.println("Error: Could not load OMG IDL model from file " + filename);
			} else {
				System.out.println("Loaded OMG IDL interface " + model.getIdentifier());
			}
			map_ModelContainer_FileName.put(new OMGIDLModelContainer(model), map_TranslationUnit_FileName.get(model));
		}
		return map_ModelContainer_FileName;
	}

	@Override
	public boolean saveModel(IModelContainer model, String filename) {
		if (! (model instanceof OMGIDLModelContainer)) {
			return false;
		}

		throw new RuntimeException("saveModel method not implemented yet");

//		OMGIDLModelContainer mc = (OMGIDLModelContainer) model;
//		return saveOMGIDLModel(createConfiguredResourceSet(), mc.model(), mc.getComments(), fn);
	}

	
	@Override
	public FModel toFranca(IModelContainer model) {
		if (! (model instanceof OMGIDLModelContainer)) {
			return null;
		}
		
		OMGIDL2FrancaTransformation trafo = injector.getInstance(OMGIDL2FrancaTransformation.class);
		OMGIDLModelContainer omg = (OMGIDLModelContainer)model;
		FModel fmodel = trafo.transform(omg.model());
		
		lastTransformationIssues = trafo.getTransformationIssues();
		System.out.println(IssueReporter.getReportString(lastTransformationIssues));

		return fmodel;
	}

	@Override
	public IModelContainer fromFranca(FModel fmodel) {
		// ranged integer conversion from Franca to OMG IDL as a preprocessing step
//		IntegerTypeConverter.removeRangedIntegers(fmodel, true);

		// do the actual transformation
		throw new RuntimeException("Franca to OMG IDL transformation is not yet implemented");
	}
	
	public Set<TransformationIssue> getLastTransformationIssues() {
		return lastTransformationIssues;
	}
	
//	private ResourceSet createConfiguredResourceSet() {
//		// create new resource set
//		ResourceSet resourceSet = new ResourceSetImpl();
//		
//		// register the appropriate resource factory to handle all file extensions for OMG IDL
//		resourceSet.getResourceFactoryRegistry().getExtensionToFactoryMap().put("idl", new IdlmmResourceFactoryImpl());
//		resourceSet.getPackageRegistry().put(IdlmmPackage.eNS_URI, IdlmmPackage.eINSTANCE);
//		
//		return resourceSet;
//	}
	
	private static TranslationUnit loadOMGIDLModel(String fileName) {
		URI uri = FileHelper.createURI(fileName);
		String filePath = uri.toFileString();

		// TODO: is it correct to use the IDLLoader class (e.g., it does some pre- and postprocessing which might be harmful)?
		// A: Preprocessing is harmful in the case of "#include". Instead of IDLLoader, ExtendedIDLLoader is used, in which prepossing is suppressed.
		IDLLoader loader = new ExtendedIDLLoader();//new IDLLoader();
		try {
			loader.load(filePath);
		} catch (Exception e) {
			e.printStackTrace();
			return null;
		}
		return loader.getModel();
	}
	
	/***
	 * Load the OMG IDL model indicated by {@code fileName} and all the other OMG IDL models included by it
	 * @param fileName 
	 * @return A list of TranslationUnit
	 */
	private static Map<TranslationUnit, String> loadOMGIDLModels(String fileName) {
		URI uri = FileHelper.createURI(fileName);
		String filePath = uri.toFileString();
		ExtendedIDLLoader loader = new ExtendedIDLLoader();
		try {
			loader.load(filePath);
		} catch (Exception e) {
			e.printStackTrace();
			return Collections.emptyMap();
		}
		return loader.getModels();
	}
}

