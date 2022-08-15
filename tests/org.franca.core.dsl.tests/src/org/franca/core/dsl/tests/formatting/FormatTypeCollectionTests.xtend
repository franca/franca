/*******************************************************************************
 * Copyright (c) 2018 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.core.dsl.tests.formatting

import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.XtextRunner
import org.franca.core.dsl.FrancaIDLTestsInjectorProvider
import org.junit.Test
import org.junit.runner.RunWith

import static org.junit.Assert.*

@RunWith(typeof(XtextRunner))
@InjectWith(typeof(FrancaIDLTestsInjectorProvider))
class FormatTypeCollectionTests extends FormatterTestBase {

	@Test
	def void test1() {
		val input = '''package a.b typeCollection TC1 { version { major 1 minor 2 }}'''
		
		val expected = '''
			package a.b
			
			typeCollection TC1 {
				version {
					major 1
					minor 2
				}
			}
		'''
		
		assertEquals(expected, input.format)
	}

	@Test
	def void test2() {
		val input = '''
			package a.b typeCollection TC1 { version { major 1 minor 2 }
			const  UInt16  c1=7}
		 '''
		
		val expected = '''
			package a.b
			
			typeCollection TC1 {
				version {
					major 1
					minor 2
				}
			
				const UInt16 c1 = 7
			}
		'''
		
		assertEquals(expected, input.format)
	}

	@Test
	def void test3() {
		val input = '''
			package a.b typeCollection TC1 {array   t1  of   UInt16}
		 '''
		
		val expected = '''
			package a.b
			
			typeCollection TC1 {
				array t1 of UInt16
			}
		'''
		
		assertEquals(expected, input.format)
	}

	@Test
	def void test4() {
		val input = '''
			package a.b typeCollection TC1 { version { major 1 minor 2 }
			array   t1  of   UInt16}
		 '''
		
		val expected = '''
			package a.b
			
			typeCollection TC1 {
				version {
					major 1
					minor 2
				}
			
				array t1 of UInt16
			}
		'''
		
		assertEquals(expected, input.format)
	}

}
