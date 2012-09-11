package org.franca.deploymodel.dsl.validation;

import java.util.List;
import java.util.Set;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EReference;
import org.eclipse.emf.ecore.EStructuralFeature;
import org.eclipse.xtext.validation.Check;
import org.eclipse.xtext.validation.ValidationMessageAcceptor;
import org.franca.core.framework.FrancaHelpers;
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
import org.franca.core.franca.FTypeRef;
import org.franca.core.franca.FUnionType;
import org.franca.deploymodel.dsl.FDInterfaceMapper;
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
import org.franca.deploymodel.dsl.fDeploy.FDPredefinedTypeId;
import org.franca.deploymodel.dsl.fDeploy.FDProperty;
import org.franca.deploymodel.dsl.fDeploy.FDPropertyDecl;
import org.franca.deploymodel.dsl.fDeploy.FDPropertyFlag;
import org.franca.deploymodel.dsl.fDeploy.FDPropertyHost;
import org.franca.deploymodel.dsl.fDeploy.FDProvider;
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
import com.google.common.collect.Sets;

 

public class FDeployJavaValidator extends AbstractFDeployJavaValidator
	implements ValidationMessageReporter {

	/**
	 * An issue ID for the "Missing mandatory property" error.
	 * Issue data will contain a comma separated string with the missing properties
	 */
	public static final String MISSING_MANDATORY_PROPERTIES  = "MISSING_MANDATORY_PROPERTIES";

	private final String msg = " must be specified because of mandatory properties";

	
	// *****************************************************************************
	// basic checks
	
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
		Set<FDSpecification> visited = Sets.newHashSet();
		FDSpecification s = spec;
		FDSpecification last = null;
		do {
			visited.add(s);
			last = s;
			s = s.getBase();
			if (s!=null && visited.contains(s)) {
				error("Inheritance cycle for specification " + last.getName(), last,
						FDeployPackage.Literals.FD_SPECIFICATION__BASE, -1);
				return;
			}
		} while (s != null);
	}

	
	// *****************************************************************************
	// check for missing properties
	
	@Check
	public void checkPropertiesComplete (FDProvider elem) {
		// check own properties
		FDSpecification spec = FDModelHelper.getRootElement(elem).getSpec();
		checkElementProperties(spec, elem, FDeployPackage.Literals.FD_PROVIDER__NAME);
	}
	
	@Check
	public void checkPropertiesComplete (FDTypes elem) {
		// we do not check own properties - there will be none
		FDSpecification spec = FDModelHelper.getRootElement(elem).getSpec();
		//checkElementProperties(spec, elem, FDeployPackage.Literals.FD_TYPES__PACKAGE);

		// check child elements recursively
		FDSpecificationExtender specHelper = new FDSpecificationExtender(spec);
		FDInterfaceMapper mapper = new FDInterfaceMapper(elem);
		checkTypes(elem.getPackage().getTypes(), specHelper, mapper, spec,
				FDeployPackage.Literals.FD_TYPES__PACKAGE);
	}
	
	
	@Check
	public void checkPropertiesComplete (FDInterface elem) {
		// check own properties
		FDSpecification spec = FDModelHelper.getRootElement(elem).getSpec();
		checkElementProperties(spec, elem, FDeployPackage.Literals.FD_INTERFACE__TARGET);
		
		// check child elements recursively
		FDSpecificationExtender specHelper = new FDSpecificationExtender(spec);
		FDInterfaceMapper mapper = new FDInterfaceMapper(elem);
		FInterface target = elem.getTarget();
		for(FAttribute tc : target.getAttributes()) {
			FDAttribute c = (FDAttribute) mapper.getFDElement(tc);
			if (c==null) {
				if (mustBeDefined(specHelper, tc)) {
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
				if (mustBeDefined(specHelper, tc)) {
					error("Method '" + tc.getName() + "'" + msg,
							FDeployPackage.Literals.FD_INTERFACE__TARGET);
				}
			} else {
				checkElementProperties(spec, c, FDeployPackage.Literals.FD_METHOD__TARGET);
				checkArgumentList(specHelper, mapper, spec, tc.getInArgs(), c,
						"Input", FDeployPackage.Literals.FD_METHOD__TARGET);
				checkArgumentList(specHelper, mapper, spec, tc.getOutArgs(), c,
						"Output", FDeployPackage.Literals.FD_METHOD__TARGET);
			}
		}

		for(FBroadcast tc : target.getBroadcasts()) {
			FDBroadcast c = (FDBroadcast) mapper.getFDElement(tc);
			if (c==null) {
				if (mustBeDefined(specHelper, tc)) {
					error("Broadcast '" + tc.getName() + "'" + msg,
							FDeployPackage.Literals.FD_INTERFACE__TARGET);
				}
			} else {
				checkElementProperties(spec, c, FDeployPackage.Literals.FD_BROADCAST__TARGET);
				checkArgumentList(specHelper, mapper, spec, tc.getOutArgs(), c,
						"Output", FDeployPackage.Literals.FD_BROADCAST__TARGET);
			}
		}
		
		checkTypes(target.getTypes(), specHelper, mapper, spec,
				FDeployPackage.Literals.FD_INTERFACE__TARGET);
	}
	
	
	private void checkTypes (List<FType> types, FDSpecificationExtender specHelper,
			FDInterfaceMapper mapper, FDSpecification spec,
			EStructuralFeature parentFeature)
	{
		for(FType tc : types) {
			if (tc instanceof FArrayType) {
				FDArray c = (FDArray) mapper.getFDElement(tc);
				if (c==null) {
					if (mustBeDefined(specHelper, (FArrayType)tc)) {
						error("Array '" + tc.getName() + "'" + msg, parentFeature);
					}
				} else {
					checkElementProperties(spec, c, FDeployPackage.Literals.FD_ARRAY__TARGET);
				}
			} else if (tc instanceof FStructType) {
				FDStruct c = (FDStruct) mapper.getFDElement(tc);
				if (c==null) {
					if (mustBeDefined(specHelper, (FStructType)tc)) {
						error("Struct '" + tc.getName() + "'" + msg, parentFeature);
					}
				} else {
					checkElementProperties(spec, c, FDeployPackage.Literals.FD_STRUCT__TARGET);
					checkFieldsList(specHelper, mapper, spec, ((FStructType) tc).getElements(), c,
							FDeployPackage.Literals.FD_STRUCT__TARGET, "Struct");
				}
			} else if (tc instanceof FUnionType) {
				FDUnion c = (FDUnion) mapper.getFDElement(tc);
				if (c==null) {
					if (mustBeDefined(specHelper, (FUnionType)tc)) {
						error("Union '" + tc.getName() + "'" + msg, parentFeature);
					}
				} else {
					checkElementProperties(spec, c, FDeployPackage.Literals.FD_UNION__TARGET);
					checkFieldsList(specHelper, mapper, spec, ((FUnionType) tc).getElements(), c,
							FDeployPackage.Literals.FD_UNION__TARGET, "Union");
				}
			} else if (tc instanceof FEnumerationType) {
				FDEnumeration c = (FDEnumeration) mapper.getFDElement(tc);
				if (c==null) {
					if (mustBeDefined(specHelper, (FEnumerationType)tc)) {
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
			FDInterfaceMapper mapper, FDSpecification spec, List<FArgument> args,
			FDElement parent, String tag, EStructuralFeature feature)
	{
		for(FArgument tc : args) {
			FDArgument c = (FDArgument) mapper.getFDElement(tc);
			if (c==null) {
				if (mustBeDefined(specHelper, tc)) {
					error(tag + " argument '" + tc.getName() + "'" + msg, parent, feature, -1);
				}
			} else {
				checkElementProperties(spec, c, FDeployPackage.Literals.FD_ARGUMENT__TARGET);
			}
		}
	}
	
	private void checkFieldsList (FDSpecificationExtender specHelper,
			FDInterfaceMapper mapper, FDSpecification spec, List<FField> fields,
			FDElement parent, EStructuralFeature feature, String tag)
	{
		for(FField tc : fields) {
			FDField c = (FDField) mapper.getFDElement(tc);
			if (c==null) {
				if (mustBeDefined(specHelper, tc)) {
					error(tag + " field '" + tc.getName() + "'" + msg, parent, feature, -1);
				}
			} else {
				checkElementProperties(spec, c, FDeployPackage.Literals.FD_FIELD__TARGET);
			}
		}
	}
	
	private void checkEnumeratorsList (FDSpecificationExtender specHelper,
			FDInterfaceMapper mapper, FDSpecification spec, List<FEnumerator> enumerators,
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
	
	private boolean mustBeDefined (FDSpecificationExtender specHelper, FMethod target) {
		if (specHelper.isMandatory(FDPropertyHost.METHODS))
			return true;
		
		if (target.getInArgs().isEmpty() && target.getOutArgs().isEmpty())
			return false;
		
		if (specHelper.isMandatory(FDPropertyHost.ARGUMENTS))
			return true;

		for(FArgument arg : target.getInArgs()) {
			if (mustBeDefined(specHelper, arg))
				return true;
		}
		
		for(FArgument arg : target.getOutArgs()) {
			if (mustBeDefined(specHelper, arg))
				return true;
		}
		
		return false;
	}
	
	private boolean mustBeDefined (FDSpecificationExtender specHelper, FBroadcast target) {
		if (specHelper.isMandatory(FDPropertyHost.BROADCASTS))
			return true;
		
		if (target.getOutArgs().isEmpty())
			return false;
		
		if (specHelper.isMandatory(FDPropertyHost.ARGUMENTS))
			return true;

		for(FArgument arg : target.getOutArgs()) {
			if (mustBeDefined(specHelper, arg))
				return true;
		}
		
		return false;
	}
	
	private boolean mustBeDefined (FDSpecificationExtender specHelper, FArrayType target) {
		if (specHelper.isMandatory(FDPropertyHost.ARRAYS))
			return true;
		
		return false;
	}
	
	private boolean mustBeDefined (FDSpecificationExtender specHelper, FStructType target) {
		// activate this if STRUCTS gets a property host (currently not defined in FDeploy.xtext)
//		if (specHelper.isMandatory(FDPropertyHost.STRUCTS))
//			return true;
		
		return mustBeDefined(specHelper, target.getElements(), FDPropertyHost.STRUCT_FIELDS);
	}
	
	private boolean mustBeDefined (FDSpecificationExtender specHelper, FUnionType target) {
		// activate this if UNIONS gets a property host (currently not defined in FDeploy.xtext)
//		if (specHelper.isMandatory(FDPropertyHost.UNIONS))
//			return true;
		
		return mustBeDefined(specHelper, target.getElements(), FDPropertyHost.UNION_FIELDS);
	}

	private boolean mustBeDefined (FDSpecificationExtender specHelper, List<FField> targets, FDPropertyHost host) {
		if (targets.isEmpty())
			return false;
		
		if (specHelper.isMandatory(host))
			return true;

		for(FField f : targets) {
			if (mustBeDefined(specHelper, f))
				return true;
		}
		
		return false;
	}
	
	private boolean mustBeDefined (FDSpecificationExtender specHelper, FEnumerationType target) {
		if (specHelper.isMandatory(FDPropertyHost.ENUMERATIONS))
			return true;
		
		if (target.getEnumerators().isEmpty())
			return false;
		
		if (specHelper.isMandatory(FDPropertyHost.ENUMERATORS))
			return true;

		return false;
	}

	private boolean mustBeDefined (FDSpecificationExtender specHelper, FArgument target) {
		if (specHelper.isMandatory(FDPropertyHost.ARGUMENTS))
			return true;

		return mustBeDefined(specHelper, target.getType());
	}

	private boolean mustBeDefined (FDSpecificationExtender specHelper, FAttribute target) {
		if (specHelper.isMandatory(FDPropertyHost.ATTRIBUTES))
			return true;

		return mustBeDefined(specHelper, target.getType());
	}

	private boolean mustBeDefined (FDSpecificationExtender specHelper, FField target) {
		boolean isStruct = target.eContainer() instanceof FStructType;
		if (specHelper.isMandatory(isStruct ? FDPropertyHost.STRUCT_FIELDS : FDPropertyHost.UNION_FIELDS))
			return true;

		return mustBeDefined(specHelper, target.getType());
	}

	private boolean mustBeDefined (FDSpecificationExtender specHelper, FTypeRef target) {
		if (FrancaHelpers.isString(target)) {
			if (specHelper.isMandatory(FDPropertyHost.STRINGS)) {
				return true;
			}
		} else if (FrancaHelpers.isInteger(target)) {
			if (specHelper.isMandatory(FDPropertyHost.INTEGERS) || specHelper.isMandatory(FDPropertyHost.NUMBERS)) {
				return true;
			}
		} else if (FrancaHelpers.isFloatingPoint(target)) {
			if (specHelper.isMandatory(FDPropertyHost.FLOATS) || specHelper.isMandatory(FDPropertyHost.NUMBERS)) {
				return true;
			}
		}
		return false;
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

	public void reportError(String message, EObject object, EStructuralFeature feature)
	{
		error(message, object, feature, ValidationMessageAcceptor.INSIGNIFICANT_INDEX);
	}

	public void reportWarning(String message, EObject object, EStructuralFeature feature)
	{
		warning(message, object, feature, ValidationMessageAcceptor.INSIGNIFICANT_INDEX);
	}
}
