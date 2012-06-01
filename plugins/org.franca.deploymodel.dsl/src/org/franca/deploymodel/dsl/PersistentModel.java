package org.franca.deploymodel.dsl;

import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;

public class PersistentModel {
	private EObject mModel;
	private String mFilename;
	
	public PersistentModel(EObject model, String filename)
	{
		mModel = model;
		mFilename = filename;
	}
	
	public EObject getModel() {
		return mModel;
	}

	public String getFilename() {
		return mFilename;
	}
}
