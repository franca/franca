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
import org.franca.deploymodel.dsl.fDeploy.FDBoolean;
import org.franca.deploymodel.dsl.fDeploy.FDComplexValue;
import org.franca.deploymodel.dsl.fDeploy.FDElement;
import org.franca.deploymodel.dsl.fDeploy.FDEnumerator;
import org.franca.deploymodel.dsl.fDeploy.FDInteger;
import org.franca.deploymodel.dsl.fDeploy.FDInterfaceRef;
import org.franca.deploymodel.dsl.fDeploy.FDProperty;
import org.franca.deploymodel.dsl.fDeploy.FDPropertyDecl;
import org.franca.deploymodel.dsl.fDeploy.FDPropertyFlag;
import org.franca.deploymodel.dsl.fDeploy.FDSpecification;
import org.franca.deploymodel.dsl.fDeploy.FDString;
import org.franca.deploymodel.dsl.fDeploy.FDTypeOverwrites;
import org.franca.deploymodel.dsl.fDeploy.FDValue;
import org.franca.deploymodel.dsl.fDeploy.FDValueArray;

import com.google.common.collect.Lists;

/**
 * This class allows the type-safe access to property values for a given
 * Franca deployment specification. It also handles to return the correct
 * default values, if those have been defined in the specification and not
 * overridden by actual concrete property definitions.
 */
public class GenericPropertyAccessor {

	private final FDSpecification spec;
	
	/**
	 * Construct a GenericPropertyAccessor object from a FDSpecification.
	 * @param spec the FDSpecification
	 */
	public GenericPropertyAccessor (FDSpecification spec) {
		this.spec = spec;
	}
	
	
	public Boolean getBoolean (FDElement elem, String property) {
		FDValue val = getSingleValue(elem, property);
		if (val!=null && val instanceof FDBoolean) {
			return ((FDBoolean) val).getValue().equals("true");
		}
		return null;
	}

	public List<Boolean> getBooleanArray (FDElement elem, String property) {
		FDValueArray valarray = getValueArray(elem, property);
		if (valarray==null)
			return null;
		
		List<Boolean> vals = Lists.newArrayList();
		for(FDValue v : valarray.getValues()) {
			if (v instanceof FDBoolean) {
				vals.add(((FDBoolean) v).getValue().equals("true"));
			} else {
				return null;
			}
		}
		return vals;
	}


	public Integer getInteger (FDElement elem, String property) {
		FDValue val = getSingleValue(elem, property);
		if (val!=null && val instanceof FDInteger) {
			return ((FDInteger) val).getValue();
		}
		return null;
	}

	public List<Integer> getIntegerArray (FDElement elem, String property) {
		FDValueArray valarray = getValueArray(elem, property);
		if (valarray==null)
			return null;
		
		List<Integer> vals = Lists.newArrayList();
		for(FDValue v : valarray.getValues()) {
			if (v instanceof FDInteger) {
				vals.add(((FDInteger) v).getValue());
			} else {
				return null;
			}
		}
		return vals;
	}

	public String getString (FDElement elem, String property) {
		FDValue val = getSingleValue(elem, property);
		if (val!=null && val instanceof FDString) {
			return ((FDString) val).getValue();
		}
		return null;
	}
	
	public List<String> getStringArray (FDElement elem, String property) {
		FDValueArray valarray = getValueArray(elem, property);
		if (valarray==null)
			return null;
		
		List<String> vals = Lists.newArrayList();
		for(FDValue v : valarray.getValues()) {
			if (v instanceof FDString) {
				vals.add(((FDString) v).getValue());
			} else {
				return null;
			}
		}
		return vals;
	}

	
	public FInterface getInterface (FDElement elem, String property) {
		FDValue val = getSingleValue(elem, property);
		if (val!=null && val instanceof FDInterfaceRef) {
			return ((FDInterfaceRef) val).getValue();
		}
		return null;
	}
	
	public List<FInterface> getInterfaceArray (FDElement elem, String property) {
		FDValueArray valarray = getValueArray(elem, property);
		if (valarray==null)
			return null;
		
		List<FInterface> vals = Lists.newArrayList();
		for(FDValue v : valarray.getValues()) {
			if (v instanceof FDInterfaceRef) {
				vals.add(((FDInterfaceRef) v).getValue());
			} else {
				return null;
			}
		}
		return vals;
	}


	@SuppressWarnings("unchecked")
	public <RuntimeType extends EObject> RuntimeType getGenericReference(
		FDElement elem,
		Class<? extends EObject> runtimeType,
		String property
	) {
		FDValue val = getSingleValue(elem, property);
		if (val!=null) {
			EObject ref = FDModelUtils.getGenericRef(val);
			if (ref!=null && runtimeType.isInstance(ref)) {
				// TODO: this cast will only work if RuntimeType and runtimeType are identical, is there a better way?
				return (RuntimeType)ref;
			}
		}
		return null;
	}
	
