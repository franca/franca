/*******************************************************************************
* Copyright (c) 2012 Harman International (http://www.harman.com).
* All rights reserved. This program and the accompanying materials
* are made available under the terms of the Eclipse Public License v1.0
* which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/epl-v10.html
*******************************************************************************/
package org.franca.deploymodel.core;

import java.util.List;

import org.eclipse.emf.ecore.EObject;
import org.franca.core.franca.FInterface;
import org.franca.deploymodel.dsl.FDInterfaceMapper;
import org.franca.deploymodel.dsl.fDeploy.FDElement;
import org.franca.deploymodel.dsl.fDeploy.FDInterface;

/**
 * This class provides type-safe access to deployment properties which are
 * attached to a Franca IDL interface. The get-functions in this class
 * take an EObject as first argument, which should be an entity from the
 * Franca IDL model (e.g., a FMethod or a FAttribute). The value of the
 * property will be returned in a type-safe way. It will be the actual
 * property value attached to the Franca interface or the default value
 * defined in the specification.
 *    
 * @author KBirken
 * @see FDeployedProvider
 */
public class FDeployedInterface {

	// the actual deployment definition of this interface 
	private FDInterface fdapi;
	
	// the mapper used for getting FDElements from Franca IDL entities
	private FDInterfaceMapper mapper;
	
	// a helper class for getting the actual property values from FDElements
	private GenericPropertyAccessor gpa;
	
	public FDeployedInterface (FDInterface fdapi) {
		this.fdapi = fdapi;
		this.mapper = new FDInterfaceMapper(fdapi);
		this.gpa = new GenericPropertyAccessor(fdapi.getSpec());
	}
	
	public FInterface getFInterface() {
		return fdapi.getTarget();
	}

	
	public Boolean getBoolean (EObject obj, String property) {
		FDElement elem = mapper.getFDElement(obj);
		if (elem==null)
			return null;
		return gpa.getBoolean(elem, property);
	}

	public List<Boolean> getBooleanArray (EObject obj, String property) {
		FDElement elem = mapper.getFDElement(obj);
		if (elem==null)
			return null;
		return gpa.getBooleanArray(elem, property);
	}
	


	public Integer getInteger (EObject obj, String property) {
		FDElement elem = mapper.getFDElement(obj);
		if (elem==null)
			return null;
		return gpa.getInteger(elem, property);
	}

	public List<Integer> getIntegerArray (EObject obj, String property) {
		FDElement elem = mapper.getFDElement(obj);
		if (elem==null)
			return null;
		return gpa.getIntegerArray(elem, property);
	}

	
	public String getString (EObject obj, String property) {
		FDElement elem = mapper.getFDElement(obj);
		if (elem==null)
			return null;
		return gpa.getString(elem, property);
	}
	
	public List<String> getStringArray (EObject obj, String property) {
		FDElement elem = mapper.getFDElement(obj);
		if (elem==null)
			return null;
		return gpa.getStringArray(elem, property);
	}


	public String getEnum (EObject obj, String property) {
		FDElement elem = mapper.getFDElement(obj);
		if (elem==null)
			return null;
		return gpa.getEnum(elem, property);
	}

	public List<String> getEnumArray (EObject obj, String property) {
		FDElement elem = mapper.getFDElement(obj);
		if (elem==null)
			return null;
		return gpa.getEnumArray(elem, property);
	}
}

