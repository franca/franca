package org.franca.core.dsl.tests

import org.eclipse.xtext.junit4.InjectWith
import org.eclipselabs.xtext.utils.unittesting.XtextRunner2
import org.franca.core.dsl.FrancaIDLTestsInjectorProvider
import org.junit.Test
import org.junit.runner.RunWith

import static org.junit.Assert.*

@RunWith(typeof(XtextRunner2))
@InjectWith(typeof(FrancaIDLTestsInjectorProvider))
class InterfaceValidationTests extends ValidationTestBase {

	@Test
	def validateMethodArgsInOutUnique() {
		val text = '''
			package a.b.c
			interface Sample {
				method MyMethod {
					in {
						UInt8 a
						Int16 b
						String c
					}
					out {
						String a
						Int16 b
					}
				}
			}
		'''
		
		assertEquals('''
			5:Duplicate argument name 'a' used for in and out
			6:Duplicate argument name 'b' used for in and out
			10:Duplicate argument name 'a' used for in and out
			11:Duplicate argument name 'b' used for in and out
		'''.toString, text.getIssues)
	}

	@Test
	def validateInheritedMethodNameUnique() {
		val text = '''
			package a.b.c
			interface Base {
				method MyMethod { }
			}
			interface Derived extends Base {
				method MyMethod { }
			}
		'''
		
		assertEquals('''
			3:Name conflict for inherited method 'MyMethod'
			6:Name conflict for inherited method 'MyMethod'
		'''.toString, text.getIssues)
	}

	@Test
	def validateInheritedBroadcastNameUnique() {
		val text = '''
			package a.b.c
			interface Base {
				broadcast MyBroadcast { }
			}
			interface Derived extends Base {
				broadcast MyBroadcast { }
			}
		'''
		
		assertEquals('''
			3:Name conflict for inherited broadcast 'MyBroadcast'
			6:Name conflict for inherited broadcast 'MyBroadcast'
		'''.toString, text.getIssues)
	}
}

