/*******************************************************************************
* Copyright (c) 2012 Harman International (http://www.harman.com).
* All rights reserved. This program and the accompanying materials
* are made available under the terms of the Eclipse Public License v1.0
* which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/epl-v10.html
*******************************************************************************/
package org.franca.deploymodel.dsl;

import java.util.Collection;
import java.util.List;
import java.util.Map;
import java.util.Queue;
import java.util.Set;

import org.eclipse.emf.ecore.EObject;
import org.franca.deploymodel.dsl.fDeploy.FDArgument;
import org.franca.deploymodel.dsl.fDeploy.FDArgumentList;
import org.franca.deploymodel.dsl.fDeploy.FDArray;
import org.franca.deploymodel.dsl.fDeploy.FDAttribute;
import org.franca.deploymodel.dsl.fDeploy.FDBroadcast;
import org.franca.deploymodel.dsl.fDeploy.FDElement;
import org.franca.deploymodel.dsl.fDeploy.FDEnumValue;
import org.franca.deploymodel.dsl.fDeploy.FDEnumeration;
import org.franca.deploymodel.dsl.fDeploy.FDField;
import org.franca.deploymodel.dsl.fDeploy.FDInterface;
import org.franca.deploymodel.dsl.fDeploy.FDMap;
import org.franca.deploymodel.dsl.fDeploy.FDMethod;
import org.franca.deploymodel.dsl.fDeploy.FDRootElement;
import org.franca.deploymodel.dsl.fDeploy.FDStruct;
import org.franca.deploymodel.dsl.fDeploy.FDTypeDefinition;
import org.franca.deploymodel.dsl.fDeploy.FDTypedef;
import org.franca.deploymodel.dsl.fDeploy.FDTypes;
import org.franca.deploymodel.dsl.fDeploy.FDUnion;

import com.google.common.collect.Lists;
import com.google.common.collect.Maps;
import com.google.common.collect.Sets;

/**
 * The FDMapper provides a mapping from the elements of a Franca model
 * (i.e., the elements in a *.fidl file) to the property definitions
 * of a Franca deployment model.
 * 
 * For example, if there is a property definition in some *.fdepl-file for
 * an FMethod, the FDMapper will map this FMethod to the corresponding
 * FDMethod object.
 */
public class FDMapper {

	Map<EObject, FDElement> mapping = Maps.newHashMap();
	
	/**
	 * This constructor of FDMapper will initialize the mapper
	 * from a given deployment definition for an interface.
	 * 
	 * @param fdi  the deployment definition for the FInterface. 
	 */
	public FDMapper (FDInterface fdi) {
		init(fdi);
	}

	/**
	 * This constructor of FDMapper will initialize the mapper
	 * from a given deployment definition for some global type definitions.
	 * 
	 * @param fdt  the deployment definition for a list of types. 
	 */
	public FDMapper (FDTypes fdt) {
		initTypeCollection(fdt);
	}


	/**
	 * The actual mapping function. For an element of a Franca interface
	 * model it will provide the corresponding deployment element (if any).  
	 * 
	 * @param obj  the element of the Franca model
	 * @return the actual mapping or null (if no mapping available) 
	 */
	public FDElement getFDElement (EObject obj) {
		return mapping.get(obj);
	}
	
	
	// *****************************************************************************
	// private helpers for initialization
	
	private void init (FDInterface fdi) {
		mapping.put(fdi.getTarget(), fdi);
		for(FDAttribute e : fdi.getAttributes()) {
			mapping.put(e.getTarget(), e);
		}
		for(FDMethod e : fdi.getMethods()) {
			mapping.put(e.getTarget(), e);
			initArguments(e.getInArguments());
			initArguments(e.getOutArguments());
		}
		for(FDBroadcast e : fdi.getBroadcasts()) {
			mapping.put(e.getTarget(), e);
			initArguments(e.getOutArguments());
		}
		
		initTypes(fdi.getTypes());
		
		// init global types referenced by 'use'
		initReferenced(fdi.getUse());
	}


	private void initReferenced (Collection<FDRootElement> used) {
		Queue<FDRootElement> work = Lists.newLinkedList();
		Set<FDTypes> visited = Sets.newHashSet();

		work.addAll(used);
		while (! work.isEmpty()) {
			FDRootElement e = work.poll();
			if (e instanceof FDTypes) {
				FDTypes fdTypes = (FDTypes)e;
				if (! visited.contains(fdTypes)) {
					visited.add(fdTypes);

					// init global types in this root element
					initTypeCollection(fdTypes);

					// add its referenced root elements to queue
					work.addAll(e.getUse());
				}
			}
		}
	}
	
	private void initTypeCollection (FDTypes fdTypes) {
		mapping.put(fdTypes.getTarget(), fdTypes);
		initTypes (fdTypes.getTypes());
	}
	
	private void initTypes (List<FDTypeDefinition> fdTypes) {
		for(FDTypeDefinition t : fdTypes) {
			if (t instanceof FDArray) {
				mapping.put(((FDArray) t).getTarget(), t);
			} else if (t instanceof FDStruct) {
				mapping.put(((FDStruct) t).getTarget(), t);
				for(FDField f : ((FDStruct) t).getFields()) {
					mapping.put(f.getTarget(), f);
				}
			} else if (t instanceof FDUnion) {
				mapping.put(((FDUnion) t).getTarget(), t);
				for(FDField f : ((FDUnion) t).getFields()) {
					mapping.put(f.getTarget(), f);
				}
			} else if (t instanceof FDEnumeration) {
				mapping.put(((FDEnumeration) t).getTarget(), t);
				for(FDEnumValue e : ((FDEnumeration) t).getEnumerators()) {
					mapping.put(e.getTarget(), e);
				}
			} else if (t instanceof FDMap) {
				mapping.put(((FDMap) t).getTarget(), t);
			} else if (t instanceof FDTypedef) {
				mapping.put(((FDTypedef) t).getTarget(), t);
			}
		}
	}
	
	private void initArguments (FDArgumentList args) {
		if (args==null)
			return;
		
		for(FDArgument arg : args.getArguments()) {
			mapping.put(arg.getTarget(), arg);
		}
	}
}
