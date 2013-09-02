package org.franca.connectors.c_header;

import org.eclipse.cdt.core.model.CoreModelUtil;
import org.eclipse.cdt.core.model.ITranslationUnit;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IWorkspaceRoot;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.Path;
import org.eclipse.emf.common.util.URI;
import org.franca.core.framework.IFrancaConnector;
import org.franca.core.framework.IModelContainer;
import org.franca.core.franca.FModel;
import org.franca.core.utils.FileHelper;

import com.google.inject.Guice;
import com.google.inject.Injector;

public class CHeaderConnector implements IFrancaConnector {

	private Injector injector;
	
	//private String fileExtension = "h";
	
	public CHeaderConnector () {
		injector = Guice.createInjector(new CHeaderConnectorModule());
	}
	
	@Override
	public IModelContainer loadModel(String fileName) {
		URI fileURI = FileHelper.createURI(fileName);
		IWorkspaceRoot workspaceRoot = ResourcesPlugin.getWorkspace().getRoot();
		Path location = new Path(fileURI.toFileString());
		IFile file = workspaceRoot.getFileForLocation(location);
		ITranslationUnit translationUnit = CoreModelUtil.findTranslationUnit(file);
		if (translationUnit == null) {
			return null;
		}
		else {
			return new CHeaderModelContainer(translationUnit, file);
		}
	}

	@Override
	public boolean saveModel (IModelContainer model, String filename) {
		return false;
	}

	@Override
	public FModel toFranca(IModelContainer model) {
		if (! (model instanceof CHeaderModelContainer)) {
			return null;
		}
		
		CHeader2FrancaTransformation transformation = injector.getInstance(CHeader2FrancaTransformation.class);
		CHeaderModelContainer modelContainer = (CHeaderModelContainer) model;
		
		return transformation.transform(modelContainer.getTranslationUnit(), modelContainer.getFile());
	}

	@Override
	public IModelContainer fromFranca(FModel fmodel) {
		
		return null;
	}


}
