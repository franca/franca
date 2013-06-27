package org.franca.deploymodel.dsl.scoping;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.xtext.resource.IEObjectDescription;
import org.franca.core.franca.impl.FTypeCollectionImpl;

import com.google.common.base.Predicate;

public class TypeCollectionPredicate implements Predicate<IEObjectDescription> {

	@Override
	public boolean apply(IEObjectDescription input) {
		EObject typeCollection = input.getEObjectOrProxy();
		return typeCollection.getClass().equals(FTypeCollectionImpl.class);
	}

}
