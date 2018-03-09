/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.core.dsl.tests

import com.google.inject.Inject
import com.itemis.xtext.testing.XtextTest
import java.math.BigInteger
import java.util.Map
import org.eclipse.emf.common.util.URI
import org.eclipse.xtext.testing.InjectWith
import org.franca.core.dsl.FrancaIDLTestsInjectorProvider
import org.franca.core.dsl.FrancaPersistenceManager
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.franca.core.franca.FConstantDef
import org.franca.core.franca.FExpression
import org.franca.core.utils.ExpressionEvaluator
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith

import static org.junit.Assert.*

@RunWith(typeof(XtextRunner2_Franca))
@InjectWith(typeof(FrancaIDLTestsInjectorProvider))
class EvaluationTests extends XtextTest {

	@Inject
	FrancaPersistenceManager fidlLoader

	var Map<String, FConstantDef> defs = null
	
	@Before
	def void init() {
		val root = URI::createURI("classpath:/")
		val loc = URI::createFileURI("testcases/evaluation/IntegerExpressions.fidl")
		val fmodel = fidlLoader.loadModel(loc, root)
		
		assertEquals(1, fmodel.typeCollections.size)
		val tc = fmodel.typeCollections.get(0)
		defs = tc.constants.toMap[name]
	}


	@Test
	def testBasicBooleanOperations() {
		check("b01", true)
		check("b02", false)
		check("b03", true)
		check("b04", false)
		check("b05", true)
		check("b06", true)
	}

	@Test
	def testComparisonOperations() {
		check("b20", false)
		check("b21", true)
		check("b22", true)
		check("b23", true)
		check("b24", true)
		check("b25", false)
		check("b26", true)
		check("b27", true)
		check("b28", true)
	}

	@Test
	def testBasicIntegerOperations() {
		check("i01", 1)
		check("i02", 3)
		check("i03", 56)
		check("i04", 77)
		check("i05", 20)
		check("i06", 2)
		check("i07", 2)
		check("i08", 2)
		check("i09", 20)
	}

	@Test
	def testHexValues() {
		check("h01", 1)
		check("h02", 16)
		check("h03", 10000)
	}

	@Test
	def testBinaryValues() {
		check("y01", 1)
		check("y02", 16)
		check("y03", 160968)
	}

	@Test
	def testComplexIntegerOperations() {
		check("i10", 15)
		check("i11", 717)
		check("i12", 156)
		check("i13", 0)
	}
		
	@Test
	def testHugeIntegers() {
		checkBig("h10", new BigInteger("1000000000000"))
		checkBig("h11", new BigInteger("2000000000001"))
	}

	@Test
	def testBasicStringOperations() {
		check("s10", "foo")
	}

	@Test
	def testRangedIntegerTypedef() {
		check("t01", 7)
	}

	@Test
	def testConstantDefRefs() {
		check("r10", false)
		check("r20", 6)
		check("r21", 8)
		check("r25", "foo")
	}

	@Test
	def testStructRefs() {
		check("r30", true)
		check("r31", 7)
		check("r40", true)
		check("r31", 7)
	}

	// helpers for checking the expected results

	def private check (String constant, boolean expected) {
		val rhs = constant.checkedConstantDef
		val result = ExpressionEvaluator::evaluateBoolean(rhs)
		assertNotNull(result)
		assertEquals(expected, result)
	}

	def private check (String constant, long expected) {
		checkBig(constant, BigInteger::valueOf(expected))
	}

	def private checkBig (String constant, BigInteger expected) {
		val rhs = constant.checkedConstantDef
		val result = ExpressionEvaluator::evaluateInteger(rhs)
		assertNotNull(result)
		assertEquals(expected, result)
	}
	
	def private check (String constant, String expected) {
		val rhs = constant.checkedConstantDef
		val result = ExpressionEvaluator::evaluateString(rhs)
		assertNotNull(result)
		assertEquals(expected, result)
	}

	def private getCheckedConstantDef (String constant) {
		assertTrue(defs.containsKey(constant))
		val c = defs.get(constant)

		assertTrue(c.rhs instanceof FExpression)
		c.rhs as FExpression 
	}
}
