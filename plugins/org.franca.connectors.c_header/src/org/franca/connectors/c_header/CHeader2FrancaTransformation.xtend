package org.franca.connectors.c_header

import org.eclipse.cdt.core.model.ITranslationUnit
import org.eclipse.core.resources.IFile
import org.franca.core.franca.FModel
import org.franca.core.franca.FrancaFactory

class CHeader2FrancaTransformation {
	
	def FModel transform(ITranslationUnit translationUnit, IFile file) {
		val model = FrancaFactory::eINSTANCE.createFModel;
		val ast = translationUnit.AST;
		ast.accept(new CHeaderASTVisitor(model, file));
		return model;
	}
	
}