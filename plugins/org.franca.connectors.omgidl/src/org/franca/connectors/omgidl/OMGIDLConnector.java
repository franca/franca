/*******************************************************************************
 * Copyright (c) 2016 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.connectors.omgidl;

import java.util.Collections;
import java.util.Map;
import java.util.Set;

import org.csu.idl.idlmm.TranslationUnit;
import org.csu.idl.xtext.loader.ExtendedIDLLoader;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.xtext.xbase.lib.ListExtensions;
import org.franca.core.framework.FrancaModelContainer;
import org.franca.core.framework.IFrancaConnector;
import org.franca.core.framework.IModelContainer;
import org.franca.core.framework.IssueReporter;
import org.franca.core.framework.TransformationIssue;
import org.franca.core.franca.FModel;
import org.franca.core.utils.FileHelper;

import com.google.common.collect.Lists;
import com.google.common.collect.Maps;
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
		Map<TranslationUnit, String> units = loadOMGIDLModel(filename);
		if (units.isEmpty()) {
			System.out.println("Error: Could not load OMG IDL model from file " + filename);
		} else {
			System.out.println("Loaded OMG IDL model from file " + filename + " (consists of " + units.size() + " files)");
		}
//		for(TranslationUnit unit : units.keySet()) {
//			System.out.println("loadModel: " + unit.eResource().getURI() + " is " + units.get(unit));
//		}
		return new OMGIDLModelContainer(units);
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
	public FrancaModelContainer toFranca(IModelContainer model) {
		if (! (model instanceof OMGIDLModelContainer)) {
			return null;
		}
		
		OMGIDL2FrancaTransformation trafo = injector.getInstance(OMGIDL2FrancaTransformation.class);
		OMGIDLModelContainer omg = (OMGIDLModelContainer)model;

		Map<EObject, EObject> transformationMap = Maps.newLinkedHashMap();
		FModel fmodel = trafo.transform(omg.model(), transformationMap);
		transformationMap = trafo.getTransformationMap();
		lastTransformationIssues = trafo.getTransformationIssues();
		System.out.println(IssueReporter.getReportString(lastTransformationIssues));

		return new FrancaModelContainer(fmodel);
	}
	
	/**
	 * Convert a OMG IDL model to Franca.</p>
	 * 
	 * The input model might consist of multiple files. The output might consist of multiple files, too.</p>
	 * 
	 * @param model the input OMG IDL model
	 * @return a sorted map of result models where the first one is the root model.
	 */
	public Map<FModel, String> toFrancas(IModelContainer model) {
		Map<FModel, String> fmodels = Maps.newLinkedHashMap();
		if (! (model instanceof OMGIDLModelContainer)) {
			return fmodels;
		}
		
		OMGIDL2FrancaTransformation trafo = injector.getInstance(OMGIDL2FrancaTransformation.class);
		OMGIDLModelContainer omg = (OMGIDLModelContainer)model;
		Map<EObject, EObject> transformationMap = Maps.newLinkedHashMap();
		for(TranslationUnit unit : ListExtensions.reverseView(omg.models())) {
			//System.out.println("transforming " + omg.getFilename(unit));
			FModel fmodel = trafo.transformToSingleFModel(unit, transformationMap);
			fmodels.put(fmodel, omg.getFilename(unit));
			transformationMap = trafo.getTransformationMap();
			lastTransformationIssues = trafo.getTransformationIssues();
			System.out.println(IssueReporter.getReportString(lastTransformationIssues));
		}

		Map<FModel, String> result = Maps.newLinkedHashMap();
		for(FModel fmodel : ListExtensions.reverseView(Lists.newArrayList(fmodels.keySet()))) {
			result.put(fmodel, fmodels.get(fmodel));
		}
		return result;
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
	
	/***
	 * Load the OMG IDL model indicated by {@code fileName} and all the other OMG IDL models included by it
	 * @param fileName 
	 * @return A list of TranslationUnit
	 */
	private static Map<TranslationUnit, String> loadOMGIDLModel(String fileName) {
		URI uri = FileHelper.createURI(fileName);
		String filePath = uri.toFileString();

		// The preprocessing of IDLLoader will replace all "#include" statements and replace them by the contents of
		// the included file. We do not want this here, because we would like to represent each idl input file as a
		// separate model. Thus, instead of IDLLoader, ExtendedIDLLoader is used, which doesn't do prepocessing.
		//IDLLoader loader = new IDLLoader();
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

