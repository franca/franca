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
class FormatTypesTests extends FormatterTestBase {

	@Test
	def void testA1() {
		val input = '''array   MyArray  of  Boolean'''
		
		val expected = '''
			array MyArray of Boolean
		'''
		
		assertEquals(expected.wrap, input.wrap.format)
	}

	@Test
	def void testE1() {
		val input = '''enumeration   MyEnum  {E1 E2 E3}'''
		
		val expected = '''
			enumeration MyEnum {
				E1
				E2
				E3
			}
		'''
		
		assertEquals(expected.wrap, input.wrap.format)
	}

	@Test
	def void testE2() {
		val input = '''enumeration   MyEnum  {E1 E2 E3}'''
		
		val expected = '''
			enumeration MyEnum {
				E1
				E2
				E3
			}
		'''
		
		assertEquals(expected.wrap, input.wrap.format)
	}

	@Test
	def void testE3() {
		val input = '''enumeration   MyEnum  {E1=1 E2=-1 E3  = 3+4}'''
		
		val expected = '''
			enumeration MyEnum {
				E1 = 1
				E2 = -1
				E3 = 3 + 4
			}
		'''
		
		assertEquals(expected.wrap, input.wrap.format)
	}

	@Test
	def void testS1() {
		val input = '''struct   MyStruct   polymorphic  {}'''
		
		val expected = '''
			struct MyStruct polymorphic { }
		'''
		
		assertEquals(expected.wrap, input.wrap.format)
	}

	@Test
	def void testS2() {
		val input = '''struct   MyStruct   { String  a   UInt8   b    }'''
		
		val expected = '''
			struct MyStruct {
				String a
				UInt8 b
			}
		'''
		
		assertEquals(expected.wrap, input.wrap.format)
	}

	@Test
	def void testS3() {
		val input = '''
			struct   MyStruct   polymorphic  {}
			struct   MyDerived    extends   MyStruct  {String s}
		'''
		
		val expected = '''
			struct MyStruct polymorphic { }
			
			struct MyDerived extends MyStruct {
				String s
			}
		'''
		
		assertEquals(expected.wrap.chompEmpty, input.wrap.format)
	}

	@Test
	def void testU1() {
		val input = '''union   MyUnion  {}'''
		
		val expected = '''
			union MyUnion { }
		'''
		
		assertEquals(expected.wrap, input.wrap.format)
	}

	@Test
	def void testU2() {
		val input = '''union   MyUnion   { String  a   UInt8   b    }'''
		
		val expected = '''
			union MyUnion {
				String a
				UInt8 b
			}
		'''
		
		assertEquals(expected.wrap, input.wrap.format)
	}

	@Test
	def void testM1() {
		val input = '''map   MyMap   { String  to  UInt16    }'''
		
		val expected = '''
			map MyMap { String to UInt16 }
		'''
		
		assertEquals(expected.wrap, input.wrap.format)
	}

	@Test
	def void testT1() {
		val input = '''typedef  MyAlias  is  String'''
		
		val expected = '''
			typedef MyAlias is String
		'''
		
		assertEquals(expected.wrap, input.wrap.format)
	}


	def private String wrap(String s) '''
		package a.b
		
		typeCollection TC1 {
			«s»
		}
	'''

}
