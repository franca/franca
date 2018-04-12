package org.franca.core.dsl

import org.eclipse.emf.ecore.EPackage
import com.google.inject.Injector

/** 
 * Initialization support for running Xtext languages 
 * without equinox extension registry
 */
class FrancaIDLStandaloneSetup extends FrancaIDLStandaloneSetupGenerated {
	def static void doSetup() {
		new FrancaIDLStandaloneSetup().createInjectorAndDoEMFRegistration()
	}

	override Injector createInjectorAndDoEMFRegistration() {
		// the FrancaPackage might not be registered because the EMF model is not part of the DSL
		if (!EPackage.Registry.INSTANCE.containsKey("http://core.franca.org")) {
			EPackage.Registry.INSTANCE.put("http://core.franca.org", org.franca.core.franca.FrancaPackage.eINSTANCE)
		}
		return super.createInjectorAndDoEMFRegistration()
	}
}
