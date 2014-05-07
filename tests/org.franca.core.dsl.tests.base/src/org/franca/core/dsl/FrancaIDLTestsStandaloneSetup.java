package org.franca.core.dsl;

import org.eclipse.xtext.util.Modules2;

import com.google.inject.Guice;
import com.google.inject.Injector;

public class FrancaIDLTestsStandaloneSetup extends FrancaIDLStandaloneSetup {
    @Override
    public Injector createInjector() {
        return Guice.createInjector(Modules2.mixin(new FrancaIDLRuntimeModule(), new FrancaIDLTestsModule()));
    }
}
