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

import org.eclipse.emf.ecore.EObject;
import org.franca.core.framework.FrancaHelpers;
import org.franca.core.franca.FArrayType;
import org.franca.core.franca.FEnumerationType;
import org.franca.core.franca.FStructType;
import org.franca.core.franca.FType;
import org.franca.core.franca.FTypeRef;
import org.franca.core.franca.FTypedElement;
import org.franca.core.franca.FUnionType;
import org.franca.deploymodel.dsl.fDeploy.FDArgument;
import org.franca.deploymodel.dsl.fDeploy.FDArray;
import org.franca.deploymodel.dsl.fDeploy.FDAttribute;
import org.franca.deploymodel.dsl.fDeploy.FDBroadcast;
import org.franca.deploymodel.dsl.fDeploy.FDBuiltInPropertyHost;
import org.franca.deploymodel.dsl.fDeploy.FDDeclaration;
import org.franca.deploymodel.dsl.fDeploy.FDElement;
import org.franca.deploymodel.dsl.fDeploy.FDEnumValue;
import org.franca.deploymodel.dsl.fDeploy.FDEnumeration;
import org.franca.deploymodel.dsl.fDeploy.FDExtensionRoot;
import org.franca.deploymodel.dsl.fDeploy.FDField;
import org.franca.deploymodel.dsl.fDeploy.FDInterface;
import org.franca.deploymodel.dsl.fDeploy.FDInterfaceInstance;
import org.franca.deploymodel.dsl.fDeploy.FDMethod;
import org.franca.deploymodel.dsl.fDeploy.FDPropertyDecl;
import org.franca.deploymodel.dsl.fDeploy.FDPropertyFlag;
import org.franca.deploymodel.dsl.fDeploy.FDProvider;
import org.franca.deploymodel.dsl.fDeploy.FDRootElement;
import org.franca.deploymodel.dsl.fDeploy.FDSpecification;
import org.franca.deploymodel.dsl.fDeploy.FDStruct;
import org.franca.deploymodel.dsl.fDeploy.FDStructOverwrites;
import org.franca.deploymodel.dsl.fDeploy.FDTypedef;
import org.franca.deploymodel.dsl.fDeploy.FDTypes;
import org.franca.deploymodel.dsl.fDeploy.FDUnion;
import org.franca.deploymodel.dsl.fDeploy.FDUnionOverwrites;
import org.franca.deploymodel.extensions.ExtensionRegistry;
import org.franca.deploymodel.extensions.IFDeployExtension;
import org.franca.deploymodel.extensions.IFDeployExtension.Root;

import com.google.common.collect.Lists;
import com.google.common.collect.Sets;

import static org.franca.deploymodel.dsl.fDeploy.FDBuiltInPropertyHost.*;

public class PropertyMappings {

	/**
	 * Get a list of all property declarations for a given deployment element.
	 * 
	 * <p>The deployment element is part of a deployment definition, which in turn
	 * has to refer to the deployment specification given as first argument.
	 * </p>
	 * 
	 * <p>The task is accomplished by first computing all relevant property hosts for 
	 * the given deployment element. Afterwards, all property declarations are
	 * collected which are specified for each of these property hosts in the 
	 * given deployment specification.
	 * </p>
	 * 
	 * <p>E.g., for an FDAttribute element which refers to an Franca IDL FAttribute
	 * element of type UInt8, the following property hosts are computed:
	 * <ul>
	 * <li>INTEGERS</li>
	 * <li>NUMBERS</li>
	 * <li>ATTRIBUTES</li>
	 * </ul></p>
	 * 
	 * <p>
	 * Afterwards, the deployment specification is scanned for declarations
	 * of these property hosts and the properties specified there are collected
	 * and returned.
	 * </p>
	 * 
	 * @param spec the deployment specification
	 * @param elem the deployment element of some deployment definition
	 * @return the list of relevant property declarations for this element  
	 */
	public static final List<FDPropertyDecl> getAllPropertyDecls(FDSpecification spec, FDElement elem) {
		Set<FDPropertyHost> hosts = Sets.newHashSet();

		FDBuiltInPropertyHost builtInMainHost = getBuiltInMainHost(elem);
		if (builtInMainHost!=null) {
			Set<FDBuiltInPropertyHost> builtinHosts = Sets.newHashSet(builtInMainHost);

			FTypeRef typeRef = null;
			boolean isInlineArray = false;
			if (elem instanceof FDAttribute) {
				FTypedElement te = ((FDAttribute) elem).getTarget();
				typeRef = te.getType();
				if (te.isArray())
					isInlineArray = true;
			} else if (elem instanceof FDArgument) {
				FTypedElement te = ((FDArgument) elem).getTarget();
				typeRef = te.getType();
				if (te.isArray())
					isInlineArray = true;
			} else if (elem instanceof FDField) {
				FTypedElement te = ((FDField) elem).getTarget();
				typeRef = te.getType();
				if (te.isArray())
					isInlineArray = true;
			}
			if (typeRef != null) {
				if (FrancaHelpers.isInteger(typeRef))
					builtinHosts.add(INTEGERS);
				else if (FrancaHelpers.isFloatingPoint(typeRef))
					builtinHosts.add(FLOATS);
				else if (FrancaHelpers.isString(typeRef))
					builtinHosts.add(STRINGS);
				else if (FrancaHelpers.isBoolean(typeRef))
					builtinHosts.add(BOOLEANS);
				else if (FrancaHelpers.isByteBuffer(typeRef))
					builtinHosts.add(BYTE_BUFFERS);
			}
			if (isInlineArray) {
				builtinHosts.add(ARRAYS);
			}

			// if looking for INTEGERS or FLOATS, we also look for NUMBERS
			if (builtinHosts.contains(INTEGERS) || builtinHosts.contains(FLOATS))
				builtinHosts.add(NUMBERS);

			// if looking for STRUCT_FIELDS or UNION_FIELDS, we also look for FIELDS
			if (builtinHosts.contains(STRUCT_FIELDS) || builtinHosts.contains(UNION_FIELDS))
				builtinHosts.add(FIELDS);
			
			for(FDBuiltInPropertyHost h : builtinHosts) {
				hosts.add(new FDPropertyHost(h));
			}
		}
		
		// check hosts from extensions
		FDRootElement rootElement = FDModelUtils.getRootElement(elem);
		if (rootElement instanceof FDExtensionRoot) {
			String rootTag = ((FDExtensionRoot) rootElement).getTag();
			Root root = ExtensionRegistry.findRoot(rootTag);
			for(IFDeployExtension.Host rh : root.getHosts()) {
				hosts.add(new FDPropertyHost(rh.getName()));
			}
		}

		return getAllPropertyDeclsHelper(spec, hosts);
	}

