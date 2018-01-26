/*******************************************************************************
* Copyright (c) 2012 Harman International (http://www.harman.com).
* All rights reserved. This program and the accompanying materials
* are made available under the terms of the Eclipse Public License v1.0
* which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/epl-v10.html
*******************************************************************************/
package org.franca.core.framework;

import java.io.File;
import java.io.IOException;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;
import org.franca.core.FrancaModelExtensions;
import org.franca.core.franca.FArrayType;
import org.franca.core.franca.FAttribute;
import org.franca.core.franca.FBasicTypeId;
import org.franca.core.franca.FBroadcast;
import org.franca.core.franca.FConstantDef;
import org.franca.core.franca.FContract;
import org.franca.core.franca.FEnumerationType;
import org.franca.core.franca.FIntegerInterval;
import org.franca.core.franca.FInterface;
import org.franca.core.franca.FMapType;
import org.franca.core.franca.FMethod;
import org.franca.core.franca.FModel;
import org.franca.core.franca.FStateGraph;
import org.franca.core.franca.FStructType;
import org.franca.core.franca.FType;
import org.franca.core.franca.FTypeDef;
import org.franca.core.franca.FTypeRef;
import org.franca.core.franca.FUnionType;
import org.franca.core.franca.FrancaPackage;

import com.google.common.collect.Lists;


public class FrancaHelpers {
	// configuration data
	private ResourceSet resourceSet = null;

	// *****************************************************************************
	// constructor(s)

	private FrancaHelpers() {
		// register the appropriate resource factory to handle all file extensions for Franca
		@SuppressWarnings("unused")
		FrancaPackage fpackage = FrancaPackage.eINSTANCE;
		
		// now create resourceSet
		resourceSet = new ResourceSetImpl();
	}

	
	// *****************************************************************************
	// model save/load

	public boolean saveModel (FModel model, String fileName) {
		return saveFrancaModel(resourceSet, model, fileName + ".franca");
	}
	
	private static boolean saveFrancaModel (ResourceSet resourceSet, FModel model, String filename) {
		URI fileUri = URI.createFileURI(new File(filename).getAbsolutePath());
		Resource res = resourceSet.createResource(fileUri);
		if (res==null) {
	        System.err.println("Franca: model file cannot be saved (resource==null, filename is " + filename + ")");
			return false;
		}
		
		res.getContents().add(model);
		try {
			res.save(Collections.EMPTY_MAP);
	        System.out.println("Created franca model file " + filename);
		} catch (IOException e) {
			e.printStackTrace();
			return false;
		}

		return true;
	}

	
	// *****************************************************************************
	// helpers for model navigation
	
	/** @deprecated Use org.franca.core.FrancaModelExtensions instead. */
	public static FInterface getEnclosingInterface (EObject obj) {
		EObject x = obj;
		do {
			x = x.eContainer();
			if (x instanceof FInterface)
				return (FInterface)x;
		} while (x!=null);
		return null;
	}
	
	/** @deprecated Use org.franca.core.FrancaModelExtensions instead. */
	public static FStateGraph getStateGraph (EObject obj) {
		EObject x = obj;
		do {
			x = x.eContainer();
			if (x instanceof FStateGraph)
				return (FStateGraph)x;
		} while (x!=null);
		return null;
	}
	
	/** @deprecated Use org.franca.core.FrancaModelExtensions instead. */
	public static FContract getContract (EObject obj) {
		EObject x = obj;
		do {
			x = x.eContainer();
			if (x instanceof FContract)
				return (FContract)x;
		} while (x!=null);
		return null;
	}
	
	/** Get all attributes of an interface including the inherited ones */
	public static List<FAttribute> getAllAttributes (FInterface api) {
		List<FAttribute> elements = Lists.newArrayList();
		for(FInterface i : FrancaModelExtensions.getInterfaceInheritationSet(api))
			elements.addAll(i.getAttributes());
		return elements;
	}
	
	/** Get all methods of an interface including the inherited ones */
	public static List<FMethod> getAllMethods (FInterface api) {
		List<FMethod> elements = Lists.newArrayList();
		for(FInterface i : FrancaModelExtensions.getInterfaceInheritationSet(api))
			elements.addAll(i.getMethods());
		return elements;
	}
	
