package org.franca.connectors.dbus.util

import org.franca.core.franca.FEnumerationType
import org.franca.core.franca.FTypeRef

import static extension org.franca.core.framework.FrancaHelpers.*

class DBusLogic {
	/**
	 * Check if a proper map key type is referenced.
	 */
	def static isProperDictKey(FTypeRef src) {
		// enumeration types will be mapped to 'i' (or another integer type), thus can be used as dict key 
		src.actualPredefined !== null || (src.actualDerived instanceof FEnumerationType)
	}
}
