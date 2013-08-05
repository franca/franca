package org.franca.tools.contracts.testcasegen

import org.franca.tools.contracts.testcasegen.FrancaTestCase
import org.franca.core.franca.FMethod
import org.franca.core.franca.FArgument
import org.franca.core.franca.FTypeRef
import org.franca.core.franca.FBasicTypeId
import java.util.Set
import java.util.logging.Logger
import java.util.logging.Level

class FMethodTestCase extends FrancaTestCase {
	
	private FMethod method;
	
	def public getDefaultInArgumentsTestCases() {
		return method.inArgs.map[new Pair(it, defaultTestValues(it))]
	}
	
	def dispatch Set<? extends Object> defaultTestValues(FArgument argument) {
		defaultTestValues(argument.type)
	}
	
	def dispatch Set<? extends Object> defaultTestValues(FTypeRef ref) {
		val name = ref.predefined.literal
		switch (ref.predefined) {
			case FBasicTypeId::INT8:    #{-1, 0, 1}
			case FBasicTypeId::UINT8:   #{0, 1}
			case FBasicTypeId::INT16:   #{-1, 0, 1}
			case FBasicTypeId::UINT16:  #{0, 1}
			case FBasicTypeId::INT32:   #{-1, 0, 1}
			case FBasicTypeId::UINT32:  #{0, 1}
			case FBasicTypeId::INT64:   #{-1l, 0l, 1l}
			case FBasicTypeId::UINT64:  #{0l, 1l}
			case FBasicTypeId::BOOLEAN: #{true, false}
			case FBasicTypeId::STRING:  #{"", "test", "TEST", "test with\twhitespace\nchars"}
			case FBasicTypeId::FLOAT:   #{-1f, 0f, 1f}
			case FBasicTypeId::DOUBLE:  #{-1d, 0d, 1d}
			default: {
				Logger::anonymousLogger.log(Level::SEVERE, "Unknown primitive type: '" + name + "'")
				throw new IllegalArgumentException("Unknown primitive type: '" + name + "'\nMaybe the type even was not a primitive one, but a user defined type!")
			}  
		}
	}
}