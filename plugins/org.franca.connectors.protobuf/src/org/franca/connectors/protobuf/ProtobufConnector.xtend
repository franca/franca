/*******************************************************************************
 * Copyright (c) 2016 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.connectors.protobuf

import com.google.eclipse.protobuf.ProtobufStandaloneSetup
import com.google.eclipse.protobuf.protobuf.Import
import com.google.eclipse.protobuf.protobuf.Protobuf
import com.google.eclipse.protobuf.scoping.IFileUriResolver
import com.google.eclipse.protobuf.scoping.ProtoDescriptorProvider
import com.google.inject.Guice
import com.google.inject.Injector
import java.util.ArrayList
import java.util.List
import java.util.Map
import java.util.Set
import org.apache.log4j.Logger
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.resource.XtextResourceSet
import org.franca.core.dsl.FrancaPersistenceManager
import org.franca.core.framework.AbstractFrancaConnector
import org.franca.core.framework.FrancaModelContainer
import org.franca.core.framework.IModelContainer
import org.franca.core.framework.IssueReporter
import org.franca.core.framework.TransformationIssue
import org.franca.core.franca.FModel
import org.franca.core.franca.FType
import org.franca.core.utils.FileHelper
import org.franca.core.utils.digraph.Digraph

public class ProtobufConnector extends AbstractFrancaConnector {

	static final Logger logger = Logger.getLogger(typeof(ProtobufConnector))

	boolean normalizeIds
	Injector injector

	//private String fileExtension = "proto";
		
	var Set<TransformationIssue> lastTransformationIssues = null

	/** constructor */
	new() {
		this(false)
	}

	/** constructor */
	new(boolean normalizeIds) {
		this.normalizeIds = normalizeIds
		this.injector = Guice.createInjector(new ProtobufConnectorModule())
	}

	override IModelContainer loadModel(String filename) {
		val Map<Protobuf, String> units = loadProtobufModel(filename);
		if (units.isEmpty()) {
			logError("Error: Could not load Protobuf model from file " + filename);
		} else {
			logInfo("Loaded Protobuf model from file " + filename + " (consists of " + units.size() + " files)");
		}
		for(Protobuf unit : units.keySet()) {
			val res = unit.eResource
			//logInfo("loadModel: " + res.getURI() + " is " + units.get(unit));
		}
		return new ProtobufModelContainer(units);
	}

	override boolean saveModel(IModelContainer model, String filename) {
		if (! (model instanceof ProtobufModelContainer)) {
			return false;
		}

		throw new RuntimeException("saveModel method not implemented yet");

	//		ProtobufModelContainer mc = (ProtobufModelContainer) model;
	//		return saveProtobufModel(createConfiguredResourceSet(), mc.model(), mc.getComments(), fn);
	}

	/**
	 * Convert a Protobuf model to Franca.</p>
	 * 
	 * The input model might consist of multiple files. The output might consist of multiple files, too.</p>
	 * 
	 * @param model the input Protobuf model
	 * @return a model container with the resulting root Franca model and some additional information
	 */
	override FrancaModelContainer toFranca(IModelContainer model) {
		if (! (model instanceof ProtobufModelContainer)) {
			return null;
		}

		val Protobuf2FrancaTransformation trafo = injector.getInstance(Protobuf2FrancaTransformation)
		trafo.normalizeIds = normalizeIds
		
		val ProtobufModelContainer proto = model as ProtobufModelContainer
		val Map<String, EObject> importedModels = newLinkedHashMap

		var Map<EObject, FType> externalTypes = newHashMap
		lastTransformationIssues = newLinkedHashSet
		val inputModels = ListExtensions.reverseView(proto.models)

		// first check if we need to transform "descriptor.proto"
		if (inputModels.findFirst[trafo.needsDescriptorInclude(it)]!=null) {
			val provider = protobufInjector.getInstance(ProtoDescriptorProvider);
			val descriptorProto = provider.primaryDescriptor
			val descriptorModel = descriptorProto.resource.contents.get(0) as Protobuf
			
			val fmodel = trafo.transform(descriptorModel, externalTypes)
			externalTypes = trafo.getExternalTypes
			lastTransformationIssues.addAll(trafo.getTransformationIssues)
			importedModels.put("descriptor.fidl", fmodel)
		}

		// now transform actual input models (sorted from bottom to top in the import graph)
		var FModel rootModel = null
		var String rootName = null
		for(item : inputModels) {
//			println("toFranca: input model " + item.elements)
			val fmodel = trafo.transform(item, externalTypes)
			externalTypes = trafo.getExternalTypes
			lastTransformationIssues.addAll(trafo.getTransformationIssues)

			if (inputModels.indexOf(item) == inputModels.size-1) {
				// this is the last input model, i.e., the top-most one
				rootModel = fmodel;
				rootName = proto.getFilename(item)
//				println("toFranca: primary output model " + rootName)
			} else {
				val String importURI =
						proto.getFilename(item) + "." + FrancaPersistenceManager.FRANCA_FILE_EXTENSION;
//				println("toFranca: secondary output model " + importURI)
				importedModels.put(importURI, fmodel)
			}
		}
		
		val report = IssueReporter.getReportString(lastTransformationIssues).split("\n")
		for(r : report) {
			logger.info(r);
		}
		
		return new FrancaModelContainer(rootModel, rootName, importedModels)
	}

	def CharSequence generateFrancaDeployment(IModelContainer model, String specification, String fidlPath,
		String fileName) {
		if (! (model instanceof ProtobufModelContainer)) {
			return null;
		}

		val Protobuf2FrancaDeploymentGenerator trafo = injector.getInstance(Protobuf2FrancaDeploymentGenerator);
		val ProtobufModelContainer dbus = model as ProtobufModelContainer;
		return trafo.generate(dbus.model(), specification, fidlPath, fileName);
	}

	override IModelContainer fromFranca(FModel fmodel) {

		// ranged integer conversion from Franca to D-Bus as a preprocessing step
		//		IntegerTypeConverter.removeRangedIntegers(fmodel, true);
		// do the actual transformation
		throw new RuntimeException("Franca to Google Protobuf transformation is not yet implemented");
	}

	def Set<TransformationIssue> getLastTransformationIssues() {
		return lastTransformationIssues;
	}

	//	private ResourceSet createConfiguredResourceSet() {
	//		// create new resource set
	//		ResourceSet resourceSet = new ResourceSetImpl();
	//		
	//		// register the appropriate resource factory to handle all file extensions for Google Protobuf
	//		resourceSet.getResourceFactoryRegistry().getExtensionToFactoryMap().put("xml", new ProtobufResourceFactoryImpl());
	//		resourceSet.getPackageRegistry().put(ProtobufPackage.eNS_URI, ProtobufPackage.eINSTANCE);
	//		
	//		return resourceSet;
	//	}
	
	val Map<Protobuf, String> part2import = newLinkedHashMap
	
	var private Injector injectorProtobuf = null;

	def private getProtobufInjector() {
		if (injectorProtobuf==null) {
			injectorProtobuf = new ProtobufStandaloneSetup().createInjectorAndDoEMFRegistration
		}
		injectorProtobuf
	}

	def private Map<Protobuf, String> loadProtobufModel(String fileName) {
		
		// we are using a member table to collect the importURI string for all resources
		// TODO: this is clumsy, improve
		part2import.clear
		
		val URI uri = FileHelper.createURI(fileName)

		val fileUriResolver = protobufInjector.getInstance(IFileUriResolver)
		val XtextResourceSet resourceSet = protobufInjector.getInstance(XtextResourceSet)
		//resourceSet.addLoadOption(XtextResource.OPTION_RESOLVE_ALL, Boolean.TRUE)
		val Resource resource = resourceSet.getResource(uri, true)

		if (resource.getContents().isEmpty())
			return null;

		val root = resource.getContents().get(0) as Protobuf
		part2import.put(root, uri.lastSegment.trimExtension(uri.fileExtension))

		val modelURIs = root.collectImportURIsAndLoadModels(uri, resourceSet, fileUriResolver)
		if (modelURIs.empty) {
			return #[ root ].convert(part2import)
		}

		val digraph = new Digraph => [
			modelURIs.forEach [ p1, p2 |
				p2.forEach [ importUri |
					addEdge(p1, importUri.toString)
				]
			]
		]
		val topoModels = digraph.topoSort
		val models = topoModels.map[resourceSet.getResource(URI.createURI(it), false)?.contents?.head as Protobuf]
		models.convert(part2import)
	}

	def private convert(List<Protobuf> models, Map<Protobuf,String> part2import) {
		val result = models.toInvertedMap[part2import.get(it)]
		result
	}

	def private Map<String, ArrayList<URI>> collectImportURIsAndLoadModels(
		Protobuf model,
		URI importingURI,
		XtextResourceSet resourceSet,
		IFileUriResolver fileUriResolver
	) {
		//val baseURI = importingURI.trimSegments(1)
		val modelURIs = newHashMap
		val key = model.eResource.URI.toString
		for(import_ : model.elements.filter(Import)) {
			if (import_.importURI != ProtoDescriptorProvider.PROTO_DESCRIPTOR_URI) {
				val importURIOriginal = URI.createURI(import_.importURI)
				fileUriResolver.resolveAndUpdateUri(import_)
				val importURI = URI.createURI(import_.importURI)
	
				var list = modelURIs.get(key)
				if (list == null) {
					list = <URI>newArrayList
					modelURIs.put(key, list)
				}
				list.add(importURI)
				val importResource = resourceSet.getResource(importURI, true)
				if (importResource != null) {
					if (! importResource.contents.empty) {
						val pmodel = importResource.contents.head as Protobuf
						val trimmed = importURIOriginal.toFileString.trimExtension(importingURI.fileExtension)

						// only recurse if not visited already (this will eliminate and duplicate imports cycles)
						if (! part2import.containsKey(pmodel)) {
							part2import.put(pmodel, trimmed)
							modelURIs.putAll(pmodel.collectImportURIsAndLoadModels(importURI, resourceSet, fileUriResolver))
						}
					}
				} else {
					logError("Warning: Cannot import resource '" + importURI + "'")
				}
			}

		}
		return modelURIs
	}
	
	def private trimExtension(String filename, String ext) {
		val dotIndex = filename.lastIndexOf(ext) - 1
		filename.substring(0, dotIndex)
	}
	
	def private logInfo(String msg) {
		if (out==System.out) {
			logger.info(msg)
		} else {
			out.println(msg)
		}
	}

	def private logError(String msg) {
		if (err==System.err) {
			logger.error(msg)
		} else {
			err.println(msg)
		}
	}
}
