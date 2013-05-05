package org.franca.core.dsl.validation;

import java.util.Collection;
import java.util.HashSet;

import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IConfigurationElement;
import org.eclipse.core.runtime.IExtension;
import org.eclipse.core.runtime.IExtensionPoint;
import org.eclipse.core.runtime.IExtensionRegistry;
import org.eclipse.core.runtime.Platform;
import org.franca.core.validation.runtime.IFrancaValidator;

public class ValidatorRegistry {

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
}
