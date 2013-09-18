package org.franca.connectors.etrice.ui.properties;

import org.eclipse.core.runtime.QualifiedName;
import org.franca.connectors.etrice.ui.Activator;

public class ETriceConnectorProperties {

	private ETriceConnectorProperties() {
		// not intended to be instantiated.
	}

	public static final String ETRICE_GEN_MODEL_PATH_PROPERTY = "ETRICE_GEN_MODEL_PATH_PROPERTY";
	public static final String ETRICE_GEN_MODEL_PATH_DEFAULT = "model-gen";

	public static final QualifiedName ETRICE_GEN_MODEL_PATH_QN =
			new QualifiedName(Activator.PLUGIN_ID, ETRICE_GEN_MODEL_PATH_PROPERTY);
}
