/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.tools.contracts.tracevalidator.tests

import java.util.List
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import com.google.inject.Inject
import org.eclipse.emf.common.util.URI
import org.eclipse.xtext.junit4.InjectWith
import org.eclipselabs.xtext.utils.unittesting.XtextRunner2
import org.eclipselabs.xtext.utils.unittesting.XtextTest
import org.franca.core.dsl.FrancaIDLTestsInjectorProvider
import org.franca.core.dsl.FrancaPersistenceManager
import org.franca.core.franca.FContract
import org.franca.core.franca.FEventOnIf
import org.franca.core.franca.FMethod
import org.franca.core.franca.FrancaFactory
import org.franca.tools.contracts.tracevalidator.TraceValidator

import static org.junit.Assert.*

@RunWith(typeof(XtextRunner2))
@InjectWith(typeof(FrancaIDLTestsInjectorProvider))
class SimpleTests extends XtextTest {

	@Inject
	FrancaPersistenceManager fidlLoader

	var FMethod m = null
	var FContract contract = null
	
	@Before
	def void init() {
		val root = URI::createURI("classpath:/")
		val loc = URI::createFileURI("testcases/10-Simple.fidl")
		val fmodel = fidlLoader.loadModel(loc, root)
		
		assertEquals(1, fmodel.interfaces.size)
		val i = fmodel.interfaces.get(0)
		contract = i.contract

		assertEquals(1, i.methods.size)
		m = i.methods.get(0)
	}


	@Test
	def testEmptyTrace() {
		val List<FEventOnIf> trace = newArrayList
		val result = TraceValidator::isValidTracePure(contract, trace)
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



	// helpers for quick definition of test cases
	
	private def check((List<FEventOnIf>)=>void traceFunc) {
		val List<FEventOnIf> trace = newArrayList
		traceFunc.apply(trace)
		TraceValidator::isValidTracePure(contract, trace)
	}

	private def call(List<FEventOnIf> trace, FMethod m) {
		val ev = FrancaFactory::eINSTANCE.createFEventOnIf
		ev.call = m
		trace.add(ev)
	}

	private def respond(List<FEventOnIf> trace, FMethod m) {
		val ev = FrancaFactory::eINSTANCE.createFEventOnIf
		ev.respond = m
		trace.add(ev)
	}
	
	private def getState(String stateName) {
		contract.stateGraph.states.findFirst[name==stateName]
	}
}
