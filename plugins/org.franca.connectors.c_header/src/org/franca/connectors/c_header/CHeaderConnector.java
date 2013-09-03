package org.franca.connectors.c_header;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;

import org.eclipse.cdt.core.model.CoreModelUtil;
import org.eclipse.cdt.core.model.ITranslationUnit;
import org.eclipse.cdt.internal.core.model.TranslationUnit;
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

@SuppressWarnings("restriction")
public class CHeaderConnector implements IFrancaConnector {

	private Injector injector;

	// private String fileExtension = "h";

	public CHeaderConnector() {
		injector = Guice.createInjector(new CHeaderConnectorModule());
	}

	@Override
	public IModelContainer loadModel(String fileName) {
		URI fileURI = FileHelper.createURI(fileName);
		IWorkspaceRoot workspaceRoot = ResourcesPlugin.getWorkspace().getRoot();
		Path location = new Path(fileURI.toFileString());
		IFile file = workspaceRoot.getFileForLocation(location);
		ITranslationUnit translationUnit = CoreModelUtil
				.findTranslationUnit(file);
		if (translationUnit == null) {
			return null;
		} else {
			return new CHeaderModelContainer((TranslationUnit) translationUnit,
					null);
		}
	}

	@Override
	public boolean saveModel(IModelContainer model, String fileName) {
		try {
			File header = new File(fileName);
			if (!header.exists()) {
				header.createNewFile();
			}

			CHeaderModelContainer container = (CHeaderModelContainer) model;
			FileWriter fstream = new FileWriter(header);
			BufferedWriter out = new BufferedWriter(fstream);
			out.write(container.getContents().toString());
			out.close();

			return true;
		} catch (IOException e) {
			return false;
		}
	}

	@Override
	public FModel toFranca(IModelContainer model) {
		if (!(model instanceof CHeaderModelContainer)) {
			return null;
		}

		CHeader2FrancaTransformation transformation = injector
				.getInstance(CHeader2FrancaTransformation.class);
		CHeaderModelContainer modelContainer = (CHeaderModelContainer) model;
		return transformation.transform(modelContainer.getTranslationUnit());
	}

	@Override
	public IModelContainer fromFranca(FModel model) {
		if (model != null) {
			Franca2CHeaderTransformation transformation = injector
					.getInstance(Franca2CHeaderTransformation.class);
			StringBuffer sb = transformation.transform(model);
			return new CHeaderModelContainer(null, sb);
		}
		return null;
	}
}
