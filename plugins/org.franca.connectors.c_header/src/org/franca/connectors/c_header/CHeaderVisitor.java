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
import org.eclipse.cdt.core.dom.ast.IASTTranslationUnit;
import org.eclipse.cdt.core.dom.ast.c.ICASTDeclSpecifier;
import org.eclipse.cdt.core.model.ITranslationUnit;
import org.eclipse.cdt.internal.core.dom.parser.c.CASTCompositeTypeSpecifier;
import org.eclipse.cdt.internal.core.dom.parser.c.CASTDeclarator;
import org.eclipse.cdt.internal.core.dom.parser.c.CASTEnumerationSpecifier;
import org.eclipse.cdt.internal.core.dom.parser.c.CASTFunctionDeclarator;
import org.eclipse.cdt.internal.core.dom.parser.c.CASTSimpleDeclSpecifier;
import org.eclipse.cdt.internal.core.dom.parser.c.CASTSimpleDeclaration;
import org.eclipse.cdt.internal.core.dom.parser.c.CASTTypedefNameSpecifier;
import org.eclipse.cdt.internal.core.model.TranslationUnit;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.runtime.CoreException;
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
import org.franca.core.franca.FTypeDef;
import org.franca.core.franca.FTypeRef;
import org.franca.core.franca.FUnionType;
import org.franca.core.franca.FrancaFactory;

/**
 * The visitor can be used to create an {@link FModel} for a given C header file. 
 * The class uses the Eclipse CDT API to traverse the header file contents. 
 *  
 * @author Tamas Szabo (itemis AG)
 *
 */
@SuppressWarnings("restriction")
public class CHeaderVisitor extends ASTVisitor {

	private TranslationUnit translationUnit;
	private FModel model;
	private Map<String, FType> customTypes;
	
	/**
	 * Visits the {@link IASTTranslationUnit} of the {@link ITranslationUnit} associated to the C header file 
	 * and creates the corresponding {@link FModel} instance. The transformation includes the following 
	 * constructs: <br/>
	 * - function declaration -> Franca {@link FMethod} <br/>
	 * - global variable with extern -> Franca {@link FAttribute} <br/>
	 * - typedef for primitive types -> Franca {@link FTypeDef} <br/>
	 * - typedef for structs -> Franca {@link FStructType} <br/>
	 * - typedef for unions -> Franca {@link FUnionType} <br/>
	 * - enumeration -> Franca {@link FEnumerationType} <br/>
	 * 
	 * @param file
	 * @return
	 */
	public static FModel visit(TranslationUnit translationUnit) {
		FModel fModel = FrancaFactory.eINSTANCE.createFModel();
		CHeaderVisitor visitor = new CHeaderVisitor(fModel, translationUnit);
		try {
			translationUnit.getAST().accept(visitor);
			return fModel;
		} catch (CoreException e) {
			e.printStackTrace();
			return null;
		}
	}
	
	private CHeaderVisitor(FModel model, TranslationUnit translationUnit) {
		this.customTypes = new HashMap<String, FType>();

		this.shouldVisitDeclarations = true;
		this.shouldVisitDeclarators = true;
		this.shouldVisitDeclSpecifiers = true;
		this.shouldVisitParameterDeclarations = true;
		this.shouldVisitAttributes = true;
		this.shouldVisitNames = true;
		
		this.translationUnit = translationUnit;
		this.model = model;
		this.model.setName(getPackageName());
	}

	private String getPackageName() {		
		IPath relativePath = translationUnit.getFile().getProjectRelativePath();
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
	// declaration, typdefs, etc. The visit method will be invoked for all 
	// of them and the creation of the model elements will be in that order.
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
				// enumerators are treated separately
				else if (type instanceof CASTEnumerationSpecifier) {
					demandCreateTypeCollection().getTypes().add(createEnumeration((CASTEnumerationSpecifier) type, declarator));
				}
				// create types if necessary
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
				.endsWith(translationUnit.getPath().toString());
	}

	private FAttribute createAttribute(IASTDeclSpecifier declSpec, IASTDeclarator declarator) {
		FAttribute attribute = FrancaFactory.eINSTANCE.createFAttribute();
		attribute.setName(declarator.getName().toString());
		attribute.setType(createTypeRef(declSpec, declarator));
		return attribute;
	}

	private FBasicTypeId createPrimitiveType(IASTDeclSpecifier declSpec) {
		CASTSimpleDeclSpecifier simpleDeclSpec = (CASTSimpleDeclSpecifier) declSpec;
		int type = simpleDeclSpec.getType();

		switch (type) {
		case IASTSimpleDeclSpecifier.t_int: {
			if (simpleDeclSpec.isUnsigned()) {
				if (simpleDeclSpec.isLong()) {
					return FBasicTypeId.UINT64;
				} else {
					return FBasicTypeId.UINT32;
				}
			} else {
				if (simpleDeclSpec.isLong()) {
					return FBasicTypeId.INT64;
				} else {
					return FBasicTypeId.INT32;
				}
			}
		}
		case IASTSimpleDeclSpecifier.t_char: {
			if (simpleDeclSpec.isUnsigned()) {
				return FBasicTypeId.UINT8;
			} else {
				return FBasicTypeId.INT8;
			}
		}
		case IASTSimpleDeclSpecifier.t_double: {
			return FBasicTypeId.DOUBLE;
		}
		case IASTSimpleDeclSpecifier.t_float: {
			return FBasicTypeId.FLOAT;
		}
		case IASTSimpleDeclSpecifier.t_bool: {
			return FBasicTypeId.BOOLEAN;
		}
		default: {
			if (simpleDeclSpec.isShort()) {
				if (simpleDeclSpec.isUnsigned()) {
					return FBasicTypeId.UINT16;
				}
				else {
					return FBasicTypeId.INT16;					
				}
			}
			else {
				return FBasicTypeId.INT32;
			}
		}
		}
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
	
	private FType createCustomType(IASTDeclSpecifier declSpec, IASTDeclarator declarator) {
		if (customTypes.containsKey(declarator.getName().toString())) {
			return customTypes.get(declarator.getName().toString());
		}

		if (declSpec instanceof CASTCompositeTypeSpecifier) {
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
		} else if (declSpec instanceof CASTSimpleDeclSpecifier) {
			FTypeDef typeDef = FrancaFactory.eINSTANCE.createFTypeDef();
			typeDef.setName(declarator.getName().toString());
			FTypeRef typeRef = FrancaFactory.eINSTANCE.createFTypeRef();
			typeRef.setPredefined(createPrimitiveType(declSpec));
			typeDef.setActualType(typeRef);
			this.customTypes.put(declarator.getName().toString(), typeDef);
			demandCreateTypeCollection().getTypes().add(typeDef);
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
		else if (declarator != null && (declSpec instanceof CASTCompositeTypeSpecifier || declSpec.getStorageClass() == ICASTDeclSpecifier.sc_typedef)) {
			typeRef.setDerived(createCustomType(declSpec, declarator));
		}
		else {
			// this part will never be invoked for a declaration
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
			iface.setName(translationUnit.getElementName());
			model.getInterfaces().add(iface);
		}
		return model.getInterfaces().get(0);
	}

}