	/** Get all broadcasts of an interface including the inherited ones */
	public static List<FBroadcast> getAllBroadcasts (FInterface api) {
		List<FBroadcast> elements = Lists.newArrayList();
		for(FInterface i : FrancaModelExtensions.getInterfaceInheritationSet(api))
			elements.addAll(i.getBroadcasts());
		return elements;
	}
	
	/** Get all types of an interface including the inherited ones */
	public static List<FType> getAllTypes (FInterface api) {
		List<FType> elements = Lists.newArrayList();
		for(FInterface i : FrancaModelExtensions.getInterfaceInheritationSet(api))
			elements.addAll(i.getTypes());
		return elements;
	}
	
	/** Get all constants of an interface including the inherited ones */
	public static List<FConstantDef> getAllConstants (FInterface api) {
		List<FConstantDef> elements = Lists.newArrayList();
		for(FInterface i : FrancaModelExtensions.getInterfaceInheritationSet(api))
			elements.addAll(i.getConstants());
		return elements;
	}
	
	/** Returns true if any of the base interfaces has a contract definition */
	public static boolean hasBaseContract (FInterface api) {
		if (api.getBase()!=null) {
			return api.getBase().getContract()!=null || hasBaseContract(api.getBase());
		}
		return false;
	}
	

	// *****************************************************************************
	// basic type system
	
	/**
	 * Returns actual predefined type for a FTypeRef.
	 * 
	 * This function hides typedefs properly.
	 */
	public static FBasicTypeId getActualPredefined (FTypeRef typeRef) {
		Set<FTypeRef> visited = new HashSet<FTypeRef>();
		FTypeRef tr = typeRef;
		while (tr.getDerived() != null) {
			if (visited.contains(tr)) {
				// found a cycle, abort
				return null;
			}
			visited.add(tr);
			
			FType type = tr.getDerived();
			if (type instanceof FTypeDef) {
				// progress in chain according to typedef
				FTypeDef typedef = (FTypeDef)type;
				tr = typedef.getActualType();
			} else {
				// this is an actualDerived type
				return null;
			}
		}
		
		return tr.getPredefined();
	}

	/**
	 * Returns actual derived type for a FTypeRef.
	 * 
	 * This function hides typedefs properly.
	 */
	public static FType getActualDerived (FTypeRef typeRef) {
		Set<FTypeRef> visited = new HashSet<FTypeRef>();
		FTypeRef tr = typeRef;
		while (tr.getDerived() != null) {
			FType type = tr.getDerived();
			if (type instanceof FTypeDef) {
				FTypeDef typedef = (FTypeDef)type;
				tr = typedef.getActualType();
			} else {
				// we found the actualDerived
				return type;
			}

			if (visited.contains(tr)) {
				// found a cycle, abort
				return null;
			}
		}

		// this is an actualPredefined type
		return null;
	}
	
	/**
	 * Returns actual interval type for a FTypeRef.
	 * 
	 * This function hides typedefs properly.
	 */
	public static FIntegerInterval getActualInterval (FTypeRef typeRef) {
		if (typeRef.getDerived() == null) {
			return typeRef.getInterval();
		} else {
			FType type = typeRef.getDerived();
			if (type instanceof FTypeDef) {
				FTypeDef typedef = (FTypeDef)type;
				return getActualInterval(typedef.getActualType());
			} else {
				return null;
			}
		}
	}

	/** Returns true if the referenced type is any kind of integer. */
	public static boolean isInteger(FTypeRef typeRef) {
		if (typeRef == null)
			return false;
		FBasicTypeId bt = getActualPredefined(typeRef);
		return isBasicIntegerId(bt) || getActualInterval(typeRef) != null;
	}

	/** Returns true if the referenced type is any kind of integer. */
	public static boolean isBasicInteger(FTypeRef typeRef) {
		if (typeRef == null)
			return false;
		FBasicTypeId bt = getActualPredefined(typeRef);
		return isBasicIntegerId(bt);
	}

	private static boolean isBasicIntegerId(FBasicTypeId id) {
		return id != null
				&& (id == FBasicTypeId.INT8
						|| id == FBasicTypeId.UINT8
						|| id == FBasicTypeId.INT16
						|| id == FBasicTypeId.UINT16
						|| id == FBasicTypeId.INT32
						|| id == FBasicTypeId.UINT32
						|| id == FBasicTypeId.INT64
						|| id == FBasicTypeId.UINT64);
	}

	/** Returns true if the referenced type is a float number. */
	public static boolean isFloat (FTypeRef typeRef) {
		return isBasicType(typeRef, FBasicTypeId.FLOAT);
	}
	
