package org.franca.core.validation.runtime;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;

import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IConfigurationElement;
import org.eclipse.core.runtime.IExtension;
import org.eclipse.core.runtime.IExtensionPoint;
import org.eclipse.core.runtime.IExtensionRegistry;
import org.eclipse.core.runtime.Platform;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.xtext.util.CancelIndicator;
import org.eclipse.xtext.validation.CheckMode;
import org.eclipse.xtext.validation.IResourceValidator;
import org.eclipse.xtext.validation.Issue;
import org.franca.core.franca.FModel;

public class FrancaValidator implements IResourceValidator {

	private static final String EXTENSION_POINT_ID = "org.franca.core.validation.runtime.francaValidator";
	private static Collection<IFrancaValidator> liveValidators = null;
	private static Collection<IFrancaValidator> batchValidators = null;

	public static Collection<IFrancaValidator> getLiveValidators() {
		if (liveValidators == null) {
			initializeValidators();
		}
		return liveValidators;
	}

	public static Collection<IFrancaValidator> getBatchValidators() {
		if (batchValidators == null) {
			initializeValidators();
		}
		return batchValidators;
	}

	private static void initializeValidators() {
		liveValidators = new HashSet<IFrancaValidator>();
		batchValidators = new HashSet<IFrancaValidator>();
		
		IExtensionRegistry reg = Platform.getExtensionRegistry();
		IExtensionPoint ep = reg.getExtensionPoint(EXTENSION_POINT_ID);

		for (IExtension extension : ep.getExtensions()) {
			for (IConfigurationElement ce : extension
					.getConfigurationElements()) {
				if (ce.getName().equals("validator")) {
					try {
						Object o = ce.createExecutableExtension("class");
						if (o instanceof IFrancaValidator) {
							boolean isLive = Boolean.parseBoolean(ce
									.getAttribute("isLive"));
							if (isLive) {
								liveValidators.add((IFrancaValidator) o);
							} else {
								batchValidators.add((IFrancaValidator) o);
							}
						}
					} catch (CoreException e) {
						e.printStackTrace();
					}
				}
			}
		}
	}

	@Override
	public List<Issue> validate(Resource resource, CheckMode mode,
			CancelIndicator indicator) {
		
		FModel model = null;
		for (EObject obj : resource.getContents()) {
			if (obj instanceof FModel) {
				model = (FModel) obj;
				break;
			}
		}
		if (model != null) {
			List<Issue> issues = new ArrayList<Issue>();
			for (IFrancaValidator validator : (mode == CheckMode.EXPENSIVE_ONLY ? getBatchValidators() : getLiveValidators())) {
				Collection<Issue> res = validator.validateModel(model);
				if (res != null) {
					issues.addAll(validator.validateModel(model));
				}
			}
			return issues;
		}
		return Collections.emptyList();
	}

}
