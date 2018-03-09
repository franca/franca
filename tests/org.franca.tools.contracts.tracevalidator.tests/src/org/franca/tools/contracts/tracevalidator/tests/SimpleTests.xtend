/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.tools.contracts.tracevalidator.tests

import org.eclipse.xtext.testing.InjectWith
import org.franca.core.dsl.FrancaIDLTestsInjectorProvider
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.franca.core.franca.FMethod
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith

import static org.junit.Assert.*

import static extension org.franca.tools.contracts.tracevalidator.tests.TraceBuilder.*

@RunWith(typeof(XtextRunner2_Franca))
@InjectWith(typeof(FrancaIDLTestsInjectorProvider))
class SimpleTests extends ValidatorTestBase {

	var FMethod m = null
	
	@Before
	def void init() {
		val i = loadModel("10-Simple.fidl")
		assertEquals(1, i.methods.size)
		m = i.methods.get(0)
	}


	@Test
	def testEmptyTrace() {
		val result = check []
		assertFalse(result.valid) // TODO: should empty trace be valid or invalid?
	}

	@Test
	def testValidTraceLen1_cm() {
		val result = check [call(m)]
		assertTrue(result.valid)
	}

	@Test
	def testValidTraceLen1_rm() {
		val result = check [respond(m)]
		assertTrue(result.valid)
	}

	@Test
	def testValidTraceLen2_cm_rm() {
		val result = check [call(m) respond(m)]
		assertTrue(result.valid)
	}

	@Test
	def testValidTraceLen2_rm_cm() {
		val result = check [respond(m) call(m)]
		assertTrue(result.valid)
	}

	@Test
	def testInvalidTraceLen2_cm_cm() {
		val result = check [call(m) call(m)]
		assertFalse(result.valid)
		assertEquals(1, result.traceElementIndex)
		assertEquals(1, result.expected.size)
		assertEquals(getState("B").transitions.get(0), result.expected.get(0))
	}

	@Test
	def testInvalidTraceLen2_rm_rm() {
		val result = check [respond(m) respond(m)]
		assertFalse(result.valid)
		assertEquals(1, result.traceElementIndex)
		assertEquals(1, result.expected.size)
		assertEquals(getState("A").transitions.get(0), result.expected.get(0))
	}

	@Test
	def testValidTraceLen3_cm_rm_cm() {
		val result = check [call(m) respond(m) call(m)]
		assertTrue(result.valid)
	}

	@Test
	def testValidTraceLen3_rm_cm_rm() {
		val result = check [respond(m) call(m) respond(m)]
		assertTrue(result.valid)
	}

}
