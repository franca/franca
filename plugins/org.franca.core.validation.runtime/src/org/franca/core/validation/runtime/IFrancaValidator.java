package org.franca.core.validation.runtime;

import java.util.Collection;

import org.eclipse.xtext.validation.Issue;
import org.franca.core.franca.FModel;

public interface IFrancaValidator {

	public Collection<Issue> validateModel(FModel model);
	
}
