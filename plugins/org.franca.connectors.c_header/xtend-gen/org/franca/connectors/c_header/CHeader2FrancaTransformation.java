package org.franca.connectors.c_header;

import org.eclipse.cdt.core.dom.ast.IASTTranslationUnit;
import org.eclipse.cdt.core.model.ITranslationUnit;
import org.eclipse.core.resources.IFile;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.franca.connectors.c_header.CHeaderASTVisitor;
import org.franca.core.franca.FModel;
import org.franca.core.franca.FrancaFactory;

@SuppressWarnings("all")
public class CHeader2FrancaTransformation {
  public FModel transform(final ITranslationUnit translationUnit, final IFile file) {
    try {
      final FModel model = FrancaFactory.eINSTANCE.createFModel();
      final IASTTranslationUnit ast = translationUnit.getAST();
      CHeaderASTVisitor _cHeaderASTVisitor = new CHeaderASTVisitor(model, file);
      ast.accept(_cHeaderASTVisitor);
      return model;
    } catch (Throwable _e) {
      throw Exceptions.sneakyThrow(_e);
    }
  }
}
