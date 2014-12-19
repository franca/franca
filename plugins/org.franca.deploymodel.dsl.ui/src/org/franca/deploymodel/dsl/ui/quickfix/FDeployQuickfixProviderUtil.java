package org.franca.deploymodel.dsl.ui.quickfix;

import java.util.List;

import org.eclipse.emf.common.util.EList;
import org.franca.core.franca.FArgument;
import org.franca.core.franca.FArrayType;
import org.franca.core.franca.FAttribute;
import org.franca.core.franca.FBroadcast;
import org.franca.core.franca.FEnumerationType;
import org.franca.core.franca.FEnumerator;
import org.franca.core.franca.FField;
import org.franca.core.franca.FMethod;
import org.franca.core.franca.FStructType;
import org.franca.core.franca.FType;
import org.franca.core.franca.FUnionType;
import org.franca.deploymodel.dsl.fDeploy.FDArgument;
import org.franca.deploymodel.dsl.fDeploy.FDArgumentList;
import org.franca.deploymodel.dsl.fDeploy.FDArray;
import org.franca.deploymodel.dsl.fDeploy.FDAttribute;
import org.franca.deploymodel.dsl.fDeploy.FDBoolean;
import org.franca.deploymodel.dsl.fDeploy.FDBroadcast;
import org.franca.deploymodel.dsl.fDeploy.FDComplexValue;
import org.franca.deploymodel.dsl.fDeploy.FDElement;
import org.franca.deploymodel.dsl.fDeploy.FDEnumType;
import org.franca.deploymodel.dsl.fDeploy.FDEnumValue;
import org.franca.deploymodel.dsl.fDeploy.FDEnumeration;
import org.franca.deploymodel.dsl.fDeploy.FDField;
import org.franca.deploymodel.dsl.fDeploy.FDGeneric;
import org.franca.deploymodel.dsl.fDeploy.FDInteger;
import org.franca.deploymodel.dsl.fDeploy.FDInterface;
import org.franca.deploymodel.dsl.fDeploy.FDInterfaceInstance;
import org.franca.deploymodel.dsl.fDeploy.FDInterfaceRef;
import org.franca.deploymodel.dsl.fDeploy.FDMethod;
import org.franca.deploymodel.dsl.fDeploy.FDPredefinedTypeId;
import org.franca.deploymodel.dsl.fDeploy.FDProperty;
import org.franca.deploymodel.dsl.fDeploy.FDPropertyDecl;
import org.franca.deploymodel.dsl.fDeploy.FDString;
import org.franca.deploymodel.dsl.fDeploy.FDStruct;
import org.franca.deploymodel.dsl.fDeploy.FDTypeDef;
import org.franca.deploymodel.dsl.fDeploy.FDTypeRef;
import org.franca.deploymodel.dsl.fDeploy.FDTypes;
import org.franca.deploymodel.dsl.fDeploy.FDUnion;
import org.franca.deploymodel.dsl.fDeploy.FDValue;
import org.franca.deploymodel.dsl.fDeploy.FDValueArray;
import org.franca.deploymodel.dsl.fDeploy.FDeployFactory;

public class FDeployQuickfixProviderUtil {

	public static <T> T getTypeForElement(Class<T> type, String name,
			List<FType> types) {
		for (FType t : types) {
			if (type.isAssignableFrom(t.getClass()) && t.getName() == name) {
				return type.cast(t);
			}
		}
		return null;
	}

	public static boolean hasPropertyDeclaration(List<FDProperty> props,
			FDPropertyDecl decl) {
		for (FDProperty p : props) {
			if (p.getDecl().getName() == decl.getName()) {
				return true;
			}
		}
		return false;
	}

	public static FDArgument getArgument(FDArgumentList args, FArgument arg) {
		for (FDArgument fdArg : args.getArguments()) {
			if (fdArg.getTarget().equals(arg)) {
				return fdArg;
			}
		}
		return null;
	}
	
	public static FDField getField(EList<FDField> fields, FField field) {
		for (FDField f : fields) {
			if (f.getTarget().equals(field)) {
				return f;
			}
		}
		return null;
	}
	
	public static FDEnumValue getEnumerator(EList<FDEnumValue> enumerators,	FEnumerator e) {
		for (FDEnumValue fdEnum : enumerators) {
			if (fdEnum.getTarget().equals(e)) {
				return fdEnum;
			}
		}
		return null;
	}

