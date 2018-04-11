/*******************************************************************************
 * Copyright (c) 2018 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.core.dsl.tests.formatting

import org.eclipse.xtext.testing.InjectWith
import org.franca.core.dsl.FrancaIDLTestsInjectorProvider
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.junit.Test
import org.junit.runner.RunWith

import static org.junit.Assert.*

@RunWith(typeof(XtextRunner2_Franca))
@InjectWith(typeof(FrancaIDLTestsInjectorProvider))
class FormatContractsTests extends FormatterTestBase {

	@Test
	def void test1() {
		val input = '''
			method m1 { }
			contract  {PSM   
			{  initial   S1   state  S1 {}}}
		'''
		
		val expected = '''
			method m1 { }
			
			contract {
				PSM {
					initial S1
					state S1 {
					}
				}
			}
		'''
		
		assertEquals(expected.wrap.chompEmpty, input.wrap.format)
	}

	@Test
	def void test2() {
		val input = '''
			method m1 { }
			contract  {PSM   
			{  initial   S1   state  S1 {
			on   call   m1   ->    S2
			}
			state  S2 {}
			}}}
		'''
		
		val expected = '''
			method m1 { }
			
			contract {
				PSM {
					initial S1
					state S1 {
						on call m1 -> S2
					}
					state S2 {
					}
				}
			}
		'''
		
		assertEquals(expected.wrap.chompEmpty, input.wrap.format)
	}

	@Test
	def void test3() {
		val input = '''
			method m1 { }method m2 { }
			contract  {PSM   
			   {  initial   S1   state  S1 {
			on   call   m1   ->    S2
			on   call   m2   ->    S1
			on   respond   m2->    S2
			    }
			state  S2 {on   respond   m1->    S1}
			  }}}
		'''
		
		val expected = '''
			method m1 { }
			
			method m2 { }
			
			contract {
				PSM {
					initial S1
					state S1 {
						on call m1 -> S2
						on call m2 -> S1
						on respond m2 -> S2
					}
					state S2 {
						on respond m1 -> S1
					}
				}
			}
		'''
		
		assertEquals(expected.wrap.chompEmpty, input.wrap.format)
	}


	def private String wrap(String s) '''
		package a.b
		
		interface I1 {
			«s»
		}
	'''

}
