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
class FormatMethodsTests extends FormatterTestBase {

	@Test
	def void test0() {
		val input = '''method    m1    {} '''
		
		val expected = '''
			method m1 { }
		'''
		
		assertEquals(expected.wrap, input.wrap.format)
	}

	@Test
	def void test1() {
		val input = '''method m1 { in {} } '''
		
		val expected = '''
			method m1 { in { } }
		'''
		
		assertEquals(expected.wrap, input.wrap.format)
	}

	@Test
	def void test2() {
		val input = '''method m1   fireAndForget  { in {} } '''
		
		val expected = '''
			method m1 fireAndForget { in { } }
		'''
		
		assertEquals(expected.wrap, input.wrap.format)
	}

	@Test
	def void test3() {
		val input = '''method m1  {  in  {  String  s1  } out   {  String   s2  Boolean s3 } }'''
		
		val expected = '''
			method m1 {
				in {
					String s1
				}
				out {
					String s2
					Boolean s3
				}
			}
		'''
		
		assertEquals(expected.wrap, input.wrap.format)
	}

	@Test
	def void test4() {
		val m1 = '''method m1 { in { String s1 } } '''
		val m2 = '''method   m2 { out { Boolean  b } } '''
		val input = '''«m1»«m2»'''
		
		val expected = '''
			method m1 {
				in {
					String s1
				}
			}

			method m2 {
				out {
					Boolean b
				}
			}
		'''
		
		assertEquals(expected.wrap.chompEmpty, input.wrap.format)
	}

	@Test
	def void test5() {
		val input = '''
			method m1  { in {} error { A B C } } 
		'''
		
		val expected = '''
			method m1 {
				in {
				}
				error {
					A
					B
					C
				}
			}
		'''
		
		assertEquals(expected.wrap, input.wrap.format)
	}

	@Test
	def void test6() {
		val input = '''
			enumeration ERR { A B C }
			method m1  { in {}   error   ERR } 
		'''
		
		val expected = '''
			enumeration ERR {
				A
				B
				C
			}
			
			method m1 {
				in {
				}
				error ERR
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