	public static FDComplexValue generateDefaultValue(FDElement element, FDTypeRef typeRef) {
		FDValue simple = null;
		if (typeRef.getComplex() == null) {
			switch (typeRef.getPredefined().getValue()) {
				case FDPredefinedTypeId.BOOLEAN_VALUE:
					FDBoolean boolVal = FDeployFactory.eINSTANCE.createFDBoolean();
					boolVal.setValue("false");
					simple = boolVal;
					break;
				case FDPredefinedTypeId.INTEGER_VALUE:
					FDInteger intVal = FDeployFactory.eINSTANCE.createFDInteger();
					intVal.setValue(0);
					simple = intVal;
					break;
				case FDPredefinedTypeId.STRING_VALUE:
					FDString strVal = FDeployFactory.eINSTANCE.createFDString();
					strVal.setValue("");
					simple = strVal;
					break;
				case FDPredefinedTypeId.INTERFACE_VALUE:
					FDInterfaceRef ifaceVal = FDeployFactory.eINSTANCE.createFDInterfaceRef();
					ifaceVal.setValue(((FDInterface) element).getTarget());
					simple = ifaceVal;
					break;
				case FDPredefinedTypeId.INSTANCE_VALUE:
					FDGeneric instVal = FDeployFactory.eINSTANCE.createFDGeneric();
					instVal.setValue(((FDInterfaceInstance) element).getTarget());
					simple = instVal;
					break;
			}
		} else {
			if (typeRef.getComplex() instanceof FDEnumType) {
				FDEnumType enumeration = (FDEnumType) typeRef.getComplex();
				FDGeneric enumVal = FDeployFactory.eINSTANCE.createFDGeneric();
				enumVal.setValue(enumeration.getEnumerators().get(0));
				simple = enumVal;
			}
		}

		if (simple != null) {
			FDComplexValue ret = FDeployFactory.eINSTANCE
					.createFDComplexValue();
			if (typeRef.getArray() == null) {
				ret.setSingle(simple);
			} else {
				FDValueArray arrayVal = FDeployFactory.eINSTANCE
						.createFDValueArray();
				arrayVal.getValues().add(simple);
				ret.setArray(arrayVal);
			}
			return ret;
		}

		return null;
	}

	public static FDAttribute getOrCreateAttribute(
			FDInterface deploymentInterface, String elementName) {
		for (FDAttribute a : deploymentInterface.getAttributes()) {
			if (a.getTarget().getName() == elementName) {
				return a;
			}
		}

		FAttribute attributeTarget = null;
		for (FAttribute a : deploymentInterface.getTarget().getAttributes()) {
			if (a.getName() == elementName) {
				attributeTarget = a;
				break;
			}
		}
		if (attributeTarget != null) {
			FDAttribute attribute = FDeployFactory.eINSTANCE
					.createFDAttribute();
			attribute.setTarget(attributeTarget);
			deploymentInterface.getAttributes().add(attribute);
			return attribute;
		}

		return null;
	}

	public static FDMethod getOrCreateMethod(FDInterface deploymentInterface,
			String elementName) {
		for (FDMethod m : deploymentInterface.getMethods()) {
			if (m.getTarget().getName() == elementName) {
				return m;
			}
		}

		FMethod methodTarget = null;
		for (FMethod m : deploymentInterface.getTarget().getMethods()) {
			if (m.getName() == elementName) {
				methodTarget = m;
			}
		}
		if (methodTarget != null) {
			FDMethod method = FDeployFactory.eINSTANCE.createFDMethod();
			method.setTarget(methodTarget);
			deploymentInterface.getMethods().add(method);
			return method;
		}

		return null;
	}

	public static FDBroadcast getOrCreateBroadcast(
			FDInterface deploymentInterface, String elementName) {

		for (FDBroadcast b : deploymentInterface.getBroadcasts()) {
			if (b.getTarget().getName() == elementName) {
				return b;
			}
		}

		FBroadcast broadcastTarget = null;

		for (FBroadcast broadcast : deploymentInterface.getTarget()
				.getBroadcasts()) {
			if (broadcast.getName() == elementName) {
				broadcastTarget = broadcast;
			}
		}

		if (broadcastTarget != null) {
			FDBroadcast broadcast = FDeployFactory.eINSTANCE
					.createFDBroadcast();
			broadcast.setTarget(broadcastTarget);
			deploymentInterface.getBroadcasts().add(broadcast);
			return broadcast;
		}
		return null;

	}
	
	public static FDArray getOrCreateArray(FDTypes types,
			String elementName) {
		for (FDTypeDef a : types.getTypes()) {
			if (a instanceof FDArray
					&& ((FDArray) a).getTarget().getName() == elementName) {
				return (FDArray) a;
			}
		}

		FArrayType arrayTarget = getTypeForElement(FArrayType.class,
				elementName, types.getTarget().getTypes());
		if (arrayTarget != null) {
			FDArray array = FDeployFactory.eINSTANCE.createFDArray();
			array.setTarget(arrayTarget);
			types.getTypes().add(array);
			return array;
		}

		return null;
	}

