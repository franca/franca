package org.franca.connectors.webidl;

import org.franca.core.framework.TransformationLogger;

import com.google.inject.AbstractModule;
import com.google.inject.Singleton;

public class WebIDLConnectorModule extends AbstractModule {

	@Override
	protected void configure() {
		bind(TransformationLogger.class).in(Singleton.class);
	}
}

