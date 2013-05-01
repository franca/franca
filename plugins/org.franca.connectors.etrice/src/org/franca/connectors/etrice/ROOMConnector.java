/*******************************************************************************
 * Copyright (c) 2012 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.connectors.etrice;

import java.io.File;
import java.io.IOException;
import java.util.Collections;

import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.etrice.core.RoomStandaloneSetup;
import org.eclipse.etrice.core.room.RoomModel;
import org.franca.connectors.etrice.internal.Franca2ETriceTransformation;
import org.franca.core.framework.IFrancaConnector;
import org.franca.core.framework.IModelContainer;
import org.franca.core.franca.FModel;

import com.google.inject.Inject;
import com.google.inject.Provider;


/**
 * Connector class for transforming Franca <=> ROOM (for eTrice).
 * 
 * @author birken
 */
public class ROOMConnector implements IFrancaConnector {

	@Inject Provider<ResourceSet> resourceSetProvider;
	@Inject Franca2ETriceTransformation trafo;

	private ResourceSet resourceSet = null;
	
	private String uriModellib = null;

	/** default constructor */
	public ROOMConnector() {
		new RoomStandaloneSetup().createInjectorAndDoEMFRegistration();
	}
	
	public void setModellibFolder (String uri) {
		uriModellib = uri;
	}
	
	@Override
	public IModelContainer loadModel (String filename) {
		// TODO not supported yet
		return null;
	}

	@Override
	public boolean saveModel (IModelContainer model, String filename) {
		if (! (model instanceof ROOMModelContainer)) {
			return false;
		}
		
		ROOMModelContainer rmc = (ROOMModelContainer) model;
		return saveRoomModel(rmc.model(), filename);
	}

	
	@Override
	public FModel toFranca (IModelContainer model) {
		// TODO not supported yet
		return null;
	}

	@Override
	public IModelContainer fromFranca (FModel fmodel) {
		RoomModel room = trafo.transform(fmodel, uriModellib, getResourceSet());
		return new ROOMModelContainer(room);
	}

	
	private boolean saveRoomModel (RoomModel model, String fileName) {
		URI fileUri = URI.createFileURI(new File(fileName).getAbsolutePath());
		Resource res = getResourceSet().createResource(fileUri);
		res.getContents().add(model);
		try {
			res.save(Collections.EMPTY_MAP);
	        System.out.println("Created ROOM model file " + fileName);
		} catch (IOException e) {
			e.printStackTrace();
			return false;
		}

		return true;
	}
	
	private ResourceSet getResourceSet() {
		if (resourceSet==null) {
			resourceSet = resourceSetProvider.get();
		}
		return resourceSet;
	}
}
