package org.franca.connectors.c_header;

import org.franca.core.framework.TransformationLogger;

import com.google.inject.AbstractModule;
import com.google.inject.Singleton;

public class CHeaderConnectorModule extends AbstractModule {

	@Override
	protected void configure() {
		bind(TransformationLogger.class).in(Singleton.class);
	}
}
