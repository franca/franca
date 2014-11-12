/*******************************************************************************
 * Copyright (c) 2012 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.deploymodel.core;

import java.util.List;
import java.util.Set;

import org.franca.core.framework.FrancaHelpers;
import org.franca.core.franca.FTypeRef;
import org.franca.deploymodel.dsl.fDeploy.FDArgument;
import org.franca.deploymodel.dsl.fDeploy.FDArray;
import org.franca.deploymodel.dsl.fDeploy.FDAttribute;
import org.franca.deploymodel.dsl.fDeploy.FDBroadcast;
import org.franca.deploymodel.dsl.fDeploy.FDDeclaration;
import org.franca.deploymodel.dsl.fDeploy.FDElement;
import org.franca.deploymodel.dsl.fDeploy.FDEnumValue;
import org.franca.deploymodel.dsl.fDeploy.FDEnumeration;
import org.franca.deploymodel.dsl.fDeploy.FDField;
import org.franca.deploymodel.dsl.fDeploy.FDInterface;
import org.franca.deploymodel.dsl.fDeploy.FDInterfaceInstance;
import org.franca.deploymodel.dsl.fDeploy.FDMethod;
import org.franca.deploymodel.dsl.fDeploy.FDPropertyDecl;
import org.franca.deploymodel.dsl.fDeploy.FDPropertyFlag;
import org.franca.deploymodel.dsl.fDeploy.FDPropertyHost;
import org.franca.deploymodel.dsl.fDeploy.FDProvider;
import org.franca.deploymodel.dsl.fDeploy.FDSpecification;
import org.franca.deploymodel.dsl.fDeploy.FDStruct;
import org.franca.deploymodel.dsl.fDeploy.FDTypes;
import org.franca.deploymodel.dsl.fDeploy.FDUnion;

import com.google.common.collect.Lists;
import com.google.common.collect.Sets;

public class PropertyMappings {

	public static final List<FDPropertyDecl> getAllPropertyDecls(FDSpecification spec, FDElement elem) {
		Set<FDPropertyHost> hosts = Sets.newHashSet(getMainHost(elem));

		FTypeRef typeRef = null;
		if (elem instanceof FDAttribute) {
			typeRef = ((FDAttribute) elem).getTarget().getType();
		} else if (elem instanceof FDArgument) {
			typeRef = ((FDArgument) elem).getTarget().getType();
		} else if (elem instanceof FDField) {
			typeRef = ((FDField) elem).getTarget().getType();
		}
		if (typeRef != null) {
			if (FrancaHelpers.isInteger(typeRef))
				hosts.add(FDPropertyHost.INTEGERS);
			else if (FrancaHelpers.isFloatingPoint(typeRef))
				hosts.add(FDPropertyHost.FLOATS);
			else if (FrancaHelpers.isString(typeRef))
				hosts.add(FDPropertyHost.STRINGS);
			else if (FrancaHelpers.isByteBuffer(typeRef))
				hosts.add(FDPropertyHost.BYTE_BUFFERS);
		}

		// if looking for INTEGERS or FLOATS, we also look for NUMBERS
		if (hosts.contains(FDPropertyHost.INTEGERS) || hosts.contains(FDPropertyHost.FLOATS))
			hosts.add(FDPropertyHost.NUMBERS);

		return getAllPropertyDeclsHelper(spec, hosts);
	}

	public static final List<FDPropertyDecl> getAllPropertyDecls(FDSpecification spec, FDPropertyHost host) {
		Set<FDPropertyHost> hosts = Sets.newHashSet(host);
		return getAllPropertyDeclsHelper(spec, hosts);
	}

	private static final List<FDPropertyDecl> getAllPropertyDeclsHelper(FDSpecification spec, Set<FDPropertyHost> hosts) {
		List<FDPropertyDecl> properties = Lists.newArrayList();
		// TODO: add full cycle check on getBase()-relation
		if (spec.getBase()!=null && spec.getBase()!=spec) {
			// get declarations from base spec recursively
			properties.addAll(getAllPropertyDeclsHelper(spec.getBase(), hosts));
		}

		// get all declarations selected by one member of hosts set
		for (FDDeclaration decl : spec.getDeclarations()) {
			if (hosts.contains(decl.getHost())) {
				properties.addAll(decl.getProperties());
			}
		}

		return properties;
	}

	private static FDPropertyHost getMainHost(FDElement elem) {
		if (elem instanceof FDProvider) {
			return FDPropertyHost.PROVIDERS;
		} else if (elem instanceof FDInterfaceInstance) {
			return FDPropertyHost.INSTANCES;
		} else if (elem instanceof FDInterface) {
			return FDPropertyHost.INTERFACES;
		} else if (elem instanceof FDTypes) {
			return FDPropertyHost.TYPE_COLLECTIONS;
		} else if (elem instanceof FDAttribute) {
			return FDPropertyHost.ATTRIBUTES;
		} else if (elem instanceof FDMethod) {
			return FDPropertyHost.METHODS;
		} else if (elem instanceof FDBroadcast) {
			return FDPropertyHost.BROADCASTS;
		} else if (elem instanceof FDArgument) {
			return FDPropertyHost.ARGUMENTS;
		} else if (elem instanceof FDArray) {
			return FDPropertyHost.ARRAYS;
		} else if (elem instanceof FDStruct) {
			return FDPropertyHost.STRUCTS;
		} else if (elem instanceof FDUnion) {
			return FDPropertyHost.UNIONS;
		} else if (elem instanceof FDField) {
			if (elem.eContainer() instanceof FDStruct)
				return FDPropertyHost.STRUCT_FIELDS;
			else // FDUnion
				return FDPropertyHost.UNION_FIELDS;
		} else if (elem instanceof FDEnumeration) {
			return FDPropertyHost.ENUMERATIONS;
		} else if (elem instanceof FDEnumValue) {
			return FDPropertyHost.ENUMERATORS;
		}

		return null;
	}


	// *****************************************************************************

	public static boolean hasMandatoryProperties(List<FDPropertyDecl> decls) {
		for (FDPropertyDecl decl : decls) {
			if (isMandatory(decl))
				return true;
		}
		return false;
	}

	public static boolean isMandatory(FDPropertyDecl decl) {
		for (FDPropertyFlag flag : decl.getFlags()) {
			if (flag.getOptional() != null || flag.getDefault() != null) {
				// property declaration is either optional or has a default
				return false;
			}
		}
		return true;
	}

}
