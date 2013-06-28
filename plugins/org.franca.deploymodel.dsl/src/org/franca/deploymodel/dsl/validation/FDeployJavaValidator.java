/*******************************************************************************
 * Copyright (c) 2012 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.deploymodel.dsl.validation;

import java.util.List;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EReference;
import org.eclipse.emf.ecore.EStructuralFeature;
import org.eclipse.xtext.validation.Check;
import org.eclipse.xtext.validation.ValidationMessageAcceptor;
import org.franca.core.franca.FArgument;
import org.franca.core.franca.FArrayType;
import org.franca.core.franca.FAttribute;
import org.franca.core.franca.FBroadcast;
import org.franca.core.franca.FEnumerationType;
import org.franca.core.franca.FEnumerator;
import org.franca.core.franca.FField;
import org.franca.core.franca.FInterface;
import org.franca.core.franca.FMethod;
import org.franca.core.franca.FStructType;
import org.franca.core.franca.FType;
import org.franca.core.franca.FUnionType;
import org.franca.deploymodel.core.FDModelUtils;
import org.franca.deploymodel.core.PropertyMappings;
import org.franca.deploymodel.dsl.FDMapper;
import org.franca.deploymodel.dsl.FDSpecificationExtender;
import org.franca.deploymodel.dsl.fDeploy.FDArgument;
import org.franca.deploymodel.dsl.fDeploy.FDArray;
import org.franca.deploymodel.dsl.fDeploy.FDAttribute;
import org.franca.deploymodel.dsl.fDeploy.FDBoolean;
import org.franca.deploymodel.dsl.fDeploy.FDBroadcast;
import org.franca.deploymodel.dsl.fDeploy.FDComplexValue;
import org.franca.deploymodel.dsl.fDeploy.FDDeclaration;
import org.franca.deploymodel.dsl.fDeploy.FDElement;
import org.franca.deploymodel.dsl.fDeploy.FDEnum;
import org.franca.deploymodel.dsl.fDeploy.FDEnumType;
import org.franca.deploymodel.dsl.fDeploy.FDEnumValue;
import org.franca.deploymodel.dsl.fDeploy.FDEnumeration;
import org.franca.deploymodel.dsl.fDeploy.FDField;
import org.franca.deploymodel.dsl.fDeploy.FDInteger;
import org.franca.deploymodel.dsl.fDeploy.FDInterface;
import org.franca.deploymodel.dsl.fDeploy.FDInterfaceInstance;
import org.franca.deploymodel.dsl.fDeploy.FDInterfaceRef;
import org.franca.deploymodel.dsl.fDeploy.FDMethod;
import org.franca.deploymodel.dsl.fDeploy.FDModel;
import org.franca.deploymodel.dsl.fDeploy.FDPredefinedTypeId;
import org.franca.deploymodel.dsl.fDeploy.FDProperty;
import org.franca.deploymodel.dsl.fDeploy.FDPropertyDecl;
import org.franca.deploymodel.dsl.fDeploy.FDPropertyFlag;
import org.franca.deploymodel.dsl.fDeploy.FDPropertyHost;
import org.franca.deploymodel.dsl.fDeploy.FDProvider;
import org.franca.deploymodel.dsl.fDeploy.FDRootElement;
import org.franca.deploymodel.dsl.fDeploy.FDSpecification;
import org.franca.deploymodel.dsl.fDeploy.FDString;
import org.franca.deploymodel.dsl.fDeploy.FDStruct;
import org.franca.deploymodel.dsl.fDeploy.FDType;
import org.franca.deploymodel.dsl.fDeploy.FDTypeRef;
import org.franca.deploymodel.dsl.fDeploy.FDTypes;
import org.franca.deploymodel.dsl.fDeploy.FDUnion;
import org.franca.deploymodel.dsl.fDeploy.FDValue;
import org.franca.deploymodel.dsl.fDeploy.FDValueArray;
import org.franca.deploymodel.dsl.fDeploy.FDeployPackage;

import com.google.common.collect.Lists;

public class FDeployJavaValidator extends AbstractFDeployJavaValidator
	implements ValidationMessageReporter {

	public static final String UPPERCASE_PROPERTYNAME_QUICKFIX = "UPPERCASE_PROPERTYNAME_QUICKFIX";
	
	public static final String METHOD_ARGUMENT_QUICKFIX = "METHOD_ARGUMENT_QUICKFIX";
	public static final String METHOD_ARGUMENT_QUICKFIX_MESSAGE = "Method argument is missing for method ";
	
	public static final String COMPOUND_FIELD_QUICKFIX = "COMPOUND_FIELD_QUICKFIX";
	public static final String COMPOUND_FIELD_QUICKFIX_MESSAGE = "Field is missing for compound ";
	
	public static final String ENUMERATOR_ENUM_QUICKFIX = "ENUMERATOR_ENUM_QUICKFIX";
	public static final String ENUMERATOR_ENUM_QUICKFIX_MESSAGE = "Enumerator element is missing for enum ";
	
	public static final String MANDATORY_PROPERTY_QUICKFIX  = "MANDATORY_PROPERTIES_QUICKFIX";
	public static final String MANDATORY_PROPERTY_QUICKFIX_MESSAGE  = "Mandatory properties are missing for element ";
	
	public static final String DEPLOYMENT_ELEMENT_QUICKFIX  = "DEPLOYMENT_ELEMENT_QUICKFIX";
	public static final String DEPLOYMENT_ELEMENT_QUICKFIX_MESSAGE  = "Specification element is missing for interface ";
	
	public static final String DEPLOYMENT_ELEMENT_RECURSIVE_QUICKFIX = "DEPLOYMENT_ELEMENT_RECURSIVE_QUICKFIX";
	public static final String DEPLOYMENT_ELEMENT_RECURSIVE_QUICKFIX_MESSAGE = "There are multiple issues with element ";
	
	// delegate to FDeployValidator
	FDeployValidator deployValidator = new FDeployValidator(this);

	
	// *****************************************************************************
	// basic checks
	
	@Check
	public void checkSpecNamesUnique(FDModel model) {
		ValidationHelpers.checkDuplicates(this, model.getSpecifications(),
				FDeployPackage.Literals.FD_SPECIFICATION__NAME, "specification name");
	}

	@Check
	public void checkRootElementNamesUnique(FDModel model) {
		ValidationHelpers.checkDuplicates(this, model.getDeployments(),
				FDeployPackage.Literals.FD_ROOT_ELEMENT__NAME, "definition name");
	}

	@Check
	public void checkRootElement (FDRootElement elem) {
		deployValidator.checkRootElement(elem);
	}

	@Check
	public void checkMethodArgs (FDMethod method) {
		if (method.getInArguments()!=null) {
			for(FDArgument arg : method.getInArguments().getArguments()) {
				if (! method.getTarget().getInArgs().contains(arg.getTarget())) {
					error("Invalid input argument '" + arg.getTarget().getName() + "'",
							arg, FDeployPackage.Literals.FD_ARGUMENT__TARGET, -1);
				}
			}
		}
		if (method.getOutArguments()!=null) {
			for(FDArgument arg : method.getOutArguments().getArguments()) {
				if (! method.getTarget().getOutArgs().contains(arg.getTarget())) {
					error("Invalid output argument '" + arg.getTarget().getName() + "'",
							arg, FDeployPackage.Literals.FD_ARGUMENT__TARGET, -1);
				}
			}
		}
	}

	
	// *****************************************************************************
	// validate specifications
	
	@Check
	public void checkPropertyName (FDPropertyDecl prop) {
		if (! Character.isUpperCase(prop.getName().charAt(0))) {
			error("Property names must begin with an uppercase character", FDeployPackage.Literals.FD_PROPERTY_DECL__NAME, UPPERCASE_PROPERTYNAME_QUICKFIX, prop.getName());
		}
	}
	
   @Check
   public void checkDeclaration(FDDeclaration decl) {
       ValidationHelpers.checkDuplicates(this, decl.getProperties(), FDeployPackage.Literals.FD_PROPERTY_DECL__NAME, "property name");
   }
	  
	@Check
	public void checkBaseSpec (FDSpecification spec) {
		FDSpecification cycleSpec = deployValidator.getCyclicBaseSpec(spec);
		if (cycleSpec!=null) {
			error("Inheritance cycle for specification " + cycleSpec.getName(), cycleSpec,
					FDeployPackage.Literals.FD_SPECIFICATION__BASE, -1);
			return;
		}
	}

	
	// *****************************************************************************
	// check for missing properties
	
	@Check
	public void checkPropertiesComplete(FDProvider elem) {
		// check own properties
		FDSpecification spec = FDModelUtils.getRootElement(elem).getSpec();
		checkSpecificationElementProperties(spec, elem, FDeployPackage.Literals.FD_ROOT_ELEMENT__NAME, spec.getName());
	}
	
	@Check
	public void checkPropertiesComplete(FDTypes elem) {
		// check own properties
		FDSpecification spec = FDModelUtils.getRootElement(elem).getSpec();
		checkSpecificationElementProperties(spec, elem, FDeployPackage.Literals.FD_TYPES__TARGET, spec.getName());

		// check child elements recursively
		FDSpecificationExtender specHelper = new FDSpecificationExtender(spec);
		PropertyDefChecker checker = new PropertyDefChecker(specHelper);
		FDMapper mapper = new FDMapper(elem);
		List<FType> targetTypes = elem.getTarget().getTypes();
		checkLocalTypes(targetTypes, specHelper, checker, mapper, spec,
				FDeployPackage.Literals.FD_TYPES__TARGET);

		deployValidator.checkUsedTypes(elem, targetTypes, checker);
	}
	
	@Check
	public void checkPropertiesComplete(FDInterface elem) {
		// check own properties
		FDSpecification spec = FDModelUtils.getRootElement(elem).getSpec();
		checkSpecificationElementProperties(spec, elem, FDeployPackage.Literals.FD_INTERFACE__TARGET, spec.getName());
		
		//Note: pay attention to the lazy and eager boolean operators!
		
		// check child elements recursively
		FDSpecificationExtender specHelper = new FDSpecificationExtender(spec);
		PropertyDefChecker checker = new PropertyDefChecker(specHelper);
		FDMapper mapper = new FDMapper(elem);
		FInterface target = elem.getTarget();
		
		for(FAttribute tc : target.getAttributes()) {
			FDAttribute c = (FDAttribute) mapper.getFDElement(tc);
			if (c==null) {
				if (checker.mustBeDefined(tc)) {
					error(DEPLOYMENT_ELEMENT_QUICKFIX_MESSAGE+ "'" + tc.getName() + "'",
							FDeployPackage.Literals.FD_INTERFACE__TARGET, 
							DEPLOYMENT_ELEMENT_QUICKFIX, 
							tc.getName(),
							FrancaQuickFixConstants.ATTRIBUTE.toString());	
					error(DEPLOYMENT_ELEMENT_RECURSIVE_QUICKFIX_MESSAGE+"'" + tc.getName() + "'",
							FDeployPackage.Literals.FD_INTERFACE__TARGET,
							DEPLOYMENT_ELEMENT_RECURSIVE_QUICKFIX, 
							tc.getName(),
							FrancaQuickFixConstants.ATTRIBUTE.toString());
				}
			} 
			else {
				checkSpecificationElementProperties(spec, c, FDeployPackage.Literals.FD_ATTRIBUTE__TARGET, tc.getName());
			}
		}

		for(FMethod tc : target.getMethods()) {
			FDMethod c = (FDMethod) mapper.getFDElement(tc);
			if (c==null) {
				if (checker.mustBeDefined(tc)) {
					error(DEPLOYMENT_ELEMENT_QUICKFIX_MESSAGE+ "'" + tc.getName() + "'",
							FDeployPackage.Literals.FD_INTERFACE__TARGET, 
							DEPLOYMENT_ELEMENT_QUICKFIX, 
							tc.getName(),
							FrancaQuickFixConstants.METHOD.toString());
					error(DEPLOYMENT_ELEMENT_RECURSIVE_QUICKFIX_MESSAGE+"'" + tc.getName() + "'",
							FDeployPackage.Literals.FD_INTERFACE__TARGET,
							DEPLOYMENT_ELEMENT_RECURSIVE_QUICKFIX, 
							tc.getName(),
							FrancaQuickFixConstants.METHOD.toString());
				}
			} 
			else {  
				checkSpecificationElementProperties(spec, c, FDeployPackage.Literals.FD_METHOD__TARGET, tc.getName());
				if (checkArgumentList(specHelper, checker, mapper, spec, tc.getInArgs(), c,	"Input", FDeployPackage.Literals.FD_METHOD__TARGET) |
				checkArgumentList(specHelper, checker, mapper, spec, tc.getOutArgs(), c, "Output", FDeployPackage.Literals.FD_METHOD__TARGET)) {
					error(DEPLOYMENT_ELEMENT_RECURSIVE_QUICKFIX_MESSAGE+"'" + tc.getName() + "'",
							c, FDeployPackage.Literals.FD_METHOD__TARGET,
							DEPLOYMENT_ELEMENT_RECURSIVE_QUICKFIX, 
							tc.getName(),
							FrancaQuickFixConstants.METHOD.toString());
				}
			}
		}

		for(FBroadcast tc : target.getBroadcasts()) {
			FDBroadcast c = (FDBroadcast) mapper.getFDElement(tc);
			if (c==null) {
				if (checker.mustBeDefined(tc)) {
					error(DEPLOYMENT_ELEMENT_QUICKFIX_MESSAGE+ "'" + tc.getName() + "'",
							FDeployPackage.Literals.FD_INTERFACE__TARGET, 
							DEPLOYMENT_ELEMENT_QUICKFIX, 
							tc.getName(),
							FrancaQuickFixConstants.BROADCAST.toString());
					error(DEPLOYMENT_ELEMENT_RECURSIVE_QUICKFIX_MESSAGE+"'" + tc.getName() + "'",
							FDeployPackage.Literals.FD_INTERFACE__TARGET,
							DEPLOYMENT_ELEMENT_RECURSIVE_QUICKFIX, 
							tc.getName(),
							FrancaQuickFixConstants.BROADCAST.toString());
				}
			} 
			else {
				checkSpecificationElementProperties(spec, c, FDeployPackage.Literals.FD_BROADCAST__TARGET, tc.getName());
				if (checkArgumentList(specHelper, checker, mapper, spec, tc.getOutArgs(), c, "Output", FDeployPackage.Literals.FD_BROADCAST__TARGET)) {
					error(DEPLOYMENT_ELEMENT_RECURSIVE_QUICKFIX_MESSAGE+"'" + tc.getName() + "'",
							c, FDeployPackage.Literals.FD_BROADCAST__TARGET,
							DEPLOYMENT_ELEMENT_RECURSIVE_QUICKFIX, 
							tc.getName(),
							FrancaQuickFixConstants.BROADCAST.toString());
				}
			}
		}
		
		checkLocalTypes(target.getTypes(), specHelper, checker, mapper, spec,
				FDeployPackage.Literals.FD_INTERFACE__TARGET);
		
		deployValidator.checkUsedTypes(elem, target.getTypes(), checker);
	}
	
	private void checkLocalTypes (List<FType> types, FDSpecificationExtender specHelper,
			PropertyDefChecker checker,
			FDMapper mapper, FDSpecification spec,
			EStructuralFeature parentFeature)
	{
		for(FType tc : types) {
			if (tc instanceof FArrayType) {
				FDArray c = (FDArray) mapper.getFDElement(tc);
				if (c==null) {
					if (checker.mustBeDefined((FArrayType)tc)) {
						error(DEPLOYMENT_ELEMENT_QUICKFIX_MESSAGE+ "'" + tc.getName() + "'",
								parentFeature, 
								DEPLOYMENT_ELEMENT_QUICKFIX, 
								tc.getName(),
								FrancaQuickFixConstants.ARRAY.toString());
						error(DEPLOYMENT_ELEMENT_RECURSIVE_QUICKFIX_MESSAGE+"'" + tc.getName() + "'",
								parentFeature,
								DEPLOYMENT_ELEMENT_RECURSIVE_QUICKFIX, 
								tc.getName(),
								FrancaQuickFixConstants.ARRAY.toString());
					}
				}
				else {
					checkSpecificationElementProperties(spec, c, FDeployPackage.Literals.FD_ARRAY__TARGET, tc.getName());
				}
			} else if (tc instanceof FStructType) {
				FDStruct c = (FDStruct) mapper.getFDElement(tc);
				if (c==null) {
					if (checker.mustBeDefined((FStructType)tc)) {
						error(DEPLOYMENT_ELEMENT_QUICKFIX_MESSAGE+ "'" + tc.getName() + "'",
								parentFeature, 
								DEPLOYMENT_ELEMENT_QUICKFIX, 
								tc.getName(),
								FrancaQuickFixConstants.STRUCT.toString());
						error(DEPLOYMENT_ELEMENT_RECURSIVE_QUICKFIX_MESSAGE+"'" + tc.getName() + "'",
								parentFeature,
								DEPLOYMENT_ELEMENT_RECURSIVE_QUICKFIX, 
								tc.getName(),
								FrancaQuickFixConstants.STRUCT.toString());
					}
				} 
				else {  
					checkSpecificationElementProperties(spec, c, FDeployPackage.Literals.FD_STRUCT__TARGET, tc.getName());
					if (checkFieldsList(specHelper, checker, mapper, spec, ((FStructType) tc).getElements(), c, FDeployPackage.Literals.FD_STRUCT__TARGET, "Struct")) {
						error(DEPLOYMENT_ELEMENT_RECURSIVE_QUICKFIX_MESSAGE+"'" + tc.getName() + "'",
								c, FDeployPackage.Literals.FD_STRUCT__TARGET,
								DEPLOYMENT_ELEMENT_RECURSIVE_QUICKFIX, 
								tc.getName(),
								FrancaQuickFixConstants.STRUCT.toString());
					}
				}
			} else if (tc instanceof FUnionType) {
				FDUnion c = (FDUnion) mapper.getFDElement(tc);
				if (c==null) {
					if (checker.mustBeDefined((FUnionType)tc)) {
						error(DEPLOYMENT_ELEMENT_QUICKFIX_MESSAGE+ "'" + tc.getName() + "'",
								parentFeature, 
								DEPLOYMENT_ELEMENT_QUICKFIX, 
								tc.getName(),
								FrancaQuickFixConstants.UNION.toString());
						error(DEPLOYMENT_ELEMENT_RECURSIVE_QUICKFIX_MESSAGE+"'" + tc.getName() + "'",
								parentFeature,
								DEPLOYMENT_ELEMENT_RECURSIVE_QUICKFIX, 
								tc.getName(),
								FrancaQuickFixConstants.UNION.toString());
					}
				} 
				else { 
					checkSpecificationElementProperties(spec, c, FDeployPackage.Literals.FD_UNION__TARGET, tc.getName());
					if (checkFieldsList(specHelper, checker, mapper, spec, ((FUnionType) tc).getElements(), c, FDeployPackage.Literals.FD_UNION__TARGET, "Union")) {
						error(DEPLOYMENT_ELEMENT_RECURSIVE_QUICKFIX_MESSAGE+"'" + tc.getName() + "'",
								c, FDeployPackage.Literals.FD_UNION__TARGET,
								DEPLOYMENT_ELEMENT_RECURSIVE_QUICKFIX, 
								tc.getName(),
								FrancaQuickFixConstants.UNION.toString());
					}
				}
			} else if (tc instanceof FEnumerationType) {
				FDEnumeration c = (FDEnumeration) mapper.getFDElement(tc);
				if (c==null) {
					if (checker.mustBeDefined((FEnumerationType)tc)) {
						error(DEPLOYMENT_ELEMENT_QUICKFIX_MESSAGE+ "'" + tc.getName() + "'",
								parentFeature, 
								DEPLOYMENT_ELEMENT_QUICKFIX, 
								tc.getName(),
								FrancaQuickFixConstants.ENUMERATION.toString());
						error(DEPLOYMENT_ELEMENT_RECURSIVE_QUICKFIX_MESSAGE+"'" + tc.getName() + "'",
								parentFeature,
								DEPLOYMENT_ELEMENT_RECURSIVE_QUICKFIX, 
								tc.getName(),
								FrancaQuickFixConstants.ENUMERATION.toString());
					}
				} 
				else {
					checkSpecificationElementProperties(spec, c, FDeployPackage.Literals.FD_ENUMERATION__TARGET, tc.getName());
					if (checkEnumeratorsList(specHelper, mapper, spec, ((FEnumerationType) tc).getEnumerators(), c,	FDeployPackage.Literals.FD_ENUMERATION__TARGET)) {
						error(DEPLOYMENT_ELEMENT_RECURSIVE_QUICKFIX_MESSAGE+"'" + tc.getName() + "'",
								c, FDeployPackage.Literals.FD_ENUMERATION__TARGET,
								DEPLOYMENT_ELEMENT_RECURSIVE_QUICKFIX, 
								tc.getName(),
								FrancaQuickFixConstants.ENUMERATION.toString());
					}
				}
			}
		}
	}

	private boolean checkArgumentList(FDSpecificationExtender specHelper,
			PropertyDefChecker checker,
			FDMapper mapper, FDSpecification spec, List<FArgument> args,
			FDElement parent, String tag, EStructuralFeature feature)
	{
		boolean hasError = false;
		for(FArgument tc : args) {
			FDArgument c = (FDArgument) mapper.getFDElement(tc);
			if (c==null) {
				if (checker.mustBeDefined(tc)) {
					error("Mandatory argument '" + tc.getName() + "' is missing for method '" + ((FDMethod) parent).getTarget().getName() + "'",
						parent, feature, -1, METHOD_ARGUMENT_QUICKFIX, ((FDMethod) parent).getTarget().getName(), tc.getName());
					hasError = true;
				}
			} 
			else {
				hasError = checkSpecificationElementProperties(spec, c, FDeployPackage.Literals.FD_ARGUMENT__TARGET, tc.getName());
			}
		}
		
		return hasError;
	}
	
	private boolean checkFieldsList (FDSpecificationExtender specHelper,
			PropertyDefChecker checker,
			FDMapper mapper, FDSpecification spec, List<FField> fields,
			FDElement parent, EStructuralFeature feature, String tag)
	{
		boolean hasError = false;
		for(FField tc : fields) {
			FDField c = (FDField) mapper.getFDElement(tc);
			if (c==null) {
				if (checker.mustBeDefined(tc)) {
					String name = "";
					if (parent instanceof FDUnion) {
						name = ((FDUnion) parent).getTarget().getName();
					}
					else if (parent instanceof FDStruct) {
						name = ((FDStruct) parent).getTarget().getName();
					}
					error("Mandatory field '" + tc.getName() + "' is missing for compound '" + name + "'", 
							parent, feature, -1, COMPOUND_FIELD_QUICKFIX, name, tc.getName());
					hasError = true;
				}
			} 
			else {
				hasError = checkSpecificationElementProperties(spec, c, FDeployPackage.Literals.FD_FIELD__TARGET, tc.getName());
			}
		}
		return hasError;
	}
	
	private boolean checkEnumeratorsList (FDSpecificationExtender specHelper,
			FDMapper mapper, FDSpecification spec, List<FEnumerator> enumerators,
			FDElement parent, EStructuralFeature feature)
	{
		boolean hasError = false;
		for(FEnumerator tc : enumerators) {
			FDEnumValue c = (FDEnumValue) mapper.getFDElement(tc);
			if (c==null) {
				if (specHelper.isMandatory(FDPropertyHost.ENUMERATORS)) {
					error("Mandatory enumerator '" + tc.getName() + "' is missing for enumeration '" + ((FDEnumeration) parent).getTarget().getName() + "'", 
							parent, feature, -1, ENUMERATOR_ENUM_QUICKFIX, ((FDEnumeration) parent).getTarget().getName(), tc.getName());
					hasError = true;
				}
			} 
			else {
				hasError = checkSpecificationElementProperties(spec, c, FDeployPackage.Literals.FD_ENUM_VALUE__TARGET, tc.getName());
			}
		}
		return hasError;
	}
	
	
	// *****************************************************************************

	@Check
	public void checkPropertiesComplete (FDInterfaceInstance elem) {
		// check own properties
		FDSpecification spec = FDModelUtils.getRootElement(elem).getSpec();
		checkSpecificationElementProperties(spec, elem, FDeployPackage.Literals.FD_INTERFACE_INSTANCE__TARGET, spec.getName());
	}
	
	private boolean checkSpecificationElementProperties(FDSpecification spec, FDElement elem, EStructuralFeature feature, String elementName)
	{
		List<FDPropertyDecl> decls = PropertyMappings.getAllPropertyDecls(spec, elem);
		List<String> missing = Lists.newArrayList();
		for(FDPropertyDecl decl : decls) {
			if (PropertyMappings.isMandatory(decl)) {
				if (! contains(elem.getProperties(), decl)) {
					missing.add(decl.getName());
				}
			}
		}
		
		if (!missing.isEmpty()) {
			error(MANDATORY_PROPERTY_QUICKFIX_MESSAGE + "'" + elementName + "'", elem, feature, -1,
					MANDATORY_PROPERTY_QUICKFIX, elementName);
			return true;
		}
		
		return false;
	}
	
	private boolean contains(List<FDProperty> properties, FDPropertyDecl decl) {
		for(FDProperty p : properties) {
			if (p.getDecl()==decl) {
				return true;
			}
		}
		return false;
	}

	
	// *****************************************************************************
	// type system
	
	@Check
	public void checkPropertyFlagType(FDPropertyFlag flag) {
		if (flag.getDefault()==null)
			return;
		
		FDPropertyDecl decl = (FDPropertyDecl)flag.eContainer();
		FDTypeRef typeRef = decl.getType();
		FDComplexValue value = flag.getDefault();
		if (value.getSingle()!=null) {
			if (typeRef.getArray()!=null)
				error("Default must be an array!", FDeployPackage.Literals.FD_PROPERTY_FLAG__DEFAULT);
			else
				checkValueType(typeRef, value.getSingle(), flag, FDeployPackage.Literals.FD_PROPERTY_FLAG__DEFAULT, -1);
		} else if (value.getArray()!=null) {
			if (typeRef.getArray()==null) {
				error("Default must be a single type, not an array!", FDeployPackage.Literals.FD_PROPERTY_FLAG__DEFAULT);
			} else
				checkValueArrayType(typeRef, value.getArray());
		}
	}

	@Check
	public void checkPropertyValueType(FDProperty prop) {
		FDTypeRef typeRef = prop.getDecl().getType();
		FDComplexValue value = prop.getValue();
		if (value.getSingle()!=null) {
			if (typeRef.getArray()!=null)
				error("Invalid type, expected array!", FDeployPackage.Literals.FD_PROPERTY__VALUE);
			else
				checkValueType(typeRef, value.getSingle(), prop, FDeployPackage.Literals.FD_PROPERTY__VALUE, -1);
		} else if (value.getArray()!=null) {
			if (typeRef.getArray()==null)
				error("Invalid array type, expected single value!", FDeployPackage.Literals.FD_PROPERTY__VALUE);
			else
				checkValueArrayType(typeRef, value.getArray());
		}
	}
	
	private void checkValueType (FDTypeRef typeRef, FDValue value, EObject src, EReference literal, int index) {
		if (typeRef.getComplex()==null) {
			// this is a predefined type
			switch (typeRef.getPredefined().getValue()) {
			case FDPredefinedTypeId.INTEGER_VALUE:
				if (! (value instanceof FDInteger)) {
					error("Invalid type, expected Integer constant",
							src, literal, index);
				}
				break;
			case FDPredefinedTypeId.STRING_VALUE:
				if (! (value instanceof FDString)) {
					error("Invalid type, expected String constant",
							src, literal, index);
				}
				break;
			case FDPredefinedTypeId.BOOLEAN_VALUE:
				if (! (value instanceof FDBoolean)) {
					error("Invalid type, expected 'true' or 'false'",
							src, literal, index);
				}
				break;
			case FDPredefinedTypeId.INTERFACE_VALUE:
				if (! (value instanceof FDInterfaceRef)) {
					error("Invalid type, expected reference to Franca interface",
							src, literal, index);
				}
				break;
			}
		} else {
			FDType type = typeRef.getComplex();
			if (type instanceof FDEnumType) {
				if (! (value instanceof FDEnum)) {
					error("Invalid type, expected enumerator",
							src, literal, index);
				}
			}
		}
	}
	
	private void checkValueArrayType (FDTypeRef typeRef, FDValueArray array) {
		int i = 0;
		for(FDValue value : array.getValues()) {
			checkValueType(typeRef, value, array, FDeployPackage.Literals.FD_VALUE_ARRAY__VALUES, i);
			i++;
		}
	}

	
	// *****************************************************************************
	// ValidationMessageReporter interface

	public void reportError(String message, EObject object,
								EStructuralFeature feature)
	{
		error(message, object, feature, ValidationMessageAcceptor.INSIGNIFICANT_INDEX);
	}

	public void reportError(String message, EObject object,
								EStructuralFeature feature, int idx)
	{
		error(message, object, feature, idx);
	}
	
	public void reportWarning(String message, EObject object,
								EStructuralFeature feature) {
		warning(message, object, feature, ValidationMessageAcceptor.INSIGNIFICANT_INDEX);
	}
}
