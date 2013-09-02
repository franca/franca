package org.franca.connectors.c_header;

import org.eclipse.cdt.core.model.ITranslationUnit;
import org.eclipse.core.resources.IFile;
import org.franca.core.framework.IModelContainer;

public class CHeaderModelContainer implements IModelContainer {

	private ITranslationUnit translationUnit = null;
	private IFile file;
	
	public CHeaderModelContainer(ITranslationUnit translationUnit, IFile file) {
		this.file = file;
		this.translationUnit = translationUnit;
	}
	
	public ITranslationUnit getTranslationUnit() {
		return translationUnit;
	}
	
	public String getFileName() {
		return file.getName();
	}
	
	public IFile getFile() {
		return file;
	}
}
