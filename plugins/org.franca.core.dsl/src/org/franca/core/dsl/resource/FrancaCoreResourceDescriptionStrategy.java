package org.franca.core.dsl.resource;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.xtext.resource.IEObjectDescription;
import org.eclipse.xtext.resource.impl.DefaultResourceDescriptionStrategy;
import org.eclipse.xtext.util.IAcceptor;

import com.google.inject.Inject;

public class FrancaCoreResourceDescriptionStrategy extends DefaultResourceDescriptionStrategy {

	@Inject 
	protected FrancaCoreEObjectDescriptions eObjectDescriptionFactory;
	
	public boolean createEObjectDescriptions(EObject eObject, IAcceptor<IEObjectDescription> acceptor) {
		if (getQualifiedNameProvider() == null){
			return false;
		}
		IEObjectDescription desc = eObjectDescriptionFactory.create(eObject);
		if(desc!=null){
			acceptor.accept(desc);
		}
		return true;
	}
	
}
