package org.franca.connectors.c_header;

import java.util.HashMap;
import java.util.Map;

import org.eclipse.cdt.core.dom.ast.ASTVisitor;
import org.eclipse.cdt.core.dom.ast.IASTCompositeTypeSpecifier;
import org.eclipse.cdt.core.dom.ast.IASTDeclSpecifier;
import org.eclipse.cdt.core.dom.ast.IASTDeclaration;
import org.eclipse.cdt.core.dom.ast.IASTDeclarator;
import org.eclipse.cdt.core.dom.ast.IASTEnumerationSpecifier.IASTEnumerator;
import org.eclipse.cdt.core.dom.ast.IASTNode;
import org.eclipse.cdt.core.dom.ast.IASTParameterDeclaration;
import org.eclipse.cdt.core.dom.ast.IASTSimpleDeclSpecifier;
import org.eclipse.cdt.core.dom.ast.c.ICASTDeclSpecifier;
import org.eclipse.cdt.internal.core.dom.parser.c.CASTCompositeTypeSpecifier;
import org.eclipse.cdt.internal.core.dom.parser.c.CASTDeclarator;
import org.eclipse.cdt.internal.core.dom.parser.c.CASTEnumerationSpecifier;
import org.eclipse.cdt.internal.core.dom.parser.c.CASTFunctionDeclarator;
import org.eclipse.cdt.internal.core.dom.parser.c.CASTSimpleDeclSpecifier;
import org.eclipse.cdt.internal.core.dom.parser.c.CASTSimpleDeclaration;
import org.eclipse.cdt.internal.core.dom.parser.c.CASTTypedefNameSpecifier;
import org.eclipse.cdt.internal.core.model.TranslationUnit;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.runtime.IPath;
import org.franca.core.franca.FArgument;
import org.franca.core.franca.FAttribute;
import org.franca.core.franca.FBasicTypeId;
import org.franca.core.franca.FEnumerationType;
import org.franca.core.franca.FEnumerator;
import org.franca.core.franca.FField;
import org.franca.core.franca.FInterface;
import org.franca.core.franca.FMethod;
import org.franca.core.franca.FModel;
import org.franca.core.franca.FStructType;
import org.franca.core.franca.FType;
import org.franca.core.franca.FTypeCollection;
import org.franca.core.franca.FTypeRef;
import org.franca.core.franca.FUnionType;
import org.franca.core.franca.FrancaFactory;

@SuppressWarnings("restriction")
public class CHeaderASTVisitor extends ASTVisitor {

	private IFile file;
	private FModel model;

	private Map<String, FType> customTypes;
	
	public CHeaderASTVisitor(FModel model, IFile file) {
		this.customTypes = new HashMap<String, FType>();

		this.shouldVisitDeclarations = true;
		this.shouldVisitDeclarators = true;
		this.shouldVisitDeclSpecifiers = true;
		this.shouldVisitParameterDeclarations = true;
		this.shouldVisitAttributes = true;
		this.shouldVisitNames = true;

		this.file = file;
		this.model = model;
		this.model.setName(getPackageName());
	}

	private String getPackageName() {
		IPath relativePath = file.getProjectRelativePath();
		String[] tokens = relativePath.toString().split("/");

		StringBuilder sb = new StringBuilder();
		if (tokens.length > 2) {
			for (int i = 1; i < tokens.length - 1; i++) {
				sb.append(tokens[i]);
				if (i != tokens.length - 2) {
					sb.append(".");
				}
			}
		}

		return sb.toString();
	}

