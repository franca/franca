package org.franca.core.validation.validators;

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import org.eclipse.xtext.diagnostics.Severity;
import org.eclipse.xtext.resource.DefaultLocationInFileProvider;
import org.eclipse.xtext.resource.ILocationInFileProvider;
import org.eclipse.xtext.util.TextRegionWithLineInformation;
import org.eclipse.xtext.validation.CheckType;
import org.eclipse.xtext.validation.Issue;
import org.franca.core.franca.FContract;
import org.franca.core.franca.FInterface;
import org.franca.core.franca.FModel;
import org.franca.core.franca.FState;
import org.franca.core.validation.runtime.IFrancaValidator;

public class UniqueStateNameValidator implements IFrancaValidator {

	ILocationInFileProvider locationProvider;
	
	public UniqueStateNameValidator() {
		locationProvider = new DefaultLocationInFileProvider();
	}
	
	@Override
	public Collection<Issue> validateModel(FModel model) {
		List<Issue> issues = new ArrayList<Issue>();
		for (FInterface _interface : model.getInterfaces()) {
			FContract contract = _interface.getContract();
			Set<String> names = new HashSet<String>();
			boolean uniqueAll = true;
			
			for (FState state : contract.getStateGraph().getStates()) {
				if (names.contains(state.getName())) {
					uniqueAll = false;
					break;
				}
				names.add(state.getName());
			}
			
			if (!uniqueAll) {
				TextRegionWithLineInformation textRegion = (TextRegionWithLineInformation) locationProvider.getFullTextRegion(contract);
				Issue.IssueImpl issue = new Issue.IssueImpl();
				issue.setUriToProblem(model.eResource().getURI());
				issue.setMessage("The names of the states must be unique in the "+_interface.getName()+" contract!");
				issue.setSyntaxError(false);
				issue.setType(CheckType.EXPENSIVE);
				issue.setSeverity(Severity.ERROR);
				issue.setOffset(textRegion.getOffset());
				issue.setLength(textRegion.getLength());
				issue.setLineNumber(textRegion.getLineNumber());
				issues.add(issue);
			}
		}
		
		return issues;
	}

}
