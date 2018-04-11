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
class FormatCommentsTests extends FormatterTestBase {

	@Test
	def void test1() {
		val input = '''
		package a.b <** @description: Hooray. **> typeCollection TC1 { }
		'''
		
		val expected = '''
			package a.b
			
			<**
				@description: Hooray. 
			**>
			typeCollection TC1 {
			}
		'''
		
		assertEquals(expected, input.format)
	}

	@Test
	def void test2() {
		val input = '''
		package a.b
		<**
			@description: Hello.
				World.
		**>
		typeCollection TC1 { }
		'''
		
		val expected = '''
			package a.b
			
			<**
				@description: Hello.
					World.
			**>
			typeCollection TC1 {
			}
		'''
		
		assertEquals(expected, input.format)
	}

	@Test
	def void test3() {
		val input = '''
			package a.b typeCollection TC1 {
				<** @author: Kurt Goedel **>array   t1  of   UInt16
			}
		 '''
		
		val expected = '''
			package a.b
			
			typeCollection TC1 {
				<**
					@author: Kurt Goedel 
				**>
				array t1 of UInt16
			}
		'''
		
		assertEquals(expected, input.format)
	}

	@Test
	def void test4() {
		val input = '''
		package a.b
		<**
			@description: Hello.
				World. This is a quite long text in
				several lines. @author: Kurt Goedel! @see: What?
		**>
		typeCollection TC1 { }
		'''
		
		val expected = '''
			package a.b
			
			<**
				@description: Hello.
					World. This is a quite long text in
					several lines. 
				@author: Kurt Goedel! 
				@see: What?
			**>
			typeCollection TC1 {
			}
		'''
		
		assertEquals(expected, input.format)
	}


}