	/** Returns true if the referenced type is a double number. */
	public static boolean isDouble (FTypeRef typeRef) {
		return isBasicType(typeRef, FBasicTypeId.DOUBLE);
	}
	
	/** Returns true if the referenced type is float or double. */
	public static boolean isFloatingPoint (FTypeRef typeRef) {
		return isFloat(typeRef) || isDouble(typeRef);
	}

	/** Returns true if the referenced type is any number. */
	public static boolean isNumber (FTypeRef typeRef) {
		return isInteger(typeRef) || isFloatingPoint(typeRef);
	}
	
	/** Returns true if the referenced type is a string. */
	public static boolean isString (FTypeRef typeRef) {
		return isBasicType(typeRef, FBasicTypeId.STRING);
	}

	/** Returns true if the referenced type is a boolean value. */
	public static boolean isBoolean (FTypeRef typeRef) {
		return isBasicType(typeRef, FBasicTypeId.BOOLEAN);
	}

	/** Returns true if the referenced type is a byte buffer. */
	public static boolean isByteBuffer (FTypeRef typeRef) {
		return isBasicType(typeRef, FBasicTypeId.BYTE_BUFFER);
	}

	/** Returns true if the referenced type is an array type. */
	public static boolean isArray (FTypeRef typeRef) {
		return isUserDefinedType(typeRef, FArrayType.class);
	}
	
	/** Returns true if the referenced type is an enumeration type. */
	public static boolean isEnumeration (FTypeRef typeRef) {
		return isUserDefinedType(typeRef, FEnumerationType.class);
	}
	
	/** Returns true if the referenced type is an struct type. */
	public static boolean isStruct (FTypeRef typeRef) {
		return isUserDefinedType(typeRef, FStructType.class);
	}
	
	/** Returns true if the referenced type is an union type. */
	public static boolean isUnion (FTypeRef typeRef) {
		return isUserDefinedType(typeRef, FUnionType.class);
	}
	
	/** Returns true if the referenced type is an compound type. */
	public static boolean isCompound (FTypeRef typeRef) {
		return isStruct(typeRef) || isUnion(typeRef);
	}

	/** Returns true if the referenced type is a map type. */
	public static boolean isMap (FTypeRef typeRef) {
		return isUserDefinedType(typeRef, FMapType.class);
	}
	

	/**
	 * Returns true if the referenced type is a given user-defined type.
	 * 
	 * This function handles typedefs correctly.
	 */ 
	private static <E extends FType> boolean isBasicType (FTypeRef typeRef, FBasicTypeId expected) {
		if (typeRef == null) return false;
		FBasicTypeId id = getActualPredefined(typeRef);
		if (id != null) {
			if (id.getValue() == expected.getValue()) {
				return true;
			}
		}
		return false;
	}
	
	/**
	 * Returns true if the referenced type is a given user-defined type.
	 * 
	 * This function handles typedefs correctly.
	 */ 
	private static <E extends FType> boolean isUserDefinedType (FTypeRef typeRef, Class<E> clazz) {
		if (typeRef == null) return false;
		FType type = getActualDerived(typeRef);
		if (type != null) {
			if (clazz.isInstance(type)) {
				return true;
			}
		}
		return false;
	}
	
	/** Get a human-readable name for a Franca type. */
	public static String getTypeString (/*@NonNull*/ FTypeRef typeRef) {
		FType derived = getActualDerived(typeRef);
		if (derived == null) {
			FIntegerInterval interval = getActualInterval(typeRef);
			if (interval == null) {
				return getActualPredefined(typeRef).getName();
			} else {
				return "Integer()";
			}
		} else {
			FType type = getActualDerived(typeRef);
			if (type instanceof FEnumerationType) {
				return "enumeration '" + type.getName() + "'";
			} else if (type instanceof FStructType) {
				return "struct '" + type.getName() + "'";
			} else if (type instanceof FUnionType) {
				return "union '" + type.getName() + "'";
			} else if (type instanceof FMapType) {
				return "map '" + type.getName() + "'";
			} else {
				return "'" + type.getName() + "'";
			}
		}
	}


	// *****************************************************************************
	// singleton
	
	private static FrancaHelpers instance = null;
	
	public static FrancaHelpers instance() {
		if (instance==null) {
			instance = new FrancaHelpers();
		}
		return instance;
	}
}
