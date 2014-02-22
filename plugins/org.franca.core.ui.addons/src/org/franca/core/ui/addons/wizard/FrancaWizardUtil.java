/*******************************************************************************
 * Copyright (c) 2012 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.core.ui.addons.wizard;

import java.io.IOException;
import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.util.Collections;
import java.util.Map;

import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.IWorkspaceRoot;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IPath;
import org.eclipse.core.runtime.Path;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.xtext.ui.resource.IResourceSetProvider;
import org.franca.core.franca.FInterface;
import org.franca.core.franca.FModel;
import org.franca.core.franca.FTypeCollection;
import org.franca.core.franca.FrancaFactory;
import org.franca.deploymodel.dsl.fDeploy.FDModel;
import org.franca.deploymodel.dsl.fDeploy.FDRootElement;
import org.franca.deploymodel.dsl.fDeploy.FDSpecification;
import org.franca.deploymodel.dsl.fDeploy.FDeployFactory;

/**
 * Utility class which contains some helper methods related to the Franca
 * wizards.
 * 
 * @author Tamas Szabo (itemis AG)
 * 
 */
public class FrancaWizardUtil {

	/**
	 * Creates a new Franca IDL file based on the given parameters.
	 * 
	 * @param resourceSetProvider
	 *            used to obtain the corresponding {@link ResourceSet} for the
	 *            project
	 * @param parameters
	 *            the parameters used during the file creation
	 * @return the path of the created file
	 */
	public static IPath createFrancaIDLFile(
			IResourceSetProvider resourceSetProvider, Map<String, String> parameters) {

		IWorkspaceRoot root = ResourcesPlugin.getWorkspace().getRoot();
		IResource containerResource = root.findMember(new Path(parameters.get("containerName")));
		ResourceSet resourceSet = resourceSetProvider.get(containerResource.getProject());

		IPath filePath = containerResource.getFullPath().append(parameters.get("fileName"));
		String fullPath = filePath.toString();

		URI fileURI = URI.createPlatformResourceURI(fullPath, false);
		Resource resource = resourceSet.createResource(fileURI);

		FModel model = FrancaFactory.eINSTANCE.createFModel();
		model.setName(parameters.get("packageName"));

		String interfaceName = parameters.get("interfaceName");
		String typeCollectionName = parameters.get("typeCollectionName");

		if (interfaceName != null && interfaceName.length() > 0) {
			FInterface _interface = FrancaFactory.eINSTANCE.createFInterface();
			_interface.setName(interfaceName);
			model.getInterfaces().add(_interface);
		}

		if (typeCollectionName != null && typeCollectionName.length() > 0) {
			FTypeCollection typeCollection = FrancaFactory.eINSTANCE
					.createFTypeCollection();
			typeCollection.setName(typeCollectionName);
			model.getTypeCollections().add(typeCollection);
		}

		resource.getContents().add(model);

		try {
			resource.save(Collections.EMPTY_MAP);
			containerResource.getProject().refreshLocal(IResource.DEPTH_INFINITE, null);
			return filePath;
		}
		catch (IOException e) {
			e.printStackTrace();
			return null;
		}
		catch (CoreException e) {
			e.printStackTrace();
			return null;
		}
	}

	/**
	 * Creates a new Franca FDEPL (deployment) file based on the given
	 * parameters.
	 * 
	 * @param resourceSetProvider
	 *            used to obtain the corresponding {@link ResourceSet} for the
	 *            project
	 * @param parameters
	 *            the parameters used during the file creation
	 * @return the path of the created file
	 */
	public static IPath createFrancaFDEPLFile(
			IResourceSetProvider resourceSetProvider, Map<String, String> parameters) {

		IWorkspaceRoot root = ResourcesPlugin.getWorkspace().getRoot();
		IResource containerResource = root.findMember(new Path(parameters.get("containerName")));
		ResourceSet resourceSet = resourceSetProvider.get(containerResource.getProject());

		IPath filePath = containerResource.getFullPath().append(parameters.get("fileName"));
		String fullPath = filePath.toString();

		URI fileURI = URI.createPlatformResourceURI(fullPath, false);
		Resource resource = resourceSet.createResource(fileURI);

		FDModel model = FDeployFactory.eINSTANCE.createFDModel();

		String specificationName = parameters.get("specificationName");
		String definitionName = parameters.get("definitionName");

		if (specificationName != null && specificationName.length() > 0) {
			FDSpecification spec = FDeployFactory.eINSTANCE.createFDSpecification();
			spec.setName(specificationName);
			model.getSpecifications().add(spec);
		}

		if (definitionName != null && definitionName.length() > 0) {
			FDRootElement def = FDeployFactory.eINSTANCE.createFDRootElement();
			def.setName(definitionName);
			model.getDeployments().add(def);
		}

		resource.getContents().add(model);

		try {
			resource.save(Collections.EMPTY_MAP);
			containerResource.getProject().refreshLocal(IResource.DEPTH_INFINITE, null);
			return filePath;
		}
		catch (IOException e) {
			e.printStackTrace();
			return null;
		}
		catch (CoreException e) {
			e.printStackTrace();
			return null;
		}
	}

	public static Object tryGet(Object obj, String field) {
		try {
			Field f = obj.getClass().getDeclaredField(field);
			f.setAccessible(true);
			return f.get(obj);
		}
		catch (Exception e) {
			return null;
		}
	}

	public static Object tryInvoke(Object obj, String method) {
		return tryInvoke(obj, method, new Class<?>[0], new Object[0]);
	}

	public static Object tryInvoke(Object obj, String method, Class<?>[] paramTypes, Object[] params) {
		try {
			Method m = obj.getClass().getMethod(method, paramTypes);
			return m.invoke(obj, params);
		}
		catch (Exception e) {
			return null;
		}
	}

	public static boolean isJDTAvailable() {
		try {
			Class.forName("org.eclipse.jdt.core.IJavaProject");
			return true;
		}
		catch (ClassNotFoundException e) {
			return false;
		}
	}
}
