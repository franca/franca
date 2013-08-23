/*******************************************************************************
 * Copyright (c) 2012 Harman International (http://www.harman.com).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.core.dsl.validation;

import java.util.HashMap;
import java.util.Map;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EStructuralFeature;
import org.eclipse.xtext.naming.IQualifiedNameProvider;
import org.eclipse.xtext.naming.QualifiedName;
import org.eclipse.xtext.validation.Check;
import org.eclipse.xtext.validation.ValidationMessageAcceptor;
import org.franca.core.FrancaModelExtensions;
import org.franca.core.ImportedModelInfo;
import org.franca.core.dsl.validation.internal.ContractValidator;
import org.franca.core.dsl.validation.internal.CyclicDependenciesValidator;
import org.franca.core.dsl.validation.internal.NameProvider;
import org.franca.core.dsl.validation.internal.ValidationHelpers;
import org.franca.core.dsl.validation.internal.ValidationMessageReporter;
import org.franca.core.dsl.validation.internal.ValidatorRegistry;
import org.franca.core.framework.FrancaHelpers;
import org.franca.core.franca.FArgument;
import org.franca.core.franca.FAssignment;
import org.franca.core.franca.FBroadcast;
import org.franca.core.franca.FCompoundType;
import org.franca.core.franca.FContract;
import org.franca.core.franca.FEnumerationType;
import org.franca.core.franca.FField;
import org.franca.core.franca.FGuard;
import org.franca.core.franca.FInterface;
import org.franca.core.franca.FMethod;
import org.franca.core.franca.FModel;
import org.franca.core.franca.FTrigger;
import org.franca.core.franca.FType;
import org.franca.core.franca.FTypeCollection;
import org.franca.core.franca.FTypeRef;
import org.franca.core.franca.FUnionType;
import org.franca.core.franca.FrancaPackage;

import com.google.inject.Inject;

public class FrancaIDLJavaValidator extends AbstractFrancaIDLJavaValidator
		implements ValidationMessageReporter, NameProvider {
	
	@Inject
	protected CyclicDependenciesValidator cyclicDependenciesValidator; 
	
	@Inject IQualifiedNameProvider qnProvider;

	FrancaIDLJavaValidator() {
		ValidationHelpers.setNameProvider(this);
	}
	
	@Check
	public void checkAnonymousTypeCollections(FModel model) {
		int count = 0;
		FTypeCollection anon = null;
		for (FTypeCollection coll : model.getTypeCollections()) {
			if (isAnonymous(coll)) {
				anon = coll;
				count++;
			}
		}
		
		if (count > 1) {
			error(
					"There can be only one anonymous type collection in a *.fidl file!", 
					model, 
					FrancaPackage.Literals.FMODEL__NAME
				);
		}
		
		if (anon!=null) {
			// check against imported type collections
			ImportedModelInfo imported = FrancaModelExtensions.getAllImportedModels(model);
			for(FModel m : imported.getImportedModels()) {
				if (m.getName().equals(model.getName())) {
					for(FTypeCollection tc : m.getTypeCollections()) {
						if (isAnonymous(tc)) {
							error("Another anonymous type collection in same package is imported via " +
										imported.getViaString(m.eResource()),
									model,
									FrancaPackage.Literals.FMODEL__NAME);
							return;
						}
					}
				}
			}
		}
	}
	
	private boolean isAnonymous (FTypeCollection tc) {
		return tc.getName()==null || tc.getName().isEmpty();
	}
	
	@Check
	public void checkExtensionValidators(FModel model) {
		for (IFrancaExternalValidator validator : ValidatorRegistry.getValidatorMap().get(getCheckMode())) {
			validator.validateModel(model, getMessageAcceptor());
		}
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
		if (model.getTypeCollections().isEmpty())
			return;

		// check local type collections
		final Iterable<FTypeCollection> tcs = FrancaModelExtensions.getNamedTypedCollections(model);
		ValidationHelpers.checkDuplicates(this, tcs,
				FrancaPackage.Literals.FMODEL_ELEMENT__NAME,
				"type collection name");

		// check against imported type collections
		ImportedModelInfo imported = FrancaModelExtensions.getAllImportedModels(model);
		for(FModel m : imported.getImportedModels()) {
			for(FTypeCollection tc : m.getTypeCollections()) {
				if (! isAnonymous(tc)) {
					QualifiedName qn = qnProvider.getFullyQualifiedName(tc);
					for(FTypeCollection tc0 : tcs) {
						QualifiedName qn0 = qnProvider.getFullyQualifiedName(tc0);
						if (qn.equals(qn0)) {
							error("Type collection name collides with imported type collection " +
									"(imported via " + imported.getViaString(m.eResource()) + ")",
									tc0,
									FrancaPackage.Literals.FMODEL_ELEMENT__NAME);
						}
					}
				}
			}
		}
	}

	@Check
	public void checkInterfaceNamesUnique(FModel model) {
		if (model.getInterfaces().isEmpty())
			return;

		// check local interfaces
		ValidationHelpers.checkDuplicates(this, model.getInterfaces(),
				FrancaPackage.Literals.FMODEL_ELEMENT__NAME,
				"interface name");

		// check against imported interfaces
		ImportedModelInfo imported = FrancaModelExtensions.getAllImportedModels(model);
		for(FModel m : imported.getImportedModels()) {
			for(FInterface i : m.getInterfaces()) {
				QualifiedName qn = qnProvider.getFullyQualifiedName(i);
				for(FInterface i0 : model.getInterfaces()) {
					QualifiedName qn0 = qnProvider.getFullyQualifiedName(i0);
					if (qn.equals(qn0)) {
						error("Interface name collides with imported interface " +
								"(imported via " + imported.getViaString(m.eResource()) + ")",
								i0,
								FrancaPackage.Literals.FMODEL_ELEMENT__NAME);
					}
				}
			}
		}
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
		if (method.isFireAndForget()) {
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
		
		// check if in- and out-arguments are pairwise different
		Map<String, FArgument> inArgs = new HashMap<String, FArgument>();
		for(FArgument a : method.getInArgs()) {
			inArgs.put(a.getName(), a);
		}
		for(FArgument a : method.getOutArgs()) {
			String key = a.getName();
			if (inArgs.containsKey(key)) {
				String msg = "Duplicate argument name '" + key + "' used for in and out"; 
				error(msg, inArgs.get(key), FrancaPackage.Literals.FMODEL_ELEMENT__NAME, -1);
				error(msg, a, FrancaPackage.Literals.FMODEL_ELEMENT__NAME, -1);
			}
		}
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
	
	
	@Check
	public void checkCyclicDependencies(FModel m) {
		cyclicDependenciesValidator.check(this, m);
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
			Object modelElementName = e.eGet(FrancaPackage.Literals.FMODEL_ELEMENT__NAME);
			//while editing the model the modelElementName might not be set
			if (modelElementName != null) {
				name = e.eGet(FrancaPackage.Literals.FMODEL_ELEMENT__NAME)
						.toString();
			}
		}
		return name;
	}

	private static String getTypeName(FArgument arg) {
		StringBuilder typeName = new StringBuilder();

		typeName.append(getName(arg.getType()));
		if (arg.isArray()) {
			typeName.append("[]");
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
