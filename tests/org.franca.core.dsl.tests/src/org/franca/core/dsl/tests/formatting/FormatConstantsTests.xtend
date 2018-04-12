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
class FormatConstantsTests extends FormatterTestBase {

	@Test
	def void testE1() {
		val input = '''
			const    Int16   a 
			    =  1    +3*   5  
		'''
		
		val expected = '''
			const Int16 a = 1 + 3 * 5
		'''
		
		assertEquals(expected.wrap, input.wrap.format)
	}

	@Test
	def void testA1() {
		val input = '''
			array   MyArray  of  UInt8
			const    MyArray   a 
			    =  [1,2,- 3,4]  
		'''
		
		val expected = '''
			array MyArray of UInt8
			
			const MyArray a = [ 1, 2, -3, 4 ]
		'''
		
		assertEquals(expected.wrap.chompEmpty, input.wrap.format)
	}

	@Test
	def void testA2() {
		val input = '''
			struct   MyStruct { Int8 e UInt8 f String g }
			const    MyStruct   a 
			    ={e:  - 3  , f   : 7   ,  g
			    : "foo" }  
		'''
		
		val expected = '''
			struct MyStruct {
				Int8 e
				UInt8 f
				String g
			}
			
			const MyStruct a = {
				e : -3,
				f : 7,
				g : "foo"
			}
		'''
		
		assertEquals(expected.wrap.chompEmpty, input.wrap.format)
	}



	def private String wrap(String s) '''
		package a.b
		
		typeCollection TC1 {
			«s»
		}
	'''

}
