/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.tools.contracts.tracevalidator.tests

import java.util.Set
import org.eclipse.xtext.testing.InjectWith
import org.franca.core.dsl.FrancaIDLTestsInjectorProvider
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.franca.core.franca.FAttribute
import org.franca.core.franca.FBroadcast
import org.franca.core.franca.FMethod
import org.franca.core.franca.FTransition
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith

import static org.junit.Assert.*

import static extension org.franca.tools.contracts.tracevalidator.tests.TraceBuilder.*

@RunWith(typeof(XtextRunner2_Franca))
@InjectWith(typeof(FrancaIDLTestsInjectorProvider))
class AllEventsTests extends ValidatorTestBase {

	var FAttribute a = null
	var FMethod m = null
	var FBroadcast b = null
	
	@Before
	def void init() {
		val i = loadModel("20-AllEvents.fidl")
		assertEquals(1, i.attributes.size)
		a = i.attributes.get(0)
		assertEquals(1, i.methods.size)
		m = i.methods.get(0)
		assertEquals(1, i.broadcasts.size)
		b = i.broadcasts.get(0)
	}

	// -------------------------------------------------

	@Test
	def testValidTrace1() {
		val result = check [
			call(m) respond(m)
		]
		assertTrue(result.valid)
	}

	@Test
	def testValidTrace2() {
		val result = check [
			respond(m)
			signal(b)			
			call(m) respond(m)
			signal(b)			
			call(m) respond(m)
			signal(b)			
		]
		assertTrue(result.valid)
	}

	@Test
	def testValidTrace5() {
		val result = check [
			update(a)
			update(a)
			update(a)
			call(m) respond(m)
			set(a)			
			set(a)			
			set(a)
			signal(b)			
			update(a)
		]
		assertTrue(result.valid)
	}

	@Test
	def testValidTrace6() {
		val result = check [
			update(a)
			call(m) error(m)
			call(m) respond(m)
			set(a)			
			signal(b)			
			update(a)
		]
		assertTrue(result.valid)
	}

	// -------------------------------------------------

	@Test
	def testInvalidTrace1() {
		val result = check [
			call(m) respond(m)
			update(a)
			update(a)
		]
		assertFalse(result.valid)
		assertEquals(2, result.traceElementIndex)
		assertEquals(2, result.expected.size)
		
		val Set<FTransition> expected = newHashSet
		expected.add(getState("writing").transitions.get(0))
		expected.add(getState("writing").transitions.get(1))
		assertEquals(expected, result.expected)
	}


}
