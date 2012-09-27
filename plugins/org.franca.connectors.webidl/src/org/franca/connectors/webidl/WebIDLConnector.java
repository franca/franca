package org.franca.connectors.webidl;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.util.Collections;
import java.util.HashMap;

import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;
import org.eclipse.emf.ecore.xmi.XMLResource;
import org.franca.core.framework.IFrancaConnector;
import org.franca.core.framework.IModelContainer;
import org.franca.core.framework.IssueReporter;
import org.franca.core.franca.FModel;
import org.waml.w3c.webidl.WebIDLStandaloneSetup;
import org.waml.w3c.webidl.webIDL.IDLDefinitions;

import com.google.inject.Guice;
import com.google.inject.Injector;


public class WebIDLConnector implements IFrancaConnector {

	private Injector injector;

	private String fileExtension = "xml";

	/** constructor */
	public WebIDLConnector () {
	      injector = Guice.createInjector(new WebIDLConnectorModule());
//	      configureResourceSet();
	}
	
	@Override
	public IModelContainer loadModel (String filename) {
		IDLDefinitions model = loadWebIDLModel(createConfiguredResourceSet(), filename);
		if (model==null) {
			System.out.println("Error: Could not load WebIDL interface from file " + filename);
		} else {
			System.out.println("Loaded WebIDL interface from file " + filename);
		}
		return new WebIDLModelContainer(model); 
	}

	@Override
	public boolean saveModel (IModelContainer model, String filename) {
		if (! (model instanceof WebIDLModelContainer)) {
			return false;
		}

		String fn = filename;
		if (! filename.endsWith("." + fileExtension)) {
			fn += "." + fileExtension;
		}
		
		WebIDLModelContainer mc = (WebIDLModelContainer) model;
		return saveWebIDLModel(createConfiguredResourceSet(), mc.model(), fn);
	}

	
	@Override
	public FModel toFranca (IModelContainer model) {
		if (! (model instanceof WebIDLModelContainer)) {
			return null;
		}
		
		WebIDL2FrancaTransformation trafo = injector.getInstance(WebIDL2FrancaTransformation.class);
		WebIDLModelContainer dbus = (WebIDLModelContainer)model;
		FModel fmodel = trafo.transform(dbus.model());
		System.out.println(IssueReporter.getReportString(trafo.getTransformationIssues()));

		return fmodel;
	}

	@Override
	public IModelContainer fromFranca (FModel fmodel) {
		Franca2WebIDLTransformation trafo = injector.getInstance(Franca2WebIDLTransformation.class);
		IDLDefinitions webidl = trafo.transform(fmodel);
		return new WebIDLModelContainer(webidl);
	}
	
	
	private ResourceSet createConfiguredResourceSet() {
		// create new resource set
		ResourceSet resourceSet = new ResourceSetImpl();
		
		// register the appropriate resource factory to handle all file extensions for Dbus
		// TODO
		WebIDLStandaloneSetup.doSetup();
//		resourceSet.getResourceFactoryRegistry().getExtensionToFactoryMap().put("webidl", new DbusxmlResourceFactoryImpl());
//		resourceSet.getResourceFactoryRegistry().getExtensionToFactoryMap().put(DbusxmlPackage.eNS_URI, DbusxmlPackage.eINSTANCE);
		
		return resourceSet;
	}
	

	
	private static IDLDefinitions loadWebIDLModel (ResourceSet resourceSet, String fileName) {
		Resource resource = resourceSet.createResource(URI.createFileURI(fileName));

		HashMap<String,Object> options = new HashMap<String,Object>();
		try {
			resource.load(options);
		} catch (IOException e) {
			e.printStackTrace();
			//return null;
		}

		return (IDLDefinitions)resource.getContents().get(0);
	}


	private static boolean saveWebIDLModel (ResourceSet resourceSet, IDLDefinitions model, String filename) {
		URI fileURI = URI.createFileURI(new File(filename).getAbsolutePath());
		Resource res = resourceSet.createResource(fileURI);
//		DbusxmlResourceImpl res = (DbusxmlResourceImpl) resourceSet.createResource(fileUri);
//		res.setEncoding("UTF-8");
				
		res.getContents().add(model);
		try {
			res.save(Collections.EMPTY_MAP);
	        System.out.println("Created WebIDL file " + filename);
	        
		} catch (IOException e) {
			e.printStackTrace();
			return false;
		}

		return true;
	}
}
