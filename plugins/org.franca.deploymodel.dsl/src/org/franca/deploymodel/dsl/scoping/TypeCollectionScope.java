package org.franca.deploymodel.dsl.scoping;

import java.util.ArrayList;
import java.util.List;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.util.EcoreUtil;
import org.eclipse.xtext.naming.QualifiedName;
import org.eclipse.xtext.resource.EObjectDescription;
import org.eclipse.xtext.resource.IEObjectDescription;
import org.eclipse.xtext.resource.IResourceDescription;
import org.eclipse.xtext.resource.IResourceDescriptions;
import org.eclipse.xtext.scoping.IScope;
import org.eclipse.xtext.scoping.impl.AbstractScope;
import org.franca.core.franca.FModel;
import org.franca.core.franca.FTypeCollection;

public class TypeCollectionScope extends AbstractScope {

	private IResourceDescriptions descriptions;
	private Resource resource;

	protected TypeCollectionScope(IScope parent, boolean ignoreCase,
			IResourceDescriptions descriptions, Resource resource) {
		super(parent, ignoreCase);
		this.descriptions = descriptions;
		this.resource = resource;
	}

	@Override
	protected Iterable<IEObjectDescription> getAllLocalElements() {
		List<IEObjectDescription> result = new ArrayList<IEObjectDescription>();

		for (IResourceDescription description : descriptions
				.getAllResourceDescriptions()) {
			for (IEObjectDescription objDescription : description
					.getExportedObjects()) {
				EObject obj = objDescription.getEObjectOrProxy();
				if (obj instanceof FModel) {
					FModel model = (FModel) resolve(obj, resource);
					for (FTypeCollection collection : model
							.getTypeCollections()) {
						String qualifiedName = (collection.getName() == null || collection
								.getName().isEmpty()) ? model.getName() : model
								.getName() + "." + collection.getName();
						result.add(new EObjectDescription(QualifiedName
								.create(qualifiedName.split("\\.")), collection, null));
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
}
