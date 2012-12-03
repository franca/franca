package org.franca.deploymodel.dsl;

import org.eclipse.emf.codegen.ecore.genmodel.GenModelPackage;
import org.eclipse.emf.ecore.EPackage;
import org.eclipse.xtext.util.Modules2;
import org.franca.core.dsl.FrancaIDLRuntimeModule;

import com.google.inject.Guice;
import com.google.inject.Injector;

public class FDeployTestsStandaloneSetup extends FDeployStandaloneSetup {
    @Override
    public Injector createInjector() {
        return Guice.createInjector(Modules2.mixin(
        		new FrancaIDLRuntimeModule(),
        		new FDeployRuntimeModule(),
        		new FDeployTestsModule()));
    }

    @Override
    public Injector createInjectorAndDoEMFRegistration() {
        EPackage.Registry.INSTANCE.put(GenModelPackage.eNS_URI, GenModelPackage.eINSTANCE);
        return super.createInjectorAndDoEMFRegistration();
    }
}
