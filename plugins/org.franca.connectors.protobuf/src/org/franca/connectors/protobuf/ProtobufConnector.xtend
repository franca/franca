package org.franca.connectors.protobuf

/*******************************************************************************
 * Copyright (c) 2016 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
import com.google.eclipse.protobuf.ProtobufStandaloneSetup
import com.google.eclipse.protobuf.protobuf.Import
import com.google.eclipse.protobuf.protobuf.Protobuf
import com.google.inject.Guice
import com.google.inject.Injector
import java.util.ArrayList
import java.util.Map
import java.util.Set
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.resource.XtextResource
import org.eclipse.xtext.resource.XtextResourceSet
import org.franca.core.framework.IFrancaConnector
import org.franca.core.framework.IModelContainer
import org.franca.core.framework.IssueReporter
import org.franca.core.framework.TransformationIssue
import org.franca.core.franca.FModel
import org.franca.core.franca.FType
import org.franca.core.utils.FileHelper
import org.franca.core.utils.digraph.Digraph

public class ProtobufConnector implements IFrancaConnector {

	private var Injector injector

	//	private String fileExtension = "xml";
	private var Set<TransformationIssue> lastTransformationIssues = null

	/** constructor */
	new() {
		injector = Guice.createInjector(new ProtobufConnectorModule())
	}

	override IModelContainer loadModel(String filename) {
		val Protobuf model = loadProtobufModel(filename);
		if (model == null) {
			System.out.println("Error: Could not load Google Protobuf model from file " + filename);
		} else {
			System.out.println("Loaded Google Protobuf model " + filename);
		}
		return new ProtobufModelContainer(model);
	}

	def Iterable<ProtobufModelContainer> loadModels(String filename) {
		val models = loadProtobufModels(filename);
		if (models == null || models.empty) {
			System.out.println("Error: Could not load Google Protobuf model from file " + filename);
		} else {
			models.forEach[
				System.out.println(
					"Loaded Google Protobuf model " + it.eResource.URI.lastSegment.toString
				)]
		}
		val containers = newLinkedList
		containers += models.map[new ProtobufModelContainer(it, it.eResource.URI.trimFileExtension.lastSegment)]
		return containers
	}

	override boolean saveModel(IModelContainer model, String filename) {
		if (! (model instanceof ProtobufModelContainer)) {
			return false;
		}

		throw new RuntimeException("saveModel method not implemented yet");

	//		ProtobufModelContainer mc = (ProtobufModelContainer) model;
	//		return saveProtobufModel(createConfiguredResourceSet(), mc.model(), mc.getComments(), fn);
	}

	override FModel toFranca(IModelContainer model) {
		if (! (model instanceof ProtobufModelContainer)) {
			return null;
		}

		val Protobuf2FrancaTransformation trafo = injector.getInstance(Protobuf2FrancaTransformation);
		val ProtobufModelContainer dbus = model as ProtobufModelContainer;
		val FModel fmodel = trafo.transform(dbus.model(), newHashMap);

		lastTransformationIssues = trafo.getTransformationIssues();
		System.out.println(IssueReporter.getReportString(lastTransformationIssues));

		return fmodel;
	}

	def Iterable<FModel> toFrancas(Iterable<ProtobufModelContainer> models) {
		val fmodels = newLinkedList
		val Map<String, FType> externalTypes = newHashMap
		models.forEach [ model |
			if (model instanceof ProtobufModelContainer) {
				val Protobuf2FrancaTransformation trafo = injector.getInstance(Protobuf2FrancaTransformation);
				val ProtobufModelContainer dbus = model as ProtobufModelContainer;
				val FModel fmodel = trafo.transform(dbus.model(), externalTypes);
				fmodel.typeCollections?.head?.types?.forEach [ type |
					externalTypes.put(dbus.model.eResource.URI.trimFileExtension.toString + "_" + type.name.toFirstUpper,
						type) //TODO use packagename + fileName
				]
				lastTransformationIssues = trafo.getTransformationIssues();
				System.out.println(IssueReporter.getReportString(lastTransformationIssues));
				fmodels += fmodel
			}
		]
		return fmodels
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
	private def static Iterable<Protobuf> loadProtobufModels(String fileName) {
		val URI uri = FileHelper.createURI(fileName)

		val injector = new ProtobufStandaloneSetup().createInjectorAndDoEMFRegistration
		val XtextResourceSet resourceSet = injector.getInstance(XtextResourceSet)
		resourceSet.addLoadOption(XtextResource.OPTION_RESOLVE_ALL, Boolean.TRUE)
		val Resource resource = resourceSet.getResource(uri, true)

		if (resource.getContents().isEmpty())
			return null;

		val root = resource.getContents().get(0) as Protobuf
		val modelURIs = root.collectImportURIsAndLoadModels(resourceSet)
		if (modelURIs.empty)
			return #[root]
		val digraph = new Digraph => [
			modelURIs.forEach [ p1, p2 |
				p2.forEach [ importUri |
					addEdge(p1, importUri.toString)
				]
			]
		]
		val topoModels = digraph.topoSort.reverseView
		return topoModels.map[resourceSet.getResource(URI.createURI(it), false)?.contents?.head as Protobuf]
	}

	private def static Map<String, ArrayList<URI>> collectImportURIsAndLoadModels(Protobuf model,
		XtextResourceSet resourceSet) {
		val modelURIs = newHashMap
		model.elements.filter(Import).forEach [ import |
			val importURI = URI.createURI(import.importURI)
			//TODO cyclic detect 
			var list = modelURIs.get(model.eResource.URI.toString)
			if (list == null) {
				list = <URI>newArrayList
				modelURIs.put(model.eResource.URI.toString, list)
			}
			list.add(importURI)
			val importResource = resourceSet.getResource(importURI, false)
			if (!importResource?.contents.empty) {
				val pmodel = importResource.contents.head as Protobuf
				modelURIs.putAll(pmodel.collectImportURIsAndLoadModels(resourceSet))
			}
		]
		return modelURIs
	}

	private def static Protobuf loadProtobufModel(String fileName) {
		val URI uri = FileHelper.createURI(fileName);

		val injector = new ProtobufStandaloneSetup().createInjectorAndDoEMFRegistration();
		val XtextResourceSet resourceSet = injector.getInstance(XtextResourceSet);
		resourceSet.addLoadOption(XtextResource.OPTION_RESOLVE_ALL, Boolean.TRUE);
		val Resource resource = resourceSet.getResource(uri, true);

		//		Resource resource = resourceSet.createResource(uri);
		//		try {
		//			resource.load(Maps.newHashMap());
		//		} catch (IOException e) {
		//			// TODO Auto-generated catch block
		//			e.printStackTrace();
		//		}
		if (resource.getContents().isEmpty())
			return null;

		return resource.getContents().get(0) as Protobuf
	}

}
