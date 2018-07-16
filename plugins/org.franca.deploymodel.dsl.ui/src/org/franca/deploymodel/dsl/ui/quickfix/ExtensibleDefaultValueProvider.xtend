package org.franca.deploymodel.dsl.ui.quickfix

import org.franca.deploymodel.dsl.fDeploy.FDComplexValue
import org.franca.deploymodel.dsl.fDeploy.FDElement
import org.franca.deploymodel.dsl.fDeploy.FDRootElement
import org.franca.deploymodel.dsl.fDeploy.FDTypeRef

/**
 * A provider for deployment property default values which can be extended
 * by an extension point.</p>
 */
class ExtensibleDefaultValueProvider {

	/**
	 * Provide a default value for any of the property types in a deployment model.<p/>
	 * 
	 * The actual default value might be different for the various properties of a
	 * deployment model. Thus, the context is submitted as arguments to the method.</p>
	 */
	def static FDComplexValue generateDefaultValue(FDRootElement root, FDElement element, FDTypeRef typeRef) {
		// TODO: implement extension point mechanism here
		val fallbackProvider = new DefaultValueProvider
		fallbackProvider.generateDefaultValue(root, element, typeRef)
	}

}