	public static FDArray getOrCreateArray(FDInterface deploymentInterface,
			String elementName) {

		for (FDTypeDef a : deploymentInterface.getTypes()) {
			if (a instanceof FDArray
					&& ((FDArray) a).getTarget().getName() == elementName) {
				return (FDArray) a;
			}
		}

		FArrayType arrayTarget = getTypeForElement(FArrayType.class,
				elementName, deploymentInterface.getTarget().getTypes());
		if (arrayTarget != null) {
			FDArray array = FDeployFactory.eINSTANCE.createFDArray();
			array.setTarget(arrayTarget);
			deploymentInterface.getTypes().add(array);
			return array;
		}

		return null;
	}
	
	public static FDStruct getOrCreateStruct(FDTypes types,
			String elementName) {
		for (FDTypeDef s : types.getTypes()) {
			if (s instanceof FDStruct
					&& ((FDStruct) s).getTarget().getName() == elementName) {
				return (FDStruct) s;
			}
		}

		FStructType structTarget = getTypeForElement(FStructType.class,
				elementName, types.getTarget().getTypes());
		if (structTarget != null) {
			FDStruct struct = FDeployFactory.eINSTANCE.createFDStruct();
			struct.setTarget(structTarget);
			types.getTypes().add(struct);
			return struct;
		}

		return null;
	}

	public static FDStruct getOrCreateStruct(FDInterface deploymentInterface,
			String elementName) {
		for (FDTypeDef s : deploymentInterface.getTypes()) {
			if (s instanceof FDStruct
					&& ((FDStruct) s).getTarget().getName() == elementName) {
				return (FDStruct) s;
			}
		}

		FStructType structTarget = getTypeForElement(FStructType.class,
				elementName, deploymentInterface.getTarget().getTypes());
		if (structTarget != null) {
			FDStruct struct = FDeployFactory.eINSTANCE.createFDStruct();
			struct.setTarget(structTarget);
			deploymentInterface.getTypes().add(struct);
			return struct;
		}

		return null;
	}
	
	public static FDEnumeration getOrCreateEnumeration(
			FDTypes types, String elementName) {
		for (FDTypeDef e : types.getTypes()) {
			if (e instanceof FDEnumeration
					&& ((FDEnumeration) e).getTarget().getName() == elementName) {
				return (FDEnumeration) e;
			}
		}

		FEnumerationType enumerationTarget = getTypeForElement(
				FEnumerationType.class, elementName,
				types.getTarget().getTypes());
		if (enumerationTarget != null) {
			FDEnumeration enumeration = FDeployFactory.eINSTANCE
					.createFDEnumeration();
			enumeration.setTarget(enumerationTarget);
			types.getTypes().add(enumeration);
			return enumeration;
		}

		return null;
	}

	public static FDEnumeration getOrCreateEnumeration(
			FDInterface deploymentInterface, String elementName) {
		for (FDTypeDef e : deploymentInterface.getTypes()) {
			if (e instanceof FDEnumeration
					&& ((FDEnumeration) e).getTarget().getName() == elementName) {
				return (FDEnumeration) e;
			}
		}

		FEnumerationType enumerationTarget = getTypeForElement(
				FEnumerationType.class, elementName,
				deploymentInterface.getTarget().getTypes());
		if (enumerationTarget != null) {
			FDEnumeration enumeration = FDeployFactory.eINSTANCE
					.createFDEnumeration();
			enumeration.setTarget(enumerationTarget);
			deploymentInterface.getTypes().add(enumeration);
			return enumeration;
		}

		return null;
	}
	
	public static FDUnion getOrCreateUnion(FDTypes types,
			String elementName) {

		for (FDTypeDef u : types.getTypes()) {
			if (u instanceof FDUnion
					&& ((FDUnion) u).getTarget().getName() == elementName) {
				return (FDUnion) u;
			}
		}

		FUnionType unionTarget = getTypeForElement(FUnionType.class,
				elementName, types.getTarget().getTypes());
		if (unionTarget != null) {
			FDUnion union = FDeployFactory.eINSTANCE.createFDUnion();
			union.setTarget(unionTarget);
			types.getTypes().add(union);
			return union;
		}
		
		return null;
	}

	public static FDUnion getOrCreateUnion(FDInterface deploymentInterface,
			String elementName) {

		for (FDTypeDef u : deploymentInterface.getTypes()) {
			if (u instanceof FDUnion
					&& ((FDUnion) u).getTarget().getName() == elementName) {
				return (FDUnion) u;
			}
		}

		FUnionType unionTarget = getTypeForElement(FUnionType.class,
				elementName, deploymentInterface.getTarget().getTypes());
		if (unionTarget != null) {
			FDUnion union = FDeployFactory.eINSTANCE.createFDUnion();
			union.setTarget(unionTarget);
			deploymentInterface.getTypes().add(union);
			return union;
		}
		
		return null;
	}
}
