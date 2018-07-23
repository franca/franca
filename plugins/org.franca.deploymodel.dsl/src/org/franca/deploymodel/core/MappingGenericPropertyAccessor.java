/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.deploymodel.core;

import java.util.List;

import org.eclipse.emf.ecore.EObject;
import org.franca.core.franca.FArgument;
import org.franca.core.franca.FArrayType;
import org.franca.core.franca.FAttribute;
import org.franca.core.franca.FBroadcast;
import org.franca.core.franca.FEnumerationType;
import org.franca.core.franca.FEnumerator;
import org.franca.core.franca.FField;
import org.franca.core.franca.FInterface;
import org.franca.core.franca.FMapType;
import org.franca.core.franca.FMethod;
import org.franca.core.franca.FStructType;
import org.franca.core.franca.FTypeDef;
import org.franca.core.franca.FUnionType;
import org.franca.deploymodel.dsl.FDMapper;
import org.franca.deploymodel.dsl.fDeploy.FDArgument;
import org.franca.deploymodel.dsl.fDeploy.FDArray;
import org.franca.deploymodel.dsl.fDeploy.FDAttribute;
import org.franca.deploymodel.dsl.fDeploy.FDBroadcast;
import org.franca.deploymodel.dsl.fDeploy.FDCompound;
import org.franca.deploymodel.dsl.fDeploy.FDElement;
import org.franca.deploymodel.dsl.fDeploy.FDEnumValue;
import org.franca.deploymodel.dsl.fDeploy.FDEnumeration;
import org.franca.deploymodel.dsl.fDeploy.FDField;
import org.franca.deploymodel.dsl.fDeploy.FDMap;
import org.franca.deploymodel.dsl.fDeploy.FDMethod;
import org.franca.deploymodel.dsl.fDeploy.FDSpecification;
import org.franca.deploymodel.dsl.fDeploy.FDStruct;
import org.franca.deploymodel.dsl.fDeploy.FDTypedef;
import org.franca.deploymodel.dsl.fDeploy.FDUnion;
import org.franca.deploymodel.dsl.fDeploy.FDeployFactory;

/** 
 * A {@link GenericPropertyAccessor} that does not access the given EObjects 
 * (i.e. the EObjects passed as first argument to the get.. Methods) directly, 
 * but the {@link FDElement}s these EObjects are mapped to by means of an {@link FDMapper}. <br/>
 * If the FDMapper does not provide an actual mapping for a given EObject, this PropertyAccessor will
 * create a Dummy-FDElement in order to access the default-value of it.

 * @author holzer
 */
public class MappingGenericPropertyAccessor extends GenericPropertyAccessor {

	/** The FDMapper providing the FDSpec for the given EObjects. */
	protected FDMapper mapper;
	
	public MappingGenericPropertyAccessor(FDSpecification spec,FDMapper mapper) {
		super(spec);
		this.mapper = mapper;
	}
	
	public Boolean getBoolean(EObject obj, String property) {
		return super.getBoolean(getFDElement(obj), property);
	}

	public List<Boolean> getBooleanArray(EObject obj, String property) {
		return super.getBooleanArray(getFDElement(obj), property);
	}

	public Integer getInteger(EObject obj, String property) {
		return super.getInteger(getFDElement(obj), property);
	}

	public List<Integer> getIntegerArray(EObject obj, String property) {
		return super.getIntegerArray(getFDElement(obj), property);
	}

	public String getString(EObject obj, String property) {
		return super.getString(getFDElement(obj), property);
	}

	public List<String> getStringArray(EObject obj, String property) {
		return super.getStringArray(getFDElement(obj), property);
	}

	public FInterface getInterface(EObject obj, String property) {
		return super.getInterface(getFDElement(obj), property);
	}

	public List<FInterface> getInterfaceArray(EObject obj, String property) {
		return super.getInterfaceArray(getFDElement(obj), property);
	}

