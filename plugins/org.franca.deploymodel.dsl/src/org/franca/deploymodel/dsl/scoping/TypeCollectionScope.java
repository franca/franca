package org.franca.deploymodel.dsl.scoping;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.util.EcoreUtil;
import org.eclipse.emf.mwe2.language.scoping.QualifiedNameProvider;
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

public class TypeCollectionScope extends AbstractScope {

	private ImportUriGlobalScopeProvider importUriGlobalScopeProvider;
	private Resource resource;
	private QualifiedNameProvider qualifiedNameProvider;
	private FDModel deploymentModel;
	private Set<URI> imports;

	protected TypeCollectionScope(IScope parent, boolean ignoreCase,
			ImportUriGlobalScopeProvider importUriGlobalScopeProvider,
			Resource resource, QualifiedNameProvider qualifiedNameProvider) {
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

	private EObject resolve(EObject proxy, Resource context) {
		if (proxy.eIsProxy()) {
			return EcoreUtil.resolve(proxy, context);
		}
		return proxy;
	}

	private Set<URI> initializeImports() {
		Set<URI> uris = new HashSet<URI>();
		for (Import i : deploymentModel.getImports()) {
			uris.add(URI.createURI(i.getImportURI()));
		}
		return uris;
	}
}
