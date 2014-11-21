package org.franca.core.utils

import java.math.BigDecimal

class JavaTypeSystemHelpers {
	
	def static public boolean isFloatingNumber(Object o) {
	    o instanceof Number && ! o.isIntegerNumber
	}
	
	def static public boolean isIntegerNumber(Object o) {
        o instanceof Number &&
        !(o instanceof Double) &&
//        !(o instanceof MutableDouble) &&
        !(o instanceof Float) &&
//        !(o instanceof MutableFloat) &&
//        !(o instanceof Fraction) &&
//        !(o instanceof AtomicDouble) &&
        !(o instanceof BigDecimal)
	}
		
}