	public <RuntimeType extends EObject> RuntimeType getGenericReference(
		EObject obj,
		Class<? extends EObject> runtimeType,
		String property
	) {
		return super.getGenericReference(getFDElement(obj), runtimeType, property);
	}

	public <RuntimeType extends EObject> List<RuntimeType> getGenericReferenceArray(
		EObject obj,
		Class<? extends EObject> runtimeType,
		String property
	) {
		return super.getGenericReference(getFDElement(obj), runtimeType, property);
	}

	public String getEnum(EObject obj, String property) {
		return super.getEnum(getFDElement(obj), property);
	}

	public List<String> getEnumArray(EObject obj, String property) {
		return super.getEnumArray(getFDElement(obj), property);
	}

	public FDElement createDummyFDEelement(EObject obj) {
		FDElement el = null;
		if (obj instanceof FAttribute) {
			el = FDeployFactory.eINSTANCE.createFDAttribute();
			((FDAttribute) el).setTarget((FAttribute) obj);
		} else if (obj instanceof FMethod) {
			el = FDeployFactory.eINSTANCE.createFDMethod();
			((FDMethod) el).setTarget((FMethod) obj);
		} else if (obj instanceof FBroadcast) {
			el = FDeployFactory.eINSTANCE.createFDBroadcast();
			((FDBroadcast) el).setTarget((FBroadcast) obj);
		} else if (obj instanceof FArgument) {
			el = FDeployFactory.eINSTANCE.createFDArgument();
			((FDArgument) el).setTarget((FArgument) obj);
		} else if (obj instanceof FArrayType) {
			el = FDeployFactory.eINSTANCE.createFDArray();
			((FDArray) el).setTarget((FArrayType) obj);
		} else if (obj instanceof FStructType) {
			el = FDeployFactory.eINSTANCE.createFDStruct();
			((FDStruct) el).setTarget((FStructType) obj);
		} else if (obj instanceof FStructType) {
			el = FDeployFactory.eINSTANCE.createFDStruct();
			((FDStruct) el).setTarget((FStructType) obj);
		} else if (obj instanceof FUnionType) {
			el = FDeployFactory.eINSTANCE.createFDUnion();
			((FDUnion) el).setTarget((FUnionType) obj);
		} else if (obj instanceof FField) {
			FField f = (FField) obj;
			el = FDeployFactory.eINSTANCE.createFDField();
			((FDField) el).setTarget(f);
			
			// for fields, we have to embed the dummy object into a dummy parent,
			// this is needed to indicate if it is a struct or union field
			FDCompound parent =
					(f.eContainer() instanceof FStructType) ?
							FDeployFactory.eINSTANCE.createFDStruct() :
							FDeployFactory.eINSTANCE.createFDUnion();
			parent.getFields().add((FDField)el);
		} else if (obj instanceof FEnumerationType) {
			el = FDeployFactory.eINSTANCE.createFDEnumeration();
			((FDEnumeration) el).setTarget((FEnumerationType) obj);
		} else if (obj instanceof FEnumerator) {
			el = FDeployFactory.eINSTANCE.createFDEnumValue();
			((FDEnumValue) el).setTarget((FEnumerator) obj);
		} else if (obj instanceof FMapType) {
			el = FDeployFactory.eINSTANCE.createFDMap();
			((FDMap) el).setTarget((FMapType) obj);
		} else if (obj instanceof FTypeDef) {
			el = FDeployFactory.eINSTANCE.createFDTypedef();
			((FDTypedef) el).setTarget((FTypeDef) obj);
		}
		return el;
	}

	/**
	 * Map an element of a Franca IDL model to the corresponding deployment element (if any).  
	 * 
	 * @param obj  the element of the Franca model
	 * @return the actual mapping or null (if no mapping available) 
	 */
	public FDElement getFDElement(EObject obj) {
		FDElement elem = mapper.getFDElement(obj);
		if (elem == null)
			// just to get a default value if any configured
			elem = createDummyFDEelement(obj);
		return elem;
	}
}