	// A declaration belongs to every method declaration, global variable
	// declaration, etc.
	@Override
	public int visit(IASTDeclaration declaration) {
		if (isOwnDeclaration(declaration)) {
			if (declaration instanceof CASTSimpleDeclaration) {
				IASTDeclSpecifier type = ((CASTSimpleDeclaration) declaration)
						.getDeclSpecifier();
				IASTDeclarator declarator = ((CASTSimpleDeclaration) declaration)
						.getDeclarators()[0];

				if (declarator instanceof CASTFunctionDeclarator) {
					//System.out.println("Create method "+declarator.getName());
					FMethod method = createMethod(declarator);
					for (IASTParameterDeclaration param : ((CASTFunctionDeclarator) declarator).getParameters()) {
						method.getInArgs().add(createArgument(param.getDeclSpecifier(), param.getDeclarator()));
					}
					
					//set output type
					method.getOutArgs().add(createArgument(type, null));
					
					demandCreateInterface().getMethods().add(method);
				}
				// global variables should be treated separately
				else if (declarator instanceof CASTDeclarator && type.getStorageClass() == ICASTDeclSpecifier.sc_extern) {
					//System.out.println("Created global variable "+declarator.getName());
					demandCreateInterface().getAttributes().add(createAttribute(type, declarator));
				}
				else if (type instanceof CASTEnumerationSpecifier) {
					demandCreateTypeCollection().getTypes().add(createEnumeration((CASTEnumerationSpecifier) type, declarator));
				}
				else {
					//System.out.println("Created type "+declarator.getName());
					createTypeRef(type, declarator);
				}
			}
		}
		return super.visit(declaration);
	}

	/**
	 * Determines if the {@link IASTNode} belongs to the {@link TranslationUnit} of the 
	 * current {@link IFile} associated to the c header that is being transformed. 
	 * 
	 * @param node the ast node from the translation unit
	 * @return true, if the node belongs to the translation unit, false otherwise
	 */
	private boolean isOwnDeclaration(IASTNode node) {
		return node.getFileLocation().getFileName()
				.endsWith(file.getFullPath().toString());
	}

	private FAttribute createAttribute(IASTDeclSpecifier declSpec, IASTDeclarator declarator) {
		FAttribute attribute = FrancaFactory.eINSTANCE.createFAttribute();
		attribute.setName(declarator.getName().toString());
		attribute.setType(createTypeRef(declSpec, declarator));
		return attribute;
	}

	private FBasicTypeId createPrimitiveType(IASTDeclSpecifier declSpec) {
		if (isOwnDeclaration(declSpec)) {
			if (declSpec instanceof CASTSimpleDeclSpecifier) {
				CASTSimpleDeclSpecifier simpleDeclSpec = (CASTSimpleDeclSpecifier) declSpec;
				int type = simpleDeclSpec.getType();

				switch (type) {
					case IASTSimpleDeclSpecifier.t_int: {
						if (simpleDeclSpec.isUnsigned()) {
							return FBasicTypeId.UINT32;
						} else {
							return FBasicTypeId.INT32;
						}
					}
					case IASTSimpleDeclSpecifier.t_double: {
						return FBasicTypeId.DOUBLE;
					}
					case IASTSimpleDeclSpecifier.t_float: {
						return FBasicTypeId.FLOAT;
					}
				}
			}
		}
		return FBasicTypeId.INT32;
	}
	
	private FType createEnumeration(CASTEnumerationSpecifier enumeration, IASTDeclarator declarator) {
		if (this.customTypes.containsKey(enumeration.getName().toString())) {
			return this.customTypes.get(enumeration.getName().toString());
		}
		FEnumerationType enumerationType = FrancaFactory.eINSTANCE.createFEnumerationType();
		enumerationType.setName(declarator.getName().toString());
		
		for (IASTEnumerator e : enumeration.getEnumerators()) {
			FEnumerator enumerator = FrancaFactory.eINSTANCE.createFEnumerator();
			enumerator.setName(e.getName().toString());
			enumerator.setValue(e.getValue().toString());
			enumerationType.getEnumerators().add(enumerator);
		}
		return enumerationType;
	}
	
