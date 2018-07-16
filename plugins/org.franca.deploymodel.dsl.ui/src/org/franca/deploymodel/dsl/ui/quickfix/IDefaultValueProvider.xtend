package org.franca.deploymodel.dsl.ui.quickfix

import org.franca.deploymodel.dsl.fDeploy.FDComplexValue
import org.franca.deploymodel.dsl.fDeploy.FDElement
import org.franca.deploymodel.dsl.fDeploy.FDRootElement
import org.franca.deploymodel.dsl.fDeploy.FDTypeRef

interface IDefaultValueProvider {
	
	/**
	 * Provide a default value for each of the property types in a deployment model.<p/>
	 * 
	 * If a default value cannot be provided, just return null. The Franca implementation
	 * will then choose a fallback default value, if possble.</p>
	 * 
	 * @param root the root element of the current deployment specification
	 * @param element the deployment element for which a default value should be provided
	 * @param typeRef the required type for the default value
	 * 
	 * @return the computed default value or null (if no default value can be provided) 
	 */
	def FDComplexValue generateDefaultValue(FDRootElement root, FDElement element, FDTypeRef typeRef)

}