	/**
	 * Get a list of all property declarations for a given Franca type.
	 * 
	 * <p>The task is accomplished by first computing the main property hosts for 
	 * the given Franca type. Afterwards, all property declarations are
	 * collected which are specified for each of these property hosts in the 
	 * given deployment specification.
	 * </p>
	 * 
	 * @param spec the deployment specification
	 * @param type the Franca type
	 * @return the list of relevant property declarations for this type  
	 */
	public static final List<FDPropertyDecl> getAllPropertyDecls(FDSpecification spec, FType type) {
		FDPropertyHost host = new FDPropertyHost(getMainHost(type));
		Set<FDPropertyHost> hosts = Sets.newHashSet(host);
		return getAllPropertyDeclsHelper(spec, hosts);
	}
	
	/**
	 * Get a list of all property declarations for a given property host.
	 * 
	 * This is done by scanning the given deployment specification and collecting
	 * all property declarations for the given host.
	 * 
	 * @param spec the deployment specification
	 * @param host a property host
	 * @return the list of relevant property declarations for this host  
	 */
	public static final List<FDPropertyDecl> getAllPropertyDecls(FDSpecification spec, FDPropertyHost host) {
		Set<FDPropertyHost> hosts = Sets.newHashSet(host);
		return getAllPropertyDeclsHelper(spec, hosts);
	}

	/**
	 * Get a list of all property declarations for a given set of property hosts.
	 * 
	 * This is done by scanning the given deployment specification and collecting
	 * all property declarations for each of the hosts in the set.
	 * 
	 * @param spec the deployment specification
	 * @param hosts a set of property hosts
	 * @return the list of relevant property declarations for all of these hosts  
	 */
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

	/**
	 * Get the built-in main host for a given deployment element.
	 * 
	 * @param elem a deployment element
	 * @return the main host for the type of this deployment element.
	 */
	private static FDBuiltInPropertyHost getBuiltInMainHost(FDElement elem) {
		// check built-in elements first
		if (elem instanceof FDProvider) {
			return PROVIDERS;
		} else if (elem instanceof FDInterfaceInstance) {
			return INSTANCES;
		} else if (elem instanceof FDInterface) {
			return INTERFACES;
		} else if (elem instanceof FDTypes) {
			return TYPE_COLLECTIONS;
		} else if (elem instanceof FDAttribute) {
			return ATTRIBUTES;
		} else if (elem instanceof FDMethod) {
			return METHODS;
		} else if (elem instanceof FDBroadcast) {
			return BROADCASTS;
		} else if (elem instanceof FDArgument) {
			return ARGUMENTS;
		} else if (elem instanceof FDArray) {
			return ARRAYS;
		} else if (elem instanceof FDStruct || elem instanceof FDStructOverwrites) {
			return STRUCTS;
		} else if (elem instanceof FDUnion || elem instanceof FDUnionOverwrites) {
			return UNIONS;
		} else if (elem instanceof FDField) {
			EObject p = elem.eContainer();
			if (p instanceof FDStruct || p instanceof FDStructOverwrites)
				return STRUCT_FIELDS;
			else if (p instanceof FDUnion || p instanceof FDUnionOverwrites)
				return UNION_FIELDS;
			else
				return null;
		} else if (elem instanceof FDEnumeration) {
			return ENUMERATIONS;
		} else if (elem instanceof FDEnumValue) {
			return ENUMERATORS;
		} else if (elem instanceof FDTypedef) {
			return TYPEDEFS;
		}

		return null;
	}

	/**
	 * Get the main deployment host for a given Franca type.
	 * 
	 * @param elem a deployment element
	 * @return the main host for the type of this deployment element.
	 */
	private static FDBuiltInPropertyHost getMainHost(FType type) {
		if (type instanceof FArrayType) {
			return ARRAYS;
		} else if (type instanceof FStructType) {
			return STRUCTS;
		} else if (type instanceof FUnionType) {
			return UNIONS;
		} else if (type instanceof FEnumerationType) {
			return ENUMERATIONS;
		}
		return null;
	}

	
	// *****************************************************************************

	/**
	 * Check if the given list of property declarations contains at least one mandatory property.
	 * 
	 * @param decls a list of property declarations 
	 * @return true if at least one of the properties is mandatory
	 */
	public static boolean hasMandatoryProperties(List<FDPropertyDecl> decls) {
		for (FDPropertyDecl decl : decls) {
			if (isMandatory(decl))
				return true;
		}
		return false;
	}

	/**
	 * Check if the given property declaration is mandatory.
	 * 
	 * Mandatory means: Not optional and no default value.
	 * 
	 * @param decl a property declaration
	 * @return true if the property is mandatory
	 */
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
