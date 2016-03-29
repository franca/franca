/*******************************************************************************
 * Copyright (c) 2016 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.connectors.protobuf;

import java.util.Set;

import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.xtext.resource.XtextResource;
import org.eclipse.xtext.resource.XtextResourceSet;
import org.franca.core.framework.IFrancaConnector;
import org.franca.core.framework.IModelContainer;
import org.franca.core.framework.IssueReporter;
import org.franca.core.framework.TransformationIssue;
import org.franca.core.franca.FModel;
import org.franca.core.utils.FileHelper;
import org.franca.deploymodel.dsl.fDeploy.FDModel;

import com.google.eclipse.protobuf.ProtobufStandaloneSetup;
import com.google.eclipse.protobuf.protobuf.Protobuf;
import com.google.inject.Guice;
import com.google.inject.Injector;

public class ProtobufConnector implements IFrancaConnector {

	private Injector injector;

//	private String fileExtension = "xml";

	private Set<TransformationIssue> lastTransformationIssues = null;

	/** constructor */
	public ProtobufConnector () {
		injector = Guice.createInjector(new ProtobufConnectorModule());
	}
	
	@Override
	public IModelContainer loadModel (String filename) {
		Protobuf model = loadProtobufModel(filename);
		if (model==null) {
			System.out.println("Error: Could not load Google Protobuf model from file " + filename);
		} else {
			System.out.println("Loaded Google Protobuf model " + filename);
		}
		return new ProtobufModelContainer(model);
	}

	@Override
	public boolean saveModel (IModelContainer model, String filename) {
		if (! (model instanceof ProtobufModelContainer)) {
			return false;
		}

		throw new RuntimeException("saveModel method not implemented yet");

//		ProtobufModelContainer mc = (ProtobufModelContainer) model;
//		return saveProtobufModel(createConfiguredResourceSet(), mc.model(), mc.getComments(), fn);
	}

	
	@Override
	public FModel toFranca (IModelContainer model) {
		if (! (model instanceof ProtobufModelContainer)) {
			return null;
		}
		
		Protobuf2FrancaTransformation trafo = injector.getInstance(Protobuf2FrancaTransformation.class);
		ProtobufModelContainer dbus = (ProtobufModelContainer)model;
		FModel fmodel = trafo.transform(dbus.model());
		
		lastTransformationIssues = trafo.getTransformationIssues();
		System.out.println(IssueReporter.getReportString(lastTransformationIssues));

		return fmodel;
	}
	
	public CharSequence generateFrancaDeployment(IModelContainer model, String specification, String fidlPath, String fileName){
		if (! (model instanceof ProtobufModelContainer)) {
			return null;
		}
		
		Protobuf2FrancaDeploymentGenerator trafo = injector.getInstance(Protobuf2FrancaDeploymentGenerator.class);
		ProtobufModelContainer dbus = (ProtobufModelContainer)model;
		return trafo.generate(dbus.model(), specification, fidlPath, fileName);
	}

	@Override
	public IModelContainer fromFranca (FModel fmodel) {
		// ranged integer conversion from Franca to D-Bus as a preprocessing step
//		IntegerTypeConverter.removeRangedIntegers(fmodel, true);

		// do the actual transformation
		throw new RuntimeException("Franca to Google Protobuf transformation is not yet implemented");
	}
	
	public Set<TransformationIssue> getLastTransformationIssues() {
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
	

	private static Protobuf loadProtobufModel(String fileName) {
		URI uri = FileHelper.createURI(fileName);

		Injector injector = new ProtobufStandaloneSetup().createInjectorAndDoEMFRegistration();
		XtextResourceSet resourceSet = injector.getInstance(XtextResourceSet.class);
		resourceSet.addLoadOption(XtextResource.OPTION_RESOLVE_ALL, Boolean.TRUE);
		Resource resource = resourceSet.getResource(uri, true);

//		Resource resource = resourceSet.createResource(uri);
//		try {
//			resource.load(Maps.newHashMap());
//		} catch (IOException e) {
//			// TODO Auto-generated catch block
//			e.printStackTrace();
//		}

		if (resource.getContents().isEmpty())
			return null;

		return (Protobuf)resource.getContents().get(0);
	}

}