	private FType createCompositeType(CASTCompositeTypeSpecifier declSpec, IASTDeclarator declarator) {
		if (isOwnDeclaration(declSpec)) {
			
			if (customTypes.containsKey(declarator.getName().toString())) {
				return customTypes.get(declarator.getName().toString());
			}
			
			int key = ((CASTCompositeTypeSpecifier) declSpec).getKey();
			switch (key) {
				case IASTCompositeTypeSpecifier.k_struct: {
					FStructType struct = FrancaFactory.eINSTANCE
							.createFStructType();
					struct.setName(declarator.getName().toString());
					for (IASTDeclaration field : ((CASTCompositeTypeSpecifier) declSpec)
							.getDeclarations(true)) {
						FField fField = FrancaFactory.eINSTANCE.createFField();
						CASTSimpleDeclaration simpleDeclaration = (CASTSimpleDeclaration) field;
						fField.setName(simpleDeclaration.getDeclarators()[0]
								.getName().toString());
						fField.setType(createTypeRef(
								simpleDeclaration.getDeclSpecifier(),
								simpleDeclaration.getDeclarators()[0]));
						struct.getElements().add(fField);
					}
					demandCreateTypeCollection().getTypes().add(struct);
					this.customTypes.put(declarator.getName().toString(), struct);
					return struct;
				}
				case IASTCompositeTypeSpecifier.k_union: {
					FUnionType union = FrancaFactory.eINSTANCE.createFUnionType();
					union.setName(declarator.getName().toString());
					for (IASTDeclaration field : ((CASTCompositeTypeSpecifier) declSpec)
							.getDeclarations(true)) {
						FField fField = FrancaFactory.eINSTANCE.createFField();
						CASTSimpleDeclaration simpleDeclaration = (CASTSimpleDeclaration) field;
						fField.setName(simpleDeclaration.getDeclarators()[0]
								.getName().toString());
						fField.setType(createTypeRef(
								simpleDeclaration.getDeclSpecifier(),
								simpleDeclaration.getDeclarators()[0]));
						union.getElements().add(fField);
					}
					demandCreateTypeCollection().getTypes().add(union);
					this.customTypes.put(declarator.getName().toString(), union);
					return union;
				}
			}
		}
		
		return null;
	}	

	private FArgument createArgument(IASTDeclSpecifier declSpec, IASTDeclarator declarator) {
		FArgument argument = FrancaFactory.eINSTANCE.createFArgument();
		argument.setType(createTypeRef(declSpec, declarator));
		argument.setName((declarator == null) ? "out" : declarator.getName().toString());
		return argument;
	}

	private FMethod createMethod(IASTDeclarator declarator) {
			FInterface _interface = demandCreateInterface();
			FMethod method = FrancaFactory.eINSTANCE.createFMethod();
			method.setName(declarator.getName().toString());
			_interface.getMethods().add(method);
			return method;
	}

	private FTypeRef createTypeRef(IASTDeclSpecifier declSpec, IASTDeclarator declarator) {
		FTypeRef typeRef = FrancaFactory.eINSTANCE.createFTypeRef();
		if (declSpec instanceof CASTTypedefNameSpecifier) {
			typeRef.setDerived(this.customTypes.get(((CASTTypedefNameSpecifier) declSpec).getName().toString()));
		}
		else if (declarator != null && declSpec instanceof CASTCompositeTypeSpecifier) {
			typeRef.setDerived(createCompositeType((CASTCompositeTypeSpecifier) declSpec, declarator));
		}
		else {
			typeRef.setPredefined(createPrimitiveType(declSpec));
		}
		
		return typeRef;
	}
	
	private FTypeCollection demandCreateTypeCollection() {
		if (model.getTypeCollections().size() == 0) {
			FTypeCollection typeCollection = FrancaFactory.eINSTANCE.createFTypeCollection();
			model.getTypeCollections().add(typeCollection);
		}
		return model.getTypeCollections().get(0);
	}

	private FInterface demandCreateInterface() {
		if (model.getInterfaces().size() == 0) {
			FInterface iface = FrancaFactory.eINSTANCE.createFInterface();
			iface.setName(file.getName());
			model.getInterfaces().add(iface);
		}
		return model.getInterfaces().get(0);
	}

}
