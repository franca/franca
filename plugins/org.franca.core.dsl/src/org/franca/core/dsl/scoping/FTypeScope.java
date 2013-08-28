/*******************************************************************************
 * Copyright (c) 2013 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.core.dsl.scoping;

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.util.EcoreUtil;
import org.eclipse.emf.mwe2.language.scoping.QualifiedNameProvider;
import org.eclipse.xtext.EcoreUtil2;
import org.eclipse.xtext.naming.QualifiedName;
import org.eclipse.xtext.resource.EObjectDescription;
import org.eclipse.xtext.resource.IEObjectDescription;
import org.eclipse.xtext.resource.IResourceDescription;
import org.eclipse.xtext.scoping.IScope;
import org.eclipse.xtext.scoping.impl.AbstractScope;
import org.eclipse.xtext.scoping.impl.ImportUriGlobalScopeProvider;
import org.franca.core.franca.FModel;
import org.franca.core.franca.FType;
import org.franca.core.franca.FTypeCollection;
import org.franca.core.franca.Import;

import com.google.common.collect.ArrayListMultimap;
import com.google.common.collect.Multimap;

/**
 * Scope for the various types from an imported type collection. 
 * This scope is able to handle anonymous type collections too 
 * and takes care about the restrictions made on the imported 
 * package prefix. 
 * 
 * @author Tamas Szabo (itemis AG)
 *
 */
public class FTypeScope extends AbstractScope {

	private ImportUriGlobalScopeProvider importUriGlobalScopeProvider;
	private Resource resource;
	private QualifiedNameProvider qualifiedNameProvider;
	private FModel model;
	private Set<URI> imports;
	private Multimap<Resource, String> packagePrefixMap;
	
	protected FTypeScope(IScope parent, boolean ignoreCase,
			ImportUriGlobalScopeProvider importUriGlobalScopeProvider,
			Resource resource, QualifiedNameProvider qualifiedNameProvider) {
		super(parent, ignoreCase);
		this.importUriGlobalScopeProvider = importUriGlobalScopeProvider;
		this.resource = resource;
		this.qualifiedNameProvider = qualifiedNameProvider;
		this.model = (FModel) resource.getContents().get(0);
		this.imports = new HashSet<URI>();
		this.packagePrefixMap = ArrayListMultimap.create();
		this.processImports();
	}
	
	/**
	 * Needs to be overridden for the custom restrictions
	 */
	@Override
	public Iterable<IEObjectDescription> getAllElements() {
		return getAllLocalElements();
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
					for (FTypeCollection collection : model.getTypeCollections()) {
						Collection<String> prefixes = packagePrefixMap.get(collection.eResource());
						if (prefixes != null) {
							for (String prefix : prefixes) {
								for (FType type : collection.getTypes()) {
									QualifiedName fqn = qualifiedNameProvider.getFullyQualifiedName(type);
									String scopeName = getScopeName(prefix, fqn.toString());
									if (scopeName != null) {
										result.add(new EObjectDescription(QualifiedName.create(scopeName), type, null));
									}
								}							
							}
						}
					}
				}
			}
		}
		return result;
	}
	
	/**
	 * Returns the name required for scoping if the fully qualified name matches the given prefix. 
	 * <br/>
	 * (1) If the prefix is an exact import name (without star) then the fully qualified name should match exactly 
	 * and the simple name will be returned. 
	 * <br/>
	 * (2) If the prefix is a general import prefix then the method checks whether the fqn 
	 * matches that given prefix, and in that case returns the part of the fully qualified name 
	 * without the prefix.
	 * <br/> 
	 * (3) In every other case the method returns null to indicate that the 
	 * fully qualified name does not match the given prefix in any way. 
	 * In this case the object itself will not be included in the scope.
	 * 
	 * @param prefix the package import prefix
	 * @param fqn the fully qualified name of the object
	 * @return the scoping name or null
	 */
	private String getScopeName(String prefix, String fqn) {
		if (prefix.endsWith("*")) {
			prefix = prefix.substring(0, prefix.length()-1);
			return (fqn.startsWith(prefix)) ? fqn.substring(prefix.length()) : null;
		}
		else {
			//exact match is required for prefix without star
			if (prefix.equals(fqn)) {
				String[] tokens = fqn.split("\\.");
				return tokens[tokens.length-1];
			}
			else {
				return null;
			}
		}
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
	 * Indexes the imports appropriate for the FTypeScope
	 */
	private void processImports() {
		for (Import i : model.getImports()) {
			imports.add(URI.createURI(i.getImportURI()));
			
			Resource res = EcoreUtil2.getResource(resource, i.getImportURI().toString());
			if (res != null) {
				packagePrefixMap.put(res, i.getImportedNamespace());
			}
		}
	}
}