	@SuppressWarnings("unchecked")
	public <RuntimeType extends EObject> List<RuntimeType> getGenericReferenceArray(
		FDElement elem,
		Class<? extends EObject> runtimeType,
		String property
	) {
		FDValueArray valarray = getValueArray(elem, property);
		if (valarray==null)
			return null;
		
		List<RuntimeType> vals = Lists.newArrayList();
		for(FDValue v : valarray.getValues()) {
			EObject ref = FDModelUtils.getGenericRef(v);
			if (ref!=null && runtimeType.isInstance(ref)) {
				// TODO: this cast will only work if RuntimeType and runtimeType are identical, is there a better way?
				vals.add((RuntimeType)ref);
			}
		}
		return vals;
	}


	public String getEnum (FDElement elem, String property) {
		FDValue val = getSingleValue(elem, property);
		if (val!=null && FDModelUtils.isEnumerator(val)) {
			return FDModelUtils.getEnumerator(val).getName();
		}
		return null;
	}

	public List<String> getEnumArray (FDElement elem, String property) {
		FDValueArray valarray = getValueArray(elem, property);
		if (valarray==null)
			return null;
		
		List<String> vals = Lists.newArrayList();
		for(FDValue v : valarray.getValues()) {
			if (FDModelUtils.isEnumerator(v)) {
				FDEnumerator e = FDModelUtils.getEnumerator(v);
				vals.add(e.getName());
			} else {
				return null;
			}
		}
		return vals;
	}


	
	// *****************************************************************************

	private FDValue getSingleValue (FDElement elem, String property) {
		FDComplexValue val = getValue(elem, property);
		if (val!=null) {
			return val.getSingle();
		}
		return null;
	}

	private FDValueArray getValueArray (FDElement elem, String property) {
		FDComplexValue val = getValue(elem, property);
		if (val!=null) {
			return val.getArray();
		}
		return null;
	}

	
	/**
	 * Get a property's value for a given FDElement. The property is defined
	 * by its name (as String). If there is no explicit value for this property,
	 * use the appropriate default. If this hasn't been defined either, return 
	 * null.
	 * 
	 * Note: If the FDElement is an overwrite element, this method will not
	 * take into account the default given in the deployment specification.
	 * For overwrite elements, the fallback value is the original property
	 * definition.
	 * 
	 * @param elem the Franca deployment element
	 * @param property the name of the property
	 * @return the property's value (might be a single value or an array)
	 */
	private FDComplexValue getValue (FDElement elem, String property) {
		// if the element doesn't have properties, it is not relevant for deployment
		// we will then just compute the default for this property.
		if (elem.getProperties() != null) {
			// look if there is an explicit value for the property
			for(FDProperty prop : elem.getProperties().getItems()) {
				if (prop.getDecl().getName().equals(property)) {
					return prop.getValue();
				}
			}

			// check for overwrite case
			if (isOverwrite(elem)) {
				// this is an overwrite element, ignore defaults
				return null;
			}
		}

		// no explicit value, but also no overwrite: look for default value for this property
		List<FDPropertyDecl> decls = PropertyMappings.getAllPropertyDecls(spec, elem);
		for(FDPropertyDecl decl : decls) {
			if (decl.getName().equals(property)) {
				FDComplexValue dflt = getDefault(decl);
				if (dflt!=null)
					return dflt;
			}
		}

		// no explicit value, and no default value =>
		// must be an optional property which is not defined here
		return null;
	}

	private static boolean isOverwrite (FDElement elem) {
		EObject e = elem;
		while (e!=null) {
			e = e.eContainer();
			if (e!=null && e instanceof FDTypeOverwrites)
				return true;
		}
		return false;
	}

	public static FDComplexValue getDefault (FDPropertyDecl decl) {
		for(FDPropertyFlag flag : decl.getFlags()) {
			if (flag.getDefault()!=null) {
				return flag.getDefault();
			}
		}
		return null;
	}
	
	/**
	 * Returns the belonging property declaration of a deployment element.
	 * 
	 * @param property
	 * @return
	 */
   public static FDPropertyDecl getPropertyDecl(EObject property) {
      EObject current = property;

      while (current != null && !(current instanceof FDPropertyDecl))
         current = current.eContainer();
      return (FDPropertyDecl) current;
   }

   /**
    * Checks if the EObject is part of a deployment specification.
    * 
    * @param property
    * @return
    */
   public static boolean isSpecification(EObject property) {
      EObject current = property;

      while (current != null) {
         if (current instanceof FDPropertyDecl)
            return true;
         if (current instanceof FDProperty)
            return false;
         current = current.eContainer();
      }

      return false;
   }

   /**
    * Checks if the EObject is the default value for its belonging property.
    * 
    * @param element 
    * @return true if the EObject is the default value
    */
   public static boolean isDefault(EObject element) {
      FDPropertyDecl decl = getPropertyDecl(element);
      FDComplexValue value = getDefault(decl);

      if (value != null && value.getSingle() != null) {
    	  FDValue single = value.getSingle();
         if (FDModelUtils.isEnumerator(single))
            return FDModelUtils.getEnumerator(single) == element;
         else
            return single == element;
      }
      return false;
   }
}
