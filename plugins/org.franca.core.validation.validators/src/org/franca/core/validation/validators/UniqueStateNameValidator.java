package org.franca.core.validation.validators;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.List;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.xtext.diagnostics.Severity;
import org.eclipse.xtext.resource.DefaultLocationInFileProvider;
import org.eclipse.xtext.resource.ILocationInFileProvider;
import org.franca.core.franca.FContract;
import org.franca.core.franca.FInterface;
import org.franca.core.franca.FModel;
import org.franca.core.franca.FState;
import org.franca.core.franca.FrancaPackage;
import org.franca.core.validation.runtime.IFrancaValidator;
import org.franca.core.validation.runtime.Issue;

import com.google.common.collect.ArrayListMultimap;
import com.google.common.collect.Multimap;

public class UniqueStateNameValidator implements IFrancaValidator {

	ILocationInFileProvider locationProvider;

	public UniqueStateNameValidator() {
		locationProvider = new DefaultLocationInFileProvider();
	}

	@Override
	public Collection<Issue> validateModel(Resource resource) {
		FModel model = null;
		for (EObject obj : resource.getContents()) {
			if (obj instanceof FModel) {
				model = (FModel) obj;
			}
		}

		if (model != null) {
			List<Issue> issues = new ArrayList<Issue>();
			for (FInterface _interface : model.getInterfaces()) {
				FContract contract = _interface.getContract();
				Multimap<String, FState> stateNameMap = ArrayListMultimap.create();

				for (FState state : contract.getStateGraph().getStates()) {
					stateNameMap.put(state.getName(), state);
				}
				
				for (String name : stateNameMap.keySet()) {
					Collection<FState> states = stateNameMap.get(name);
					if (states.size() > 1) {
						for (FState state : states) {
							issues.add(new Issue("The name of the state is not unique!", state, FrancaPackage.Literals.FMODEL_ELEMENT__NAME, Severity.ERROR));
						}
					}
				}
			}

			return issues;
		}
		return Collections.emptyList();
	}

}
