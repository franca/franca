/*******************************************************************************
 * Copyright (c) 2013 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.deploymodel.dsl.scoping;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.util.EcoreUtil;
import org.eclipse.xtext.naming.IQualifiedNameProvider;
import org.eclipse.xtext.resource.EObjectDescription;
import org.eclipse.xtext.resource.IEObjectDescription;
import org.eclipse.xtext.resource.IResourceDescription;
import org.eclipse.xtext.scoping.IScope;
import org.eclipse.xtext.scoping.impl.AbstractScope;
import org.eclipse.xtext.scoping.impl.ImportUriGlobalScopeProvider;
import org.franca.core.franca.FModel;
import org.franca.core.franca.FTypeCollection;
import org.franca.deploymodel.dsl.fDeploy.FDModel;
import org.franca.deploymodel.dsl.fDeploy.Import;

/**
 * Scope for type collections, which is able to handle 
 * anonymous ones too. 
 * 
 * @author Tamas Szabo (itemis AG)
 *
 */
public class FTypeCollectionScope extends AbstractScope {

	private ImportUriGlobalScopeProvider importUriGlobalScopeProvider;
	private Resource resource;
	private IQualifiedNameProvider qualifiedNameProvider;
	private FDModel deploymentModel;
	private Set<URI> imports;

	protected FTypeCollectionScope(IScope parent, boolean ignoreCase,
			ImportUriGlobalScopeProvider importUriGlobalScopeProvider,
			Resource resource, IQualifiedNameProvider qualifiedNameProvider) {
		super(parent, ignoreCase);
		this.importUriGlobalScopeProvider = importUriGlobalScopeProvider;
		this.resource = resource;
		this.qualifiedNameProvider = qualifiedNameProvider;
		this.deploymentModel = (FDModel) resource.getContents().get(0);
		this.imports = initializeImports();
	}

	@Override
	protected Iterable<IEObjectDescription> getAllLocalElements() {
		List<IEObjectDescription> result = new ArrayList<IEObjectDescription>();
		for (IResourceDescription description : importUriGlobalScopeProvider
				.getResourceDescriptions(resource, imports)
				.getAllResourceDescriptions()) {

			for (IEObjectDescription objDescription : description
					.getExportedObjects()) {
				EObject obj = objDescription.getEObjectOrProxy();
				if (obj instanceof FModel) {
					FModel model = (FModel) resolve(obj, resource);
					for (FTypeCollection collection : model
							.getTypeCollections()) {
						result.add(new EObjectDescription(
								(collection.getName() == null || collection
										.getName().isEmpty()) ? qualifiedNameProvider
										.getFullyQualifiedName(model)
										: qualifiedNameProvider
												.getFullyQualifiedName(collection),
								collection, null));
					}
				}
			}
		}
		return result;
	}

	/**
	 * Resolves an {@link EObject} if it is a proxy, otherwise returns the original object. 
	 * 
	 * @param proxy the {@link EObject} or proxy
	 * @param context the context to use for resolving
	 * @return the resolved (if resolving was possible) proxy or the original object
	 */
	private EObject resolve(EObject proxy, Resource context) {
		if (proxy.eIsProxy()) {
			return EcoreUtil.resolve(proxy, context);
		}
		return proxy;
	}

	/**
	 * Returns the imports from a deployment model as a {@link Set} of {@link URI}s. 
	 * 
	 * @return the set of uris
	 */
	private Set<URI> initializeImports() {
		Set<URI> uris = new HashSet<URI>();
		for (Import i : deploymentModel.getImports()) {
			uris.add(URI.createURI(i.getImportURI()));
		}
		return uris;
	}
}
