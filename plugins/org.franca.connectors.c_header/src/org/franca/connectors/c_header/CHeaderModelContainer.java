package org.franca.connectors.c_header;

import org.eclipse.cdt.internal.core.model.TranslationUnit;
import org.franca.core.framework.IModelContainer;

@SuppressWarnings("restriction")
public class CHeaderModelContainer implements IModelContainer {

	private TranslationUnit translationUnit;
	private StringBuffer contents;
	
	public CHeaderModelContainer(TranslationUnit translationUnit, StringBuffer contents) {
		this.translationUnit = translationUnit;
		this.contents = contents;
	}

	public TranslationUnit getTranslationUnit() {
		return translationUnit;
	}

	public StringBuffer getContents() {
		return contents;
	}
}
