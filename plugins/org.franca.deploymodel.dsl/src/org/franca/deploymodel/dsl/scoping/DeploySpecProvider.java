/*******************************************************************************
 * Copyright (c) 2013 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.deploymodel.dsl.scoping;

import java.util.Collection;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;

import org.eclipse.core.runtime.IConfigurationElement;
import org.eclipse.core.runtime.IExtension;
import org.eclipse.core.runtime.IExtensionPoint;
import org.eclipse.core.runtime.IExtensionRegistry;
import org.eclipse.core.runtime.IRegistryEventListener;
import org.eclipse.core.runtime.Platform;
import org.eclipse.emf.common.util.TreeIterator;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;
import org.eclipse.xtext.naming.IQualifiedNameProvider;
import org.eclipse.xtext.naming.QualifiedName;
import org.franca.deploymodel.dsl.fDeploy.FDSpecification;

import com.google.inject.Inject;
import com.google.inject.Singleton;

/** Util class providing convenience regarding the <code>deploySpecProvider</code> Extension Point. */
@Singleton
public class DeploySpecProvider {

	public static final String DEPLOY_SPEC_PROVIDER_EXTENSION = "org.franca.deploymodel.dsl.deploySpecProvider";
	public static final String DEPLOY_SPEC_PROVIDER_ATTRIB_RESOURCE = "resource";
	public static final String DEPLOY_SPEC_PROVIDER_ATTRIB_ALIAS = "alias";
	public static final String DEPLOY_SPEC_PROVIDER_ATTRIB_FDSPECIFICATION = "FDSpecification";

	protected Map<String, DeploySpecEntry> deploySpecEntries = new HashMap<String, DeploySpecEntry>();

	@Inject
	IQualifiedNameProvider qnProvider;

	/** 
	 * Represents a contribution to extension org.franca.deploymodel.dsl.deploySpecProvider 
	 * (i.e. the data read from the contributing plugin.xml by means of <code>Platform.getExtensionRegistry()</code>).
	 * Provides some convenience to process these data.
	 */
	public class DeploySpecEntry {
		public String alias;
		public String resourceId;
		public String fdSpec;
		public String contributorName;
		protected Resource lazyResource;
		protected FDSpecification lazyFDSpec;

		public DeploySpecEntry(String contributorName, String alias, String resourceId, String fdSpec) {
			this.alias = alias;
			this.resourceId = resourceId;
			this.fdSpec = fdSpec;
			this.contributorName = contributorName;

		}

		@Override
		public String toString() {
			return "DeploySpecEntry[" + contributorName + "','" + alias + "','" + fdSpec + "','" + resourceId + "']";
		}

		protected FDSpecification getFDSpecification() {
			if (lazyFDSpec == null) {
				Resource resource = getResource();
				if (resource != null) {
					TreeIterator<EObject> allIt = resource.getAllContents();
					while (allIt.hasNext()) {
						EObject eObject = allIt.next();
						if (eObject instanceof FDSpecification) {
							QualifiedName fqn = qnProvider.getFullyQualifiedName(eObject);
							if (fqn != null && fqn.toString().equals(fdSpec)) {
								lazyFDSpec = (FDSpecification) eObject;
								break;
							}
						}
					}
				}
			}
			return lazyFDSpec;
		}

		protected Resource getResource() {
			if (lazyResource == null) {
				URI uri = URI.createPlatformPluginURI(contributorName + "/" + resourceId, true);
				lazyResource = new ResourceSetImpl().getResource(uri, true);
			}
			return lazyResource;
		}
	}

	protected DeploySpecEntry putDeploySpecEntry(String contributorName, String alias, String resource, String fdSpec) {
		return deploySpecEntries.put(alias, new DeploySpecEntry(contributorName, alias, resource, fdSpec));
	}

	IRegistryEventListener registryEventListener = null;

	public Set<String> getAliases() {
		if (deploySpecEntries.isEmpty()) {
			readDeploySpecEntries();
		}
		return deploySpecEntries.keySet();
	}

	public Collection<DeploySpecEntry> getEntries() {
		if (deploySpecEntries.isEmpty()) {
			readDeploySpecEntries();
		}
		return deploySpecEntries.values();
	}

	public DeploySpecEntry getEntry(String alias) {
		if (deploySpecEntries.isEmpty()) {
			readDeploySpecEntries();
		}
		return deploySpecEntries.get(alias);
	}

	public void readDeploySpecEntries() {
		IExtensionRegistry extensionRegistry = Platform.getExtensionRegistry();
		IConfigurationElement[] extensions = extensionRegistry.getConfigurationElementsFor(DEPLOY_SPEC_PROVIDER_EXTENSION);
		for (IConfigurationElement e : extensions) {
			putDeploySpecEntry(e.getContributor().getName(), e.getAttribute(DEPLOY_SPEC_PROVIDER_ATTRIB_ALIAS),
					e.getAttribute(DEPLOY_SPEC_PROVIDER_ATTRIB_RESOURCE), e.getAttribute(DEPLOY_SPEC_PROVIDER_ATTRIB_FDSPECIFICATION));
		}
		if (registryEventListener == null) {
			registryEventListener = new IRegistryEventListener() {
				@Override
				public void removed(IExtensionPoint[] eps) {
					deploySpecEntries.clear();
				}

				@Override
				public void removed(IExtension[] es) {
					deploySpecEntries.clear();
				}

				@Override
				public void added(IExtensionPoint[] eps) {
					deploySpecEntries.clear();
				}

				@Override
				public void added(IExtension[] es) {
					deploySpecEntries.clear();
				}
			};
			extensionRegistry.addListener(registryEventListener, DEPLOY_SPEC_PROVIDER_EXTENSION);
		}
	}

}
