/*******************************************************************************
* Copyright (c) 2012 Harman International (http://www.harman.com).
* All rights reserved. This program and the accompanying materials
* are made available under the terms of the Eclipse Public License v1.0
* which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/epl-v10.html
*******************************************************************************/
package org.franca.deploymodel.core;

import java.util.List;

import org.franca.deploymodel.dsl.fDeploy.FDInterface;
import org.franca.deploymodel.dsl.fDeploy.FDModel;
import org.franca.deploymodel.dsl.fDeploy.FDRootElement;
import org.franca.deploymodel.dsl.fDeploy.FDTypes;

import com.google.common.collect.Lists;

public class FDModelExtender {

	private FDModel fdmodel;
	
	public FDModel getFDModel()
	{
		return fdmodel;
	}
	
	// analysis data cached for a given FDModel
//	private Map<FDInterface,FDInterfaceMapper> interfaceMappers;
	
	public FDModelExtender (FDModel fdmodel) {
		this.fdmodel = fdmodel;
		
//		initMappers();
	}
	
	
	/**
	 * Get a list of all Franca IDL interfaces referenced by a Franca deployment model
	 * @return the list of FDInterfaces
	 */
	public List<FDInterface> getFDInterfaces() {
		List<FDInterface> results = Lists.newArrayList();
		
		for(FDRootElement elem : fdmodel.getDeployments()) {
			if (elem instanceof FDInterface) {
				results.add((FDInterface) elem);
			}
		}
		
		return results;
	}


	/**
	 * Get a list of all Franca IDL type collections referenced by a Franca deployment model
	 * @return the list of FDTypes
	 */
	public List<FDTypes> getFDTypesList() {
		List<FDTypes> results = Lists.newArrayList();
		
		for(FDRootElement elem : fdmodel.getDeployments()) {
			if (elem instanceof FDTypes) {
				results.add((FDTypes) elem);
			}
		}
		
		return results;
	}


	// *****************************************************************************

//	private void initMappers() {
//		interfaceMappers = Maps.newHashMap();
//		
//		for(FDRootElement elem : fdmodel.getDeployments()) {
//			if (elem instanceof FDInterface) {
//				FDInterface fdi = (FDInterface)elem;
//				interfaceMappers.put(fdi, new FDInterfaceMapper(fdi));
//			}
//		}
//	}
}

