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
import org.franca.core.franca.FUnionType;
import org.franca.deploymodel.dsl.FDInterfaceMapper;
import org.franca.deploymodel.dsl.fDeploy.FDArgument;
import org.franca.deploymodel.dsl.fDeploy.FDArray;
import org.franca.deploymodel.dsl.fDeploy.FDAttribute;
import org.franca.deploymodel.dsl.fDeploy.FDBroadcast;
import org.franca.deploymodel.dsl.fDeploy.FDElement;
import org.franca.deploymodel.dsl.fDeploy.FDEnumValue;
import org.franca.deploymodel.dsl.fDeploy.FDEnumeration;
import org.franca.deploymodel.dsl.fDeploy.FDInterface;
import org.franca.deploymodel.dsl.fDeploy.FDMethod;
import org.franca.deploymodel.dsl.fDeploy.FDStruct;
import org.franca.deploymodel.dsl.fDeploy.FDUnion;
import org.franca.deploymodel.dsl.fDeploy.FDField;
import org.franca.deploymodel.dsl.fDeploy.FDeployFactory;

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
		return gpa.getBoolean(getFDElement(obj), property);
	}

	public List<Boolean> getBooleanArray (EObject obj, String property) {
		return gpa.getBooleanArray(getFDElement(obj), property);
	}
	


	public Integer getInteger (EObject obj, String property) {
		return gpa.getInteger(getFDElement(obj), property);
	}

	public List<Integer> getIntegerArray (EObject obj, String property) {
		return gpa.getIntegerArray(getFDElement(obj), property);
	}

	
	public String getString (EObject obj, String property) {
		return gpa.getString(getFDElement(obj), property);
	}
	
	public List<String> getStringArray (EObject obj, String property) {
		return gpa.getStringArray(getFDElement(obj), property);
	}


	public String getEnum (EObject obj, String property) {
		return gpa.getEnum(getFDElement(obj), property);
	}

	public List<String> getEnumArray (EObject obj, String property) {
		return gpa.getEnumArray(getFDElement(obj), property);
	}

   public FDElement createDummyFDEelement(EObject obj) {
      FDElement el = null;

      if (obj instanceof FAttribute) {
         el = FDeployFactory.eINSTANCE.createFDAttribute();
         ((FDAttribute) el).setTarget((FAttribute) obj);
      }
      else if (obj instanceof FMethod)
      {
         el = FDeployFactory.eINSTANCE.createFDMethod();
         ((FDMethod) el).setTarget((FMethod) obj);
      }
      else if (obj instanceof FBroadcast)
      {
         el = FDeployFactory.eINSTANCE.createFDBroadcast();
         ((FDBroadcast) el).setTarget((FBroadcast) obj);
      }
      else if (obj instanceof FArgument)
      {
         el = FDeployFactory.eINSTANCE.createFDArgument();
         ((FDArgument) el).setTarget((FArgument) obj);
      }
      else if (obj instanceof FArrayType)
      {
         el = FDeployFactory.eINSTANCE.createFDArray();
         ((FDArray) el).setTarget((FArrayType) obj);
      }
      else if (obj instanceof FStructType)
      {
         el = FDeployFactory.eINSTANCE.createFDStruct();
         ((FDStruct) el).setTarget((FStructType) obj);
      } 
      else if (obj instanceof FStructType)
      {
         el = FDeployFactory.eINSTANCE.createFDStruct();
         ((FDStruct) el).setTarget((FStructType) obj);
      }
      else if (obj instanceof FUnionType)
      {
         el = FDeployFactory.eINSTANCE.createFDUnion();
         ((FDUnion) el).setTarget((FUnionType) obj);
      }
      else if (obj instanceof FField)
      {
         el = FDeployFactory.eINSTANCE.createFDField();
         ((FDField) el).setTarget((FField) obj);
      }
      else if (obj instanceof FEnumerationType)
      {
         el = FDeployFactory.eINSTANCE.createFDEnumeration();
         ((FDEnumeration) el).setTarget((FEnumerationType) obj);
      }
      else if (obj instanceof FEnumerator)
      {
         el = FDeployFactory.eINSTANCE.createFDEnumValue();
         ((FDEnumValue) el).setTarget((FEnumerator) obj);
      }
      return el;
   }

   private FDElement getFDElement(EObject obj)
   {
      FDElement elem = mapper.getFDElement(obj);
      if (elem == null)
         //just to get a default value if any configured
         elem = createDummyFDEelement(obj);
      return elem;
   }
}

