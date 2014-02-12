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
import java.util.List;

import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;
import org.eclipse.jdt.annotation.NonNull;
import org.franca.core.franca.FArrayType;
import org.franca.core.franca.FAttribute;
import org.franca.core.franca.FBasicTypeId;
import org.franca.core.franca.FBroadcast;
import org.franca.core.franca.FConstantDef;
import org.franca.core.franca.FContract;
import org.franca.core.franca.FEnumerationType;
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
		if (api.getBase()!=null) {
			elements.addAll(getAllAttributes(api.getBase()));
		}
		elements.addAll(api.getAttributes());
		return elements;
	}
	
	/** Get all methods of an interface including the inherited ones */
	public static List<FMethod> getAllMethods (FInterface api) {
		List<FMethod> elements = Lists.newArrayList();
		if (api.getBase()!=null) {
			elements.addAll(getAllMethods(api.getBase()));
		}
		elements.addAll(api.getMethods());
		return elements;
	}
	
	/** Get all broadcasts of an interface including the inherited ones */
	public static List<FBroadcast> getAllBroadcasts (FInterface api) {
		List<FBroadcast> elements = Lists.newArrayList();
		if (api.getBase()!=null) {
			elements.addAll(getAllBroadcasts(api.getBase()));
		}
		elements.addAll(api.getBroadcasts());
		return elements;
	}
	
	/** Get all types of an interface including the inherited ones */
	public static List<FType> getAllTypes (FInterface api) {
		List<FType> elements = Lists.newArrayList();
		if (api.getBase()!=null) {
			elements.addAll(getAllTypes(api.getBase()));
		}
		elements.addAll(api.getTypes());
		return elements;
	}
	
	/** Get all constants of an interface including the inherited ones */
	public static List<FConstantDef> getAllConstants (FInterface api) {
		List<FConstantDef> elements = Lists.newArrayList();
		if (api.getBase()!=null) {
			elements.addAll(getAllConstants(api.getBase()));
		}
		elements.addAll(api.getConstants());
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
		if (typeRef.getDerived() == null) {
			return typeRef.getPredefined();
		} else {
			FType type = typeRef.getDerived();
			if (type instanceof FTypeDef) {
				FTypeDef typedef = (FTypeDef)type;
				return getActualPredefined(typedef.getActualType());
			} else {
				return null;
			}
		}
	}

	/**
	 * Returns actual derived type for a FTypeRef.
	 * 
	 * This function hides typedefs properly.
	 */
	public static FType getActualDerived (FTypeRef typeRef) {
		if (typeRef.getDerived() == null) {
			return null;
		} else {
			FType type = typeRef.getDerived();
			if (type instanceof FTypeDef) {
				FTypeDef typedef = (FTypeDef)type;
				return getActualDerived(typedef.getActualType());
			} else {
				return type;
			}
		}
	}

	/** Returns true if the referenced type is any kind of integer. */
	public static boolean isInteger (FTypeRef typeRef) {
		if (typeRef == null) return false;
		FBasicTypeId bt = getActualPredefined(typeRef);
		if (bt != null) {
			int id = bt.getValue();
			if (id==FBasicTypeId.INT8_VALUE  || id==FBasicTypeId.UINT8_VALUE  ||
				id==FBasicTypeId.INT16_VALUE || id==FBasicTypeId.UINT16_VALUE ||
				id==FBasicTypeId.INT32_VALUE || id==FBasicTypeId.UINT32_VALUE ||
				id==FBasicTypeId.INT64_VALUE || id==FBasicTypeId.UINT64_VALUE   )
			{
				return true;
			}
		}
		return false;
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
	public static String getTypeString (@NonNull FTypeRef typeRef) {
		FType derived = getActualDerived(typeRef);
		if (derived == null) {
			return getActualPredefined(typeRef).getName();
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
