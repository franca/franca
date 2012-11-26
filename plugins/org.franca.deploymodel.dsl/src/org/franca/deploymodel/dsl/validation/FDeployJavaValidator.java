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
import org.franca.deploymodel.dsl.FDMapper;
import org.franca.deploymodel.dsl.FDModelHelper;
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

	/**
	 * An issue ID for the "Missing mandatory property" error.
	 * Issue data will contain a comma separated string with the missing properties
	 */
	public static final String MISSING_MANDATORY_PROPERTIES  = "MISSING_MANDATORY_PROPERTIES";

	private final String msg = " must be specified because of mandatory properties";

	
	// delegate to FDeployValidator
	FDeployValidator aux = new FDeployValidator(this);

	
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
		aux.checkRootElement(elem);
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
		String n = prop.getName();
		if (! Character.isUpperCase(n.charAt(0))) {
			error("Property names must begin with an uppercase character",
					FDeployPackage.Literals.FD_PROPERTY_DECL__NAME);
		}
	}
	
   @Check
   public void checkDeclaration(FDDeclaration decl) {
       ValidationHelpers.checkDuplicates(this, decl.getProperties(), FDeployPackage.Literals.FD_PROPERTY_DECL__NAME, "property name");
   }
	  
	@Check
	public void checkBaseSpec (FDSpecification spec) {
		FDSpecification cycleSpec = aux.getCyclicBaseSpec(spec);
		if (cycleSpec!=null) {
			error("Inheritance cycle for specification " + cycleSpec.getName(), cycleSpec,
						FDeployPackage.Literals.FD_SPECIFICATION__BASE, -1);
				return;
			}
	}

	
	// *****************************************************************************
	// check for missing properties
	
	@Check
	public void checkPropertiesComplete (FDProvider elem) {
		// check own properties
		FDSpecification spec = FDModelHelper.getRootElement(elem).getSpec();
		checkElementProperties(spec, elem, FDeployPackage.Literals.FD_ROOT_ELEMENT__NAME);
	}
	
	@Check
	public void checkPropertiesComplete (FDTypes elem) {
		// we do not check own properties - there will be none
		FDSpecification spec = FDModelHelper.getRootElement(elem).getSpec();
		//checkElementProperties(spec, elem, FDeployPackage.Literals.FD_TYPES__PACKAGE);

		// check child elements recursively
		FDSpecificationExtender specHelper = new FDSpecificationExtender(spec);
		PropertyDefChecker checker = new PropertyDefChecker(specHelper);
		FDMapper mapper = new FDMapper(elem);
		List<FType> targetTypes = elem.getTarget().getTypes();
		checkLocalTypes(targetTypes, specHelper, checker, mapper, spec,
				FDeployPackage.Literals.FD_TYPES__TARGET);

		aux.checkUsedTypes(elem, targetTypes, checker);
	}
	
	
	@Check
	public void checkPropertiesComplete (FDInterface elem) {
		// check own properties
		FDSpecification spec = FDModelHelper.getRootElement(elem).getSpec();
		checkElementProperties(spec, elem, FDeployPackage.Literals.FD_INTERFACE__TARGET);
		
		// check child elements recursively
		FDSpecificationExtender specHelper = new FDSpecificationExtender(spec);
		PropertyDefChecker checker = new PropertyDefChecker(specHelper);
		FDMapper mapper = new FDMapper(elem);
		FInterface target = elem.getTarget();
		for(FAttribute tc : target.getAttributes()) {
			FDAttribute c = (FDAttribute) mapper.getFDElement(tc);
			if (c==null) {
				if (checker.mustBeDefined(tc)) {
					error("Attribute '" + tc.getName() + "'" + msg,
							FDeployPackage.Literals.FD_INTERFACE__TARGET);
				}
			} else {
				checkElementProperties(spec, c, FDeployPackage.Literals.FD_ATTRIBUTE__TARGET);
			}
		}

		for(FMethod tc : target.getMethods()) {
			FDMethod c = (FDMethod) mapper.getFDElement(tc);
			if (c==null) {
				if (checker.mustBeDefined(tc)) {
					error("Method '" + tc.getName() + "'" + msg,
							FDeployPackage.Literals.FD_INTERFACE__TARGET);
				}
			} else {
				checkElementProperties(spec, c, FDeployPackage.Literals.FD_METHOD__TARGET);
				checkArgumentList(specHelper, checker, mapper, spec, tc.getInArgs(), c,
						"Input", FDeployPackage.Literals.FD_METHOD__TARGET);
				checkArgumentList(specHelper, checker, mapper, spec, tc.getOutArgs(), c,
						"Output", FDeployPackage.Literals.FD_METHOD__TARGET);
			}
		}

		for(FBroadcast tc : target.getBroadcasts()) {
			FDBroadcast c = (FDBroadcast) mapper.getFDElement(tc);
			if (c==null) {
				if (checker.mustBeDefined(tc)) {
					error("Broadcast '" + tc.getName() + "'" + msg,
							FDeployPackage.Literals.FD_INTERFACE__TARGET);
				}
			} else {
				checkElementProperties(spec, c, FDeployPackage.Literals.FD_BROADCAST__TARGET);
				checkArgumentList(specHelper, checker, mapper, spec, tc.getOutArgs(), c,
						"Output", FDeployPackage.Literals.FD_BROADCAST__TARGET);
			}
		}
		
		checkLocalTypes(target.getTypes(), specHelper, checker, mapper, spec,
				FDeployPackage.Literals.FD_INTERFACE__TARGET);
		
		
		aux.checkUsedTypes(elem, target.getTypes(), checker);
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
						error("Array '" + tc.getName() + "'" + msg, parentFeature);
					}
				} else {
					checkElementProperties(spec, c, FDeployPackage.Literals.FD_ARRAY__TARGET);
				}
			} else if (tc instanceof FStructType) {
				FDStruct c = (FDStruct) mapper.getFDElement(tc);
				if (c==null) {
					if (checker.mustBeDefined((FStructType)tc)) {
						error("Struct '" + tc.getName() + "'" + msg, parentFeature);
					}
				} else {
					checkElementProperties(spec, c, FDeployPackage.Literals.FD_STRUCT__TARGET);
					checkFieldsList(specHelper, checker, mapper, spec, ((FStructType) tc).getElements(), c,
							FDeployPackage.Literals.FD_STRUCT__TARGET, "Struct");
				}
			} else if (tc instanceof FUnionType) {
				FDUnion c = (FDUnion) mapper.getFDElement(tc);
				if (c==null) {
					if (checker.mustBeDefined((FUnionType)tc)) {
						error("Union '" + tc.getName() + "'" + msg, parentFeature);
					}
				} else {
					checkElementProperties(spec, c, FDeployPackage.Literals.FD_UNION__TARGET);
					checkFieldsList(specHelper, checker, mapper, spec, ((FUnionType) tc).getElements(), c,
							FDeployPackage.Literals.FD_UNION__TARGET, "Union");
				}
			} else if (tc instanceof FEnumerationType) {
				FDEnumeration c = (FDEnumeration) mapper.getFDElement(tc);
				if (c==null) {
					if (checker.mustBeDefined((FEnumerationType)tc)) {
						error("Enumeration '" + tc.getName() + "'" + msg, parentFeature);
					}
				} else {
					checkElementProperties(spec, c, FDeployPackage.Literals.FD_ENUMERATION__TARGET);
					checkEnumeratorsList(specHelper, mapper, spec, ((FEnumerationType) tc).getEnumerators(), c,
							FDeployPackage.Literals.FD_ENUMERATION__TARGET);
				}
			}
		}
	}

	private void checkArgumentList (FDSpecificationExtender specHelper,
			PropertyDefChecker checker,
			FDMapper mapper, FDSpecification spec, List<FArgument> args,
			FDElement parent, String tag, EStructuralFeature feature)
	{
		for(FArgument tc : args) {
			FDArgument c = (FDArgument) mapper.getFDElement(tc);
			if (c==null) {
				if (checker.mustBeDefined(tc)) {
					error(tag + " argument '" + tc.getName() + "'" + msg, parent, feature, -1);
				}
			} else {
				checkElementProperties(spec, c, FDeployPackage.Literals.FD_ARGUMENT__TARGET);
			}
		}
	}
	
	private void checkFieldsList (FDSpecificationExtender specHelper,
			PropertyDefChecker checker,
			FDMapper mapper, FDSpecification spec, List<FField> fields,
			FDElement parent, EStructuralFeature feature, String tag)
	{
		for(FField tc : fields) {
			FDField c = (FDField) mapper.getFDElement(tc);
			if (c==null) {
				if (checker.mustBeDefined(tc)) {
					error(tag + " field '" + tc.getName() + "'" + msg, parent, feature, -1);
				}
			} else {
				checkElementProperties(spec, c, FDeployPackage.Literals.FD_FIELD__TARGET);
			}
		}
	}
	
	private void checkEnumeratorsList (FDSpecificationExtender specHelper,
			FDMapper mapper, FDSpecification spec, List<FEnumerator> enumerators,
			FDElement parent, EStructuralFeature feature)
	{
		for(FEnumerator tc : enumerators) {
			FDEnumValue c = (FDEnumValue) mapper.getFDElement(tc);
			if (c==null) {
				if (specHelper.isMandatory(FDPropertyHost.ENUMERATORS)) {
					error("Enumerator '" + tc.getName() + "'" + msg, parent, feature, -1);
				}
			} else {
				checkElementProperties(spec, c, FDeployPackage.Literals.FD_ENUM_VALUE__TARGET);
			}
		}
	}
	
	
	// *****************************************************************************

	@Check
	public void checkPropertiesComplete (FDInterfaceInstance elem) {
		// check own properties
		FDSpecification spec = FDModelHelper.getRootElement(elem).getSpec();
		checkElementProperties(spec, elem, FDeployPackage.Literals.FD_INTERFACE_INSTANCE__TARGET);
	}
	

	private void checkElementProperties (FDSpecification spec, FDElement elem, EStructuralFeature feature)
	{
		List<FDPropertyDecl> decls = FDModelHelper.getAllPropertyDecls(spec, elem);
		List<String> missing = Lists.newArrayList();
		for(FDPropertyDecl decl : decls) {
			if (FDModelHelper.isMandatory(decl)) {
				if (! contains(elem.getProperties(), decl)) {
					missing.add(decl.getName());
				}
			}
		}
		
		if (! missing.isEmpty()) {
			String issue = "";
			String msg = missing.size()==1 ? "property " : "properties ";
			boolean sep = false; 
			for(String s : missing) {
				if (sep) {
					issue += ", ";
					msg += ", ";
				}
				sep = true;
				issue += s;
				msg += "'" + s + "'";
			}
			
			error("Missing mandatory " + msg, elem, feature, -1,
					MISSING_MANDATORY_PROPERTIES, issue);
		}
	}


	private boolean contains (List<FDProperty> properties, FDPropertyDecl decl) {
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
	public void checkPropertyFlagType (FDPropertyFlag flag) {
		if (flag.getDefault()==null)
			return;
		
		FDPropertyDecl decl = (FDPropertyDecl)flag.eContainer();
		FDTypeRef typeRef = decl.getType();
		FDComplexValue value = flag.getDefault();
		if (value.getSingle()!=null) {
			if (typeRef.getArray()!=null)
				error("Default must be an array!", FDeployPackage.Literals.FD_PROPERTY_FLAG__DEFAULT);
			else
				checkValueType(typeRef, value.getSingle(), FDeployPackage.Literals.FD_PROPERTY_FLAG__DEFAULT, -1);
		} else if (value.getArray()!=null) {
			if (typeRef.getArray()==null) {
				error("Default must be a single type, not an array!", FDeployPackage.Literals.FD_PROPERTY_FLAG__DEFAULT);
			} else
				checkValueArrayType(typeRef, value.getArray());
		}
	}

	@Check
	public void checkPropertyValueType (FDProperty prop) {
		FDTypeRef typeRef = prop.getDecl().getType();
		FDComplexValue value = prop.getValue();
		if (value.getSingle()!=null) {
			if (typeRef.getArray()!=null)
				error("Invalid type, expected array!", FDeployPackage.Literals.FD_PROPERTY__VALUE);
			else
				checkValueType(typeRef, value.getSingle(), FDeployPackage.Literals.FD_PROPERTY__VALUE, -1);
		} else if (value.getArray()!=null) {
			if (typeRef.getArray()==null)
				error("Invalid array type, expected single value!", FDeployPackage.Literals.FD_PROPERTY__VALUE);
			else
				checkValueArrayType(typeRef, value.getArray());
		}
	}
	
	private void checkValueType (FDTypeRef typeRef, FDValue value, EReference literal, int index) {
		if (typeRef.getComplex()==null) {
			// this is a predefined type
			switch (typeRef.getPredefined().getValue()) {
			case FDPredefinedTypeId.INTEGER_VALUE:
				if (! (value instanceof FDInteger)) {
					error("Invalid type, expected Integer constant",
							value.eContainer(), literal, index);
				}
				break;
			case FDPredefinedTypeId.STRING_VALUE:
				if (! (value instanceof FDString)) {
					error("Invalid type, expected String constant",
							value.eContainer(), literal, index);
				}
				break;
			case FDPredefinedTypeId.BOOLEAN_VALUE:
				if (! (value instanceof FDBoolean)) {
					error("Invalid type, expected 'true' or 'false'",
							value.eContainer(), literal, index);
				}
				break;
			}
		} else {
			FDType type = typeRef.getComplex();
			if (type instanceof FDEnumType) {
				if (! (value instanceof FDEnum)) {
					error("Invalid type, expected enumerator",
							value.eContainer(), literal, index);
				}
			}
		}
	}
	
	private void checkValueArrayType (FDTypeRef typeRef, FDValueArray array) {
		int i = 0;
		for(FDValue value : array.getValues()) {
			checkValueType(typeRef, value, FDeployPackage.Literals.FD_VALUE_ARRAY__VALUES, i);
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
