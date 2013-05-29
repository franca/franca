package org.franca.connectors.c_header;

import org.eclipse.cdt.core.dom.ast.ASTVisitor;
import org.eclipse.cdt.core.dom.ast.IASTDeclSpecifier;
import org.eclipse.cdt.core.dom.ast.IASTDeclaration;
import org.eclipse.cdt.core.dom.ast.IASTDeclarator;
import org.eclipse.cdt.core.dom.ast.IASTParameterDeclaration;
import org.eclipse.cdt.internal.core.dom.parser.c.CASTFunctionDeclarator;
import org.eclipse.cdt.internal.core.dom.parser.c.CASTSimpleDeclSpecifier;
import org.eclipse.cdt.internal.core.dom.parser.c.CASTSimpleDeclaration;
import org.franca.core.franca.FInterface;
import org.franca.core.franca.FMethod;
import org.franca.core.franca.FModel;
import org.franca.core.franca.FrancaFactory;

@SuppressWarnings("restriction")
public class CHeaderASTVisitor extends ASTVisitor {
	
	private String fileName;
	private String fileNameLastSegment;
	private FModel model;
	
	public CHeaderASTVisitor(FModel model, String fileName) {
		this.shouldVisitDeclarations = true;
		this.shouldVisitDeclSpecifiers = true;
		this.shouldVisitParameterDeclarations = true;
		this.shouldVisitAttributes = true;
		this.fileName = fileName;
		this.fileNameLastSegment = fileName.substring(fileName.lastIndexOf("/")+1).replace(".", "_");
		this.model = model;
		this.model.setName(fileNameLastSegment+"_model");
	}

	@Override
	public int visit(IASTDeclaration declaration) {
		if (fileName.contains(declaration.getContainingFilename())) {
			if (declaration instanceof CASTSimpleDeclaration) {
				CASTSimpleDeclaration simpleDeclaration = (CASTSimpleDeclaration) declaration;
				
				for (IASTDeclarator declarator : simpleDeclaration.getDeclarators()) {
					visitInternal(declarator);
				}
			}
		}
		return super.visit(declaration);
	}
	
	public void visitInternal(IASTDeclSpecifier declSpec) {
		if (declSpec instanceof CASTSimpleDeclSpecifier) {
			
		}
	}
	
	public void visitInternal(IASTDeclarator declarator) {
		if (declarator instanceof CASTFunctionDeclarator) {
			if (model.getInterfaces().size() == 0) {
				FInterface iface = FrancaFactory.eINSTANCE.createFInterface();
				iface.setName(fileNameLastSegment);
				model.getInterfaces().add(iface);
			}
			
			FMethod method = FrancaFactory.eINSTANCE.createFMethod();
			method.setName(declarator.getName().getRawSignature());
			model.getInterfaces().get(0).getMethods().add(method);
		}
	}
	
	public void visitInernal(IASTParameterDeclaration parameterDeclaration) {
		
	}
	
}
