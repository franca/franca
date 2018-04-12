package org.franca.core.dsl.tests.util;

import org.eclipse.xtext.testing.IInjectorProvider;
import org.eclipse.xtext.testing.IRegistryConfigurator;
import org.eclipse.xtext.testing.XtextRunner;
import org.junit.runners.model.FrameworkMethod;
import org.junit.runners.model.InitializationError;
import org.junit.runners.model.Statement;

/**
 * This is a clone of class XtextRunner2 from https://github.com/itemis/xtext-testing.</p>
 * 
 * TODO: Replace this as soon as xtext-testing uses all imports from org.eclipse.xtext.testing.
 */
public class XtextRunner2_Franca extends XtextRunner {

    public XtextRunner2_Franca(final Class<?> klass) throws InitializationError {
        super(klass);
    }

    @Override
    protected Statement methodBlock(final FrameworkMethod method) {
        final IInjectorProvider injectorProvider = getOrCreateInjectorProvider();
        if (injectorProvider instanceof IRegistryConfigurator) {

            final Statement methodBlock = super.methodBlock(method);

            final IRegistryConfigurator registryConfigurator = (IRegistryConfigurator) injectorProvider;
            registryConfigurator.setupRegistry();

            // ATU: move this line up because super.methodBlock(method) will
            // call
            // <DSL>InjectorProvider.getInjector(),
            // and because <DSL>InjectorProvider.setupRegistry() should be
            // called afterwards.
            //
            // final Statement methodBlock = super.methodBlock(method);

            return new Statement() {
                @Override
                public void evaluate() throws Throwable {
                    try {
                        methodBlock.evaluate();
                    } finally {
                        registryConfigurator.restoreRegistry();
                    }
                }
            };
        } else {
            return super.methodBlock(method);
        }
    }
}
