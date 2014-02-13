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
import java.math.BigInteger;
import java.util.Collections;
import java.util.List;

import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;
import org.eclipse.emf.mwe2.language.scoping.QualifiedNameProvider;
import org.eclipse.jdt.annotation.NonNull;
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
import com.google.inject.Inject;


public class FrancaHelpers {
	// configuration data
	private ResourceSet resourceSet = null;
	
	@Inject
	private QualifiedNameProvider fqnProvider;

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
	
	/** Returns true if the referenced type is any kind of integer. */
	public static boolean isInteger (FTypeRef typeRef) {
		if (typeRef == null) return false;
		
		if (typeRef.getDerived() == null) {
			FBasicTypeId id = typeRef.getPredefined();
			if (	id==FBasicTypeId.INT8  || id==FBasicTypeId.UINT8  ||
					id==FBasicTypeId.INT16 || id==FBasicTypeId.UINT16 ||
					id==FBasicTypeId.INT32 || id==FBasicTypeId.UINT32 ||
					id==FBasicTypeId.INT64 || id==FBasicTypeId.UINT64 ||
					typeRef.getInterval() != null
			) {
				return true;
			}
		} else {
			FType type = typeRef.getDerived();
			if (type instanceof FTypeDef) {
				FTypeDef typedef = (FTypeDef)type;
				return isInteger(typedef.getActualType());
			}
		}
		return false;
	}

	/** Returns true if the referenced type is float or double. */
	public static boolean isFloatingPoint (FTypeRef typeRef) {
		return basicTypeEquals(typeRef, FBasicTypeId.FLOAT) || basicTypeEquals(typeRef, FBasicTypeId.DOUBLE);
	}
	
	public static boolean typeEquals(FTypeRef typeRef1, FTypeRef typeRef2) {
		FBasicTypeId predef = typeRef2.getPredefined();
		if (predef != null) {
			return basicTypeEquals(typeRef1, predef);
		}
		
		FIntegerInterval interval1 = typeRef1.getInterval();
		FIntegerInterval interval2 = typeRef2.getInterval();
		if (interval1 != null || interval2 != null) {
			if (interval1 != null && interval2 != null) {
				return (interval1.getLowerBound() == null || interval1.getLowerBound().equals(interval2.getLowerBound())) &&
						(interval1.getUpperBound() == null || interval1.getUpperBound().equals(interval2.getUpperBound()));
			}
			return false;
		}
		
		//TODO: fqnProvider statically not available!!!
//		FType derived1 = typeRef1.getDerived();
//		FType derived2 = typeRef2.getDerived();
//		QualifiedName fqn1 = fqnProvider.getFullyQualifiedName(derived1);
//		if (fqn1 != null) { //otherwise we would be somewhere in the middle of parsing
//			return fqn1.equals(fqnProvider.getFullyQualifiedName(derived2));
//		}
		
		return false;
	}
	
	public static boolean basicTypeEquals(FTypeRef typeRef, FBasicTypeId basicTypeID) {
		if (typeRef == null) return false;
		
		if (typeRef.getDerived() == null) {
			FBasicTypeId id = typeRef.getPredefined();
			if (id==basicTypeID) {
				return true;
			}
		} else {
			FType type = typeRef.getDerived();
			if (type instanceof FTypeDef) {
				FTypeDef typedef = (FTypeDef)type;
				return basicTypeEquals(typedef.getActualType(), basicTypeID);
			}
		}
		return false;
	}
	
	/** Returns true if the referenced type is any number. */
	public static boolean isNumber (FTypeRef typeRef) {
		return isInteger(typeRef) || isFloatingPoint(typeRef);
	}
	
	/** Returns true if the referenced type is a double. */
	public static boolean isDouble(FTypeRef typeRef) {
		return basicTypeEquals(typeRef, FBasicTypeId.DOUBLE);
	}
	/** Returns true if the referenced type is a float. */
	public static boolean isFloat(FTypeRef typeRef) {
		return basicTypeEquals(typeRef, FBasicTypeId.FLOAT);
	}
	/** Returns true if the referenced type is a string. */
	public static boolean isString (FTypeRef typeRef) {
		return basicTypeEquals(typeRef, FBasicTypeId.STRING);
	}

	/** Returns true if the referenced type is a boolean. */
	public static boolean isBoolean (FTypeRef typeRef) {
		return basicTypeEquals(typeRef, FBasicTypeId.BOOLEAN);
	}

	/** Returns true if the referenced type is an enumeration type. */
	public static boolean isEnumeration (FTypeRef typeRef) {
		if (typeRef == null) return false;
		
		if (typeRef.getDerived() != null) {
			FType type = typeRef.getDerived();
			if (type instanceof FEnumerationType) {
				return true;
			} else if (type instanceof FTypeDef) {
				FTypeDef typedef = (FTypeDef)type;
				return isEnumeration(typedef.getActualType());
			}
		}
		return false;
	}
	
	/** Get a human-readable name for a Franca type. */
	public static String getTypeString (@NonNull FTypeRef typeRef) {
		if (typeRef.getDerived() == null) {
			return typeRef.getPredefined().getName();
		} else {
			FType type = typeRef.getDerived();
			if (type instanceof FTypeDef) {
				FTypeDef typedef = (FTypeDef)type;
				return getTypeString(typedef.getActualType());
			} else if (type instanceof FIntegerInterval) {
				FIntegerInterval interval = (FIntegerInterval) type;
				BigInteger lowerBound = interval.getLowerBound();
				BigInteger upperBound = interval.getLowerBound();
				return "integer interval (" + lowerBound == null ? "minInt" : lowerBound.toString() + "," + upperBound == null ? "maxInt" : upperBound.toString() + ")";
			} else if (type instanceof FEnumerationType) {
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
