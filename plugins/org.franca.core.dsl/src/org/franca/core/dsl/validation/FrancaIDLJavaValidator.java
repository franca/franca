/*******************************************************************************
 * Copyright (c) 2012 Harman International (http://www.harman.com).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.core.dsl.validation;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EStructuralFeature;
import org.eclipse.xtext.validation.Check;
import org.eclipse.xtext.validation.ValidationMessageAcceptor;
import org.franca.core.FrancaModelExtensions;
import org.franca.core.framework.FrancaHelpers;
import org.franca.core.franca.FArgument;
import org.franca.core.franca.FArrayType;
import org.franca.core.franca.FAssignment;
import org.franca.core.franca.FBroadcast;
import org.franca.core.franca.FCompoundType;
import org.franca.core.franca.FContract;
import org.franca.core.franca.FEnumerationType;
import org.franca.core.franca.FField;
import org.franca.core.franca.FGuard;
import org.franca.core.franca.FInterface;
import org.franca.core.franca.FMapType;
import org.franca.core.franca.FMethod;
import org.franca.core.franca.FModel;
import org.franca.core.franca.FStructType;
import org.franca.core.franca.FTrigger;
import org.franca.core.franca.FType;
import org.franca.core.franca.FTypeCollection;
import org.franca.core.franca.FTypeDef;
import org.franca.core.franca.FTypeRef;
import org.franca.core.franca.FTypedElement;
import org.franca.core.franca.FUnionType;
import org.franca.core.franca.FrancaPackage;

public class FrancaIDLJavaValidator extends AbstractFrancaIDLJavaValidator
		implements ValidationMessageReporter, NameProvider {

	FrancaIDLJavaValidator() {
		ValidationHelpers.setNameProvider(this);
	}

	@Check
	public void checkAttributesUnique(FInterface iface) {
		ValidationHelpers.checkDuplicates(this, iface.getAttributes(),
				FrancaPackage.Literals.FMODEL_ELEMENT__NAME, "attribute name");
	}

	@Check
	public void checkMethodsUnique(FInterface iface) {
		ValidationHelpers.checkDuplicates(this, iface.getMethods(),
				FrancaPackage.Literals.FMODEL_ELEMENT__NAME, "method name");
	}

	@Check
	public void checkBroadcastsUnique(FInterface iface) {
		ValidationHelpers.checkDuplicates(this, iface.getBroadcasts(),
				FrancaPackage.Literals.FMODEL_ELEMENT__NAME, "broadcast name");
	}

	@Check
	public void checkTypeCollectionNamesUnique(FModel model) {
		ValidationHelpers.checkDuplicates(this, model.getTypeCollections(),
				FrancaPackage.Literals.FMODEL_ELEMENT__NAME,
				"type collection name");
	}

	@Check
	public void checkTypeNamesUnique(FTypeCollection collection) {
		ValidationHelpers.checkDuplicates(this, collection.getTypes(),
				FrancaPackage.Literals.FMODEL_ELEMENT__NAME, "type name");
	}

	@Check
	public void checkTypeNamesUnique(FInterface iface) {
		ValidationHelpers.checkDuplicates(this, iface.getTypes(),
				FrancaPackage.Literals.FMODEL_ELEMENT__NAME, "type name");
	}

	@Check
	public void checkCompoundElementsUnique(FCompoundType type) {
		ValidationHelpers.checkDuplicates(this, type.getElements(),
				FrancaPackage.Literals.FMODEL_ELEMENT__NAME, "element name");
	}

	@Check
	public void checkUnionElementTypesUnique(FUnionType type) {
		ValidationHelpers.NameList names = ValidationHelpers.createNameList();
		for(FField f : type.getElements()) {
			names.add(f, getName(f.getType()));
		}
		ValidationHelpers
				.checkDuplicates(this, names,
						FrancaPackage.Literals.FTYPED_ELEMENT__TYPE,
						"element type");
	}

	@Check
	public void checkEnumeratorsUnique(FEnumerationType type) {
		ValidationHelpers.checkDuplicates(this, type.getEnumerators(),
				FrancaPackage.Literals.FMODEL_ELEMENT__NAME, "enumerator name");
	}

	@Check
	public void checkMethodFlags(FMethod method) {
		if (method.getFireAndForget() != null) {
			if (!method.getOutArgs().isEmpty()) {
				error("Fire-and-forget methods cannot have out arguments",
						method,
						FrancaPackage.Literals.FMETHOD__FIRE_AND_FORGET, -1);
			}
			if (method.getErrorEnum() != null || method.getErrors() != null) {
				error("Fire-and-forget methods cannot have error return codes",
						method,
						FrancaPackage.Literals.FMETHOD__FIRE_AND_FORGET, -1);
			}
		}
	}

	@Check
	public void checkMethodArgsUnique(FMethod method) {
		ValidationHelpers.checkDuplicates(this, method.getInArgs(),
				FrancaPackage.Literals.FMODEL_ELEMENT__NAME, "argument name");
		ValidationHelpers.checkDuplicates(this, method.getOutArgs(),
				FrancaPackage.Literals.FMODEL_ELEMENT__NAME, "argument name");
	}

	@Check
	public void checkBroadcastArgsUnique(FBroadcast bc) {
		ValidationHelpers.checkDuplicates(this, bc.getOutArgs(),
				FrancaPackage.Literals.FMODEL_ELEMENT__NAME, "argument name");
	}

	@Check
	public void checkConsistentInheritance(FInterface api) {
		ValidationHelpers.checkDuplicates(this,
				FrancaHelpers.getAllAttributes(api),
				FrancaPackage.Literals.FMODEL_ELEMENT__NAME,
				"inherited attribute");

		ValidationHelpers
				.checkDuplicates(this, FrancaHelpers.getAllMethods(api),
						FrancaPackage.Literals.FMODEL_ELEMENT__NAME,
						"inherited method");

		ValidationHelpers.checkDuplicates(this,
				FrancaHelpers.getAllBroadcasts(api),
				FrancaPackage.Literals.FMODEL_ELEMENT__NAME,
				"inherited broadcast");

		ValidationHelpers.checkDuplicates(this, FrancaHelpers.getAllTypes(api),
				FrancaPackage.Literals.FMODEL_ELEMENT__NAME, "inherited type");

		if (api.getContract() != null && FrancaHelpers.hasBaseContract(api)) {
			error("Interface cannot overwrite base contract",
					api.getContract(),
					FrancaPackage.Literals.FINTERFACE__CONTRACT, -1);
		}
	}

	// *****************************************************************************

	@Check
	public void checkContract(FContract contract) {
		ContractValidator.checkContract(this, contract);
	}

	@Check
	public void checkTrigger(FTrigger trigger) {
		ContractValidator.checkTrigger(this, trigger);
	}

	@Check
	public void checkAssignment(FAssignment assignment) {
		ContractValidator.checkAssignment(this, assignment);
	}

	@Check
	public void checkGuard(FGuard guard) {
		ContractValidator.checkGuard(this, guard);
	}

	// *****************************************************************************

	// data structures consistency
	// TODO: replace this by a more general type dependency graph cycle check

	@Check
	public void checkArraySelfRef(FArrayType type) {
		if (type.getElementType().getDerived() != null) {
			if (type.getElementType().getDerived() == type) {
				error("Array references itself",
						FrancaPackage.Literals.FARRAY_TYPE__ELEMENT_TYPE);
			}
		}
	}

	@Check
	public void checkStructSelfRef(FStructType type) {
		checkCompoundSelfRef(type, "Struct");
	}

	@Check
	public void checkUnionSelfRef(FUnionType type) {
		checkCompoundSelfRef(type, "Union");
	}

	private void checkCompoundSelfRef(FCompoundType type, String label) {
		for (FTypedElement elem : type.getElements()) {
			if (elem.getType().getDerived() != null) {
				if (elem.getType().getDerived() == type) {
					error(label + " references itself", elem,
							FrancaPackage.Literals.FTYPED_ELEMENT__TYPE, -1);
				}
			}
		}
	}

	@Check
	public void checkTypeDefSelfRef(FTypeDef type) {
		if (type.getActualType().getDerived() != null) {
			if (type == type.getActualType().getDerived()) {
				error("Cyclic reference for typedef '" + type.getName() + "'", type,
						FrancaPackage.Literals.FTYPE_DEF__ACTUAL_TYPE, -1);
			}
		}
	}

	@Check
	public void checkMapSelfRef(FMapType type) {
		FType keyType = type.getKeyType().getDerived();
		FType valueType = type.getValueType().getDerived();

		if (keyType != null) {
			if (type == keyType) {
				error("Map references itself", type,
						FrancaPackage.Literals.FMAP_TYPE__KEY_TYPE, -1);
			}
		}
		if (valueType != null) {
			if (type == valueType) {
				error("Map references itself", type,
						FrancaPackage.Literals.FMAP_TYPE__VALUE_TYPE, -1);
			}
		}
	}

	@Check
	public void checkStructSelfExtend(FStructType type) {
		if (type.getBase() != null) {
			if (type == type.getBase()) {
				error("Cyclic inheritance for struct", type,
						FrancaPackage.Literals.FSTRUCT_TYPE__BASE, -1);
			}
		}
	}

	@Check
	public void checkUnionSelfExtend(FUnionType type) {
		if (type.getBase() != null) {
			if (type == type.getBase()) {
				error("Cyclic inheritance for union", type,
						FrancaPackage.Literals.FUNION_TYPE__BASE, -1);
			}
		}
	}

	@Check
	public void checkEnumSelfExtend(FEnumerationType type) {
		if (type.getBase() != null) {
			if (type == type.getBase()) {
				error("Cyclic inheritance for FEnumerationType", type,
						FrancaPackage.Literals.FENUMERATION_TYPE__BASE, -1);
			}
		}
	}

	// *****************************************************************************

	// visibility of derived types

	@Check
	public void checkTypeVisible(FTypeRef typeref) {
		if (typeref.getDerived() != null) {
			// this is a derived type, check if referenced type can be accessed
			FType referencedType = typeref.getDerived();
			FInterface refParent = FrancaModelExtensions
					.getInterface(referencedType);
			if (refParent == null) {
				// referenced type is defined on model level, can be accessed
				// anyway
			} else {
				// referenced type is defined as part of an FInterface,
				// check if reference is allowed by local access (same
				// FInterface)
				FInterface parent = FrancaModelExtensions.getInterface(typeref);
				if (refParent != parent) {
					error("Type " + referencedType.getName()
							+ " can only be referenced inside interface "
							+ refParent.getName(), typeref,
							FrancaPackage.Literals.FTYPE_REF__DERIVED, -1);
				}
			}
		}
	}

	// *****************************************************************************

	/**
	 * Helper function that computes the name of a method, broadcast including
	 * its signature. Used to identify uniquely the element in a restricted
	 * scope.
	 * 
	 * @param e
	 *            the object to get the name
	 * @return the name
	 */
	public String getName(EObject e) {
		String name = new String();

		if (e instanceof FMethod) {
			FMethod method = (FMethod) e;

			name += method.getName();
			for (FArgument arg : method.getInArgs()) {
				name += getTypeName(arg);
			}
			for (FArgument arg : method.getOutArgs()) {
				name += getTypeName(arg);
			}
		} else if (e instanceof FBroadcast) {
			FBroadcast broadcast = (FBroadcast) e;

			name += broadcast.getName();
			for (FArgument arg : broadcast.getOutArgs()) {
				name += getTypeName(arg);
			}
		} else if (e instanceof FTypeRef) {
			name = getName((FTypeRef)e);
		} else {
			name = e.eGet(FrancaPackage.Literals.FMODEL_ELEMENT__NAME)
					.toString();
		}
		return name;
	}

	private static String getTypeName(FArgument arg) {
		StringBuilder typeName = new StringBuilder();

		typeName.append(getName(arg.getType()));
		if (arg.getArray() != null) {
			typeName.append(arg.getArray());
		}
		return typeName.toString();
	}

	private static String getName(FTypeRef type) {
		if (type.getDerived()==null) {
			return type.getPredefined().getLiteral();
		} else {
			return type.getDerived().getName();
		}
	}

	// *****************************************************************************

	// ValidationMessageReporter interface
	public void reportError(String message, EObject object,
			EStructuralFeature feature) {
		error(message, object, feature,
				ValidationMessageAcceptor.INSIGNIFICANT_INDEX);
	}

	public void reportWarning(String message, EObject object,
			EStructuralFeature feature) {
		warning(message, object, feature,
				ValidationMessageAcceptor.INSIGNIFICANT_INDEX);
	}

}
