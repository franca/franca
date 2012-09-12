package org.franca.deploymodel.dsl.validation

import org.franca.deploymodel.dsl.fDeploy.FDRootElement
import static org.franca.deploymodel.dsl.fDeploy.FDeployPackage$Literals.*

import static extension org.franca.core.utils.CycleChecker.*

class FDeployValidator {
	
	ValidationMessageReporter reporter
	
	new (ValidationMessageReporter reporter) {
		this.reporter = reporter	
	}


	// *****************************************************************************
	
	def checkRootElement (FDRootElement it) {
		// ensure that use-relation is non-cyclic 
		val path = isReferenced[e | e.use] 
		if (path!=null) {
			val idx = use.indexOf(path.get(0))
			reporter.reportError("Cyclic use-relation in element '" + name + "'",
				it, FD_ROOT_ELEMENT__USE, idx)
		}
	}
}