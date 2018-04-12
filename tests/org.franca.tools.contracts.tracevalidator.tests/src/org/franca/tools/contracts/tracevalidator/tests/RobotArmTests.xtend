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
import org.franca.core.franca.FMethod
import org.franca.core.franca.FTransition
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith

import static org.junit.Assert.*

import static extension org.franca.tools.contracts.tracevalidator.tests.TraceBuilder.*

@RunWith(typeof(XtextRunner2_Franca))
@InjectWith(typeof(FrancaIDLTestsInjectorProvider))
class RobotArmTests extends ValidatorTestBase {

	var FMethod move = null
	var FMethod grab = null
	var FMethod release = null
	
	@Before
	def void init() {
		val i = loadModel("50-RobotArm.fidl")
		assertEquals(3, i.methods.size)
		move = getMethod(i, "move")
		grab = getMethod(i, "grab")
		release = getMethod(i, "release")
	}

	// -------------------------------------------------

	@Test
	def testValidTrace1() {
		val result = check [
			call(move) respond(move)
		]
		assertTrue(result.valid)
	}

	@Test
	def testValidTrace2() {
		val result = check [
			call(move) respond(move)
			call(move) respond(move)
		]
		assertTrue(result.valid)
	}

	@Test
	def testValidTrace3() {
		val result = check [
			call(grab) respond(grab)
			call(release) respond(release)
		]
		assertTrue(result.valid)
	}

	@Test
	def testValidTrace4() {
		val result = check [
			call(move) respond(move)
			call(move) respond(move)
			call(grab) respond(grab)
			call(move) respond(move)
			call(move) respond(move)
			call(release) respond(release)
		]
		assertTrue(result.valid)
	}

	// -------------------------------------------------
	
	@Test
	def testValidIncompleteTrace1() {
		val result = check [
			respond(move)
		]
		assertTrue(result.valid)
	}

	@Test
	def testValidIncompleteTrace2() {
		val result = check [
			respond(move)
			call(release) respond(release)
		]
		assertTrue(result.valid)
	}

	// -------------------------------------------------

	@Test
	def testInvalidTrace1() {
		val result = check [
			call(move) call(move)
		]
		assertFalse(result.valid)
		assertEquals(1, result.traceElementIndex)
		assertEquals(2, result.expected.size)
		
		val Set<FTransition> expected = newHashSet
		expected.add(getState("handleMoveEmpty").transitions.get(0))
		expected.add(getState("handleMoveFull").transitions.get(0))
		assertEquals(expected, result.expected)
	}


}
