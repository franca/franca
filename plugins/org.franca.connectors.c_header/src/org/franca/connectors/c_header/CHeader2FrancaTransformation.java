package org.franca.connectors.c_header;

import org.eclipse.cdt.internal.core.model.TranslationUnit;
import org.franca.core.franca.FModel;

@SuppressWarnings("restriction")
public class CHeader2FrancaTransformation {
	
	public FModel transform(TranslationUnit translationUnit) {
		return CHeaderVisitor.visit(translationUnit);
	}
	
}