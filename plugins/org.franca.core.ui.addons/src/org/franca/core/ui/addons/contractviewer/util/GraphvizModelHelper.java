/*******************************************************************************
 * Copyright (c) 2012 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.core.ui.addons.contractviewer.util;

import java.io.File;
import java.io.IOException;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IFolder;
import org.franca.core.franca.FInterface;
import org.franca.core.franca.FModel;
import org.franca.core.franca.FState;
import org.franca.core.franca.FTransition;

public class GraphvizModelHelper {

	/**
	 * Returns the corresponding .dot file for the Franca fidl file. 
	 * Precondition: the generated .dot file is present in the src-gen folder of the corresponding project. 
	 * 
	 * @param file the fidl file instance
	 * @return the .dot file instance
	 */
	public static IFile getDotFile(IFile file) {
		if (file != null) {
			IFolder folder = file.getProject().getFolder("src-gen");
			if (folder.exists()) {
				IFile dotFile = folder.getFile(file.getName()+".dot");
				if (dotFile.exists()) {
					return dotFile;
				}
			}
		}
		return null;
	}
	
	public static byte[] getDotImage(IFile dotFile) {
		IFolder folder = dotFile.getProject().getFolder("src-gen");
		File file = new File(folder.getRawLocation().makeAbsolute().toString());
		String absoluteFilePath = dotFile.getRawLocation().makeAbsolute().toString();
		try {
			Runtime.getRuntime().exec("dot -Tpng "+absoluteFilePath+" -o "+absoluteFilePath+".png", null, file);
		} catch (IOException e) {
			e.printStackTrace();
		}
		return null;
	}
	
	public static Map<FState, Set<FTransition>> getBackwardIndex(FModel model) {
		Map<FState, Set<FTransition>> map = new HashMap<FState, Set<FTransition>>();
		
		for (FInterface _interface : model.getInterfaces()) {
			if (_interface.getContract() != null) {
				for (FState state : _interface.getContract().getStateGraph().getStates()) {
					for (FTransition transition : state.getTransitions()) {
						FState target = transition.getTo();
						Set<FTransition> transitions = map.get(target);
						if (transitions == null) {
							transitions = new HashSet<FTransition>();
						}
						transitions.add(transition);
						map.put(target, transitions);
					}
				}
			}
		}
		
		return map;
	}
	
//	public static GraphvizModel parseFile(IFile file) {
//		ISetup setup = new GraphvizDotStandaloneSetupGenerated(); 
//        Injector injector = setup.createInjectorAndDoEMFRegistration();
//        XtextResourceSet rs = injector.getInstance(XtextResourceSet.class);
//        rs.setClasspathURIContext(GraphvizModelParser.class);
//
//        IResourceFactory resourceFactory = injector.getInstance(IResourceFactory.class);
//        URI uri = URI.createURI(file.getName()); 
//        XtextResource resource = (XtextResource) resourceFactory.createResource(uri);
//        rs.getResources().add(resource);
//
//        try {
//        	InputStream in = file.getContents();
//        	resource.load(in, null);
//        	EcoreUtil.resolveAll(resource);
//        }
//        catch (CoreException e) {
//        	e.printStackTrace();
//        	return null;
//        } 
//        catch (IOException e) {
//        	e.printStackTrace();
//        	return null;
//		}
//        if (!resource.getErrors().isEmpty()) {
//        	return null;
//        }
//        else {
//        	return (GraphvizModel) resource.getParseResult().getRootASTElement();
//        }
//	}
	
}
