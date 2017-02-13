/** 
 * Copyright (c) 2016 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package org.franca.connectors.omgidl

import java.util.Collections
import java.util.List
import java.util.Map
import java.util.Set
import org.csu.idl.idlmm.TranslationUnit
import org.csu.idl.xtext.loader.ExtendedIDLLoader
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.xtext.xbase.lib.ListExtensions
import org.franca.core.dsl.FrancaPersistenceManager
import org.franca.core.framework.AbstractFrancaConnector
import org.franca.core.framework.FrancaModelContainer
import org.franca.core.framework.IModelContainer
import org.franca.core.framework.IssueReporter
import org.franca.core.framework.TransformationIssue
import org.franca.core.franca.FModel
import org.franca.core.franca.FTypeCollection
import org.franca.core.utils.FileHelper
import com.google.common.collect.Maps
import com.google.common.collect.Sets
import com.google.inject.Guice
import com.google.inject.Injector

class OMGIDLConnector extends AbstractFrancaConnector {
	Injector injector
	
	// private String fileExtension = "idl";
	
	Set<TransformationIssue> lastTransformationIssues = null
	FModel baseModel = null

	/** 
	 * constructor 
	 */
	new() {
		this.injector = Guice.createInjector(new OMGIDLConnectorModule())
	}

	/** 
	 * constructor 
	 */
	new(FModel baseModel) {
		this.injector = Guice.createInjector(new OMGIDLConnectorModule())
		this.baseModel = baseModel
	}

	override IModelContainer loadModel(String filename) {
		var Map<TranslationUnit, String> units = loadOMGIDLModel(filename)
		if (units.isEmpty()) {
			out.println('''Error: Could not load OMG IDL model from file «filename»''')
		} else {
			out.println('''Loaded OMG IDL model from file «filename» (consists of «units.size()» files)''')
		}
		for (TranslationUnit unit : units.keySet()) {
			out.println('''loadModel: «unit.eResource().getURI()» is «units.get(unit)»''')
		}
		return new OMGIDLModelContainer(units)
	}

	override boolean saveModel(IModelContainer model, String filename) {
		if (!(model instanceof OMGIDLModelContainer)) {
			return false
		}
		throw new RuntimeException("saveModel method not implemented yet") // OMGIDLModelContainer mc = (OMGIDLModelContainer) model;
		// return saveOMGIDLModel(createConfiguredResourceSet(), mc.model(), mc.getComments(), fn);
	}

	/** 
	 * Convert a OMG IDL model to Franca.</p>
	 * The input model might consist of multiple files. The output might consist of multiple files, too.</p>
	 * @param model the input OMG IDL model
	 * @return a model container with the resulting root Franca model and some additional information
	 */
	override FrancaModelContainer toFranca(IModelContainer model) {
		if (!(model instanceof OMGIDLModelContainer)) {
			return null
		}
		var OMGIDL2FrancaTransformation trafo = injector.getInstance(OMGIDL2FrancaTransformation)
		var OMGIDLModelContainer omg = model as OMGIDLModelContainer
		var Map<String, EObject> importedModels = Maps.newLinkedHashMap()
		var Map<EObject, EObject> transformationMap = Maps.newLinkedHashMap()
		lastTransformationIssues = Sets.newLinkedHashSet()
		var List<TranslationUnit> inputModels = ListExtensions.reverseView(omg.models())
		var FModel rootModel = null
		var String rootName = null
		for (TranslationUnit unit : inputModels) {
			out.println('''transforming «omg.getFilename(unit)»''')
			var FModel fmodel = trafo.transformToSingleFModel(unit, transformationMap, getBaseTypes())
			transformationMap = trafo.getTransformationMap()
			lastTransformationIssues.addAll(trafo.getTransformationIssues())
			if (trafo.isUsingBaseTypedefs() && baseModel !== null) {
				if (!importedModels.containsKey("OMGIDLBase.fidl")) {
					// FModel baseModelCopy = EcoreUtil.copy(baseModel);
					baseModel.eResource().getContents().clear()
					var Resource rbm = baseModel.eResource()
					importedModels.put("OMGIDLBase.fidl", baseModel)
				}

			}
			if (inputModels.indexOf(unit) === inputModels.size() - 1) {
				// this is the last input model, i.e., the top-most one
				rootModel = fmodel
				rootName = omg.getFilename(unit)
			} else {
				var String importURI = '''«omg.getFilename(unit)».«FrancaPersistenceManager.FRANCA_FILE_EXTENSION»'''
				importedModels.put(importURI, fmodel)
			}
		}
		out.println(IssueReporter.getReportString(lastTransformationIssues))
		return new FrancaModelContainer(rootModel, rootName, importedModels)
	}

	def private FTypeCollection getBaseTypes() {
		if (baseModel === null) {
			return null
		}
		if (baseModel.getTypeCollections() !== null) {
			for (FTypeCollection tc : baseModel.getTypeCollections()) {
				if (tc.getName() === null || tc.getName().isEmpty()) {
					// found anonymous type collection
					return tc
				}

			}

		}
		return null
	}

	override IModelContainer fromFranca(FModel fmodel) {
		// ranged integer conversion from Franca to OMG IDL as a preprocessing step
		// IntegerTypeConverter.removeRangedIntegers(fmodel, true);
		// do the actual transformation
		throw new RuntimeException("Franca to OMG IDL transformation is not yet implemented")
	}

	def Set<TransformationIssue> getLastTransformationIssues() {
		return lastTransformationIssues
	}

	// private ResourceSet createConfiguredResourceSet() {
	// // create new resource set
	// ResourceSet resourceSet = new ResourceSetImpl();
	//
	// // register the appropriate resource factory to handle all file extensions for OMG IDL
	// resourceSet.getResourceFactoryRegistry().getExtensionToFactoryMap().put("idl", new IdlmmResourceFactoryImpl());
	// resourceSet.getPackageRegistry().put(IdlmmPackage.eNS_URI, IdlmmPackage.eINSTANCE);
	//
	// return resourceSet;
	// }

	/** 
	 * Load the OMG IDL model indicated by {@code fileName} and all the other OMG IDL models
	 * included by it.</p>
	 * @param fileName the path and name of the top-level input file 
	 * @return a list of TranslationUnit objects
	 */
	def private static Map<TranslationUnit, String> loadOMGIDLModel(String fileName) {
		var URI uri = FileHelper.createURI(fileName)
		var String filePath = uri.toFileString()
		// The preprocessing of IDLLoader will replace all "#include" statements and replace them by the contents of
		// the included file. We do not want this here, because we would like to represent each idl input file as a
		// separate model. Thus, instead of IDLLoader, ExtendedIDLLoader is used, which doesn't do prepocessing.
		// IDLLoader loader = new IDLLoader();
		var ExtendedIDLLoader loader = new ExtendedIDLLoader()
		try {
			loader.load(filePath)
		} catch (Exception e) {
			e.printStackTrace()
			return Collections.emptyMap()
		}
		return loader.getModels()
	}

}
