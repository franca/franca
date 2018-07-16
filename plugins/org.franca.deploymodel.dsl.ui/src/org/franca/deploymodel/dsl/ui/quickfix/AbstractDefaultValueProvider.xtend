package org.franca.deploymodel.dsl.ui.quickfix

import org.eclipse.emf.ecore.EObject
import org.franca.core.franca.FInterface
import org.franca.deploymodel.dsl.fDeploy.FDComplexValue
import org.franca.deploymodel.dsl.fDeploy.FDValue
import org.franca.deploymodel.dsl.fDeploy.FDeployFactory

abstract class AbstractDefaultValueProvider implements IDefaultValueProvider {
	
	/**
	 * Helper method which wraps a value as complex value</p>
	 * 
	 * @param value which has to be wrapped
	 * @return complex value which just contains the single input value
	 */
	def protected FDComplexValue createSingle(FDValue item) {
		val ret = FDeployFactory.eINSTANCE.createFDComplexValue
		ret.single = item
		ret
	}
	
	/**
	 * Helper method which creates a grouped value from a set of items.</p>
	 * 
	 * @param items one or more values which will be members of the grouip
	 * @return complex value which is actually a group of values
	 */
	def protected FDComplexValue createGroup(FDValue... items) {
		val ret = FDeployFactory.eINSTANCE.createFDComplexValue
		val arrayVal = FDeployFactory.eINSTANCE.createFDValueArray
		for(item : items) {
			arrayVal.values.add(item)
		}
		ret.array = arrayVal	
		ret		
	}
	
	/**
	 * Helper method which creates a value of type boolean.</p>
	 */
	def protected FDValue createBooleanValue(boolean v) {
		FDeployFactory.eINSTANCE.createFDBoolean => [ value = if (v) "true" else "false" ]
	}

	/**
	 * Helper method which creates a value of type boolean.</p>
	 */
	def protected FDValue createIntegerValue(int v) {
		FDeployFactory.eINSTANCE.createFDInteger => [ value = v ]
	}

	/**
	 * Helper method which creates a value of type boolean.</p>
	 */
	def protected FDValue createStringValue(String v) {
		FDeployFactory.eINSTANCE.createFDString => [ value = v ]
	}
	
	/**
	 * Helper method which creates a value of type InterfaceRef.</p>
	 */
	def protected FDValue createInterfaceRefValue(FInterface v) {
		FDeployFactory.eINSTANCE.createFDInterfaceRef => [ value = v ]
	}
	
	/**
	 * Helper method which creates a value of type EObject.</p>
	 */
	def protected FDValue createEObjectValue(EObject v) {
		FDeployFactory.eINSTANCE.createFDGeneric => [ value = v ]
	}
	
}
