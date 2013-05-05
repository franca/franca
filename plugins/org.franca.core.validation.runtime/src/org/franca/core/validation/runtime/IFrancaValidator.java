package org.franca.core.validation.runtime;

import java.util.Collection;

import org.eclipse.emf.ecore.resource.Resource;

public interface IFrancaValidator {

	public Collection<Issue> validateModel(Resource resource);
	
}
