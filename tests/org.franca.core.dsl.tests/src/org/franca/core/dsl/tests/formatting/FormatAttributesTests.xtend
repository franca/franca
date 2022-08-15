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
class FormatAttributesTests extends FormatterTestBase {

	@Test
	def void test1() {
		val input = '''attribute  String   m1'''
		
		val expected = '''
			attribute String m1
		'''
		
		assertEquals(expected.wrap, input.wrap.format)
	}

	@Test
	def void test2() {
		val input = '''attribute  String   m1  readonly'''
		
		val expected = '''
			attribute String m1 readonly
		'''
		
		assertEquals(expected.wrap, input.wrap.format)
	}

	@Test
	def void test3() {
		val input = '''attribute  String   m1
		noRead   noSubscriptions'''
		
		val expected = '''
			attribute String m1 noRead noSubscriptions
		'''
		
		assertEquals(expected.wrap, input.wrap.format)
	}


	def private String wrap(String s) '''
		package a.b
		
		interface I1 {
			«s»
		}
	'''

}
