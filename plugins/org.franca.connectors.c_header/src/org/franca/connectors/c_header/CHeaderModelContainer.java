package org.franca.connectors.c_header;

import org.eclipse.cdt.core.model.ITranslationUnit;
import org.franca.core.framework.IModelContainer;

public class CHeaderModelContainer implements IModelContainer {

	private ITranslationUnit translationUnit = null;
	private String fileName;
	
	public CHeaderModelContainer(ITranslationUnit translationUnit, String fileName) {
		this.fileName = fileName;
		this.translationUnit = translationUnit;
	}
	
	public ITranslationUnit getTranslationUnit() {
		return translationUnit;
	}
	
	public String getFileName() {
		return fileName;
	}
}
