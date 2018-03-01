/*******************************************************************************
 * Copyright (c) 2015 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.core.dsl.tests

import com.google.inject.Inject
import com.itemis.xtext.testing.XtextTest
import java.math.BigInteger
import org.eclipse.emf.common.util.URI
import org.eclipse.xtext.testing.InjectWith
import org.franca.core.dsl.FrancaIDLTestsInjectorProvider
import org.franca.core.dsl.FrancaPersistenceManager
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.franca.core.franca.FBinaryOperation
import org.franca.core.franca.FConstantDef
import org.franca.core.franca.FEnumerationType
import org.franca.core.franca.FExpression
import org.franca.core.franca.FIntegerConstant
import org.franca.core.franca.FQualifiedElementRef
import org.franca.core.utils.ExpressionEvaluator
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith

import static org.junit.Assert.*

@RunWith(typeof(XtextRunner2_Franca))
@InjectWith(typeof(FrancaIDLTestsInjectorProvider))
class EnumValueTests extends XtextTest {

	@Inject
	FrancaPersistenceManager fidlLoader

	var FEnumerationType enum1 = null
	
	@Before
	def void init() {
		val root = URI::createURI("classpath:/")
		val loc = URI::createFileURI("testcases/evaluation/ConstantsForEnums.fidl")
		val fmodel = fidlLoader.loadModel(loc, root)
		
		assertEquals(1, fmodel.typeCollections.size)
		val tc = fmodel.typeCollections.get(0)
		enum1 = tc.types.filter(FEnumerationType).findFirst[name=="Enum1"]
	}


	@Test
	def void testE0() {
		val e = enum1.getEnum("E0")
		assertNull(e.value)
	}

	@Test
	def void testE1() {
		val e = enum1.getEnum("E1")
		assertNotNull(e.value)
		val v = e.value
		
		assertTrue(v instanceof FQualifiedElementRef)
		val qe = v as FQualifiedElementRef
		
		// qe.element is still a proxy, the next line will resolve the proxy 
		val elem = qe.element
		assertTrue(elem instanceof FConstantDef)
		val c = elem as FConstantDef
		c.check(1)
	}
	
	@Test
	def void testE2() {
		val e = enum1.getEnum("E2")
		assertNotNull(e.value)
		val v = e.value
		
		assertTrue(v instanceof FQualifiedElementRef)
		val qe = v as FQualifiedElementRef
		val elem = qe.element
		assertTrue(elem instanceof FConstantDef)
		val c = elem as FConstantDef
		c.check(3)
	}
	
	@Test
	def void testE3() {
		val e = enum1.getEnum("E3")
		assertNotNull(e.value)
		val v = e.value
		
		assertTrue(v instanceof FQualifiedElementRef)
		val qe = v as FQualifiedElementRef
		val elem = qe.element
		assertTrue(elem instanceof FConstantDef)
		val c = elem as FConstantDef
		c.check(77)
	}
	
	@Test
	def void testE4() {
		val e = enum1.getEnum("E4")
		assertNotNull(e.value)
		val v = e.value
		
		assertTrue(v instanceof FQualifiedElementRef)
		val qe = v as FQualifiedElementRef
		val elem = qe.element
		assertTrue(elem instanceof FConstantDef)
		val c = elem as FConstantDef
		c.check(4)
	}
	
	@Test
	def void testE5() {
		val e = enum1.getEnum("E5")
		assertNotNull(e.value)
		val v = e.value
		
		assertTrue(v instanceof FIntegerConstant)
		val c = v as FIntegerConstant
		assertEquals(BigInteger::valueOf(77), c.^val)
	}

	@Test
	def void testE6() {
		val e = enum1.getEnum("E6")
		assertNotNull(e.value)
		val v = e.value
		
		assertTrue(v instanceof FBinaryOperation)
		val op = v as FBinaryOperation
		
		// we could parse the FBinaryOperation here, but we just use the evaluator to check its value
		val result = ExpressionEvaluator::evaluateInteger(op)
		assertNotNull(result)
		assertEquals(BigInteger::valueOf(30), result)
	}


	@Test
	def void testE7() {
		val e = enum1.getEnum("E7")
		assertNotNull(e.value)
		val v = e.value
		
		// just use the evaluator to check the value of the expression
		val result = ExpressionEvaluator::evaluateInteger(v)
		assertNotNull(result)
		assertEquals(BigInteger::valueOf(12), result)

		// do a little bit of parsing (use some Xtend interpreter with dispatch methods for this)
		assertTrue(v instanceof FBinaryOperation)
		val op = v as FBinaryOperation

		assertTrue(op.left instanceof FQualifiedElementRef)
		assertTrue(op.right instanceof FQualifiedElementRef)
		val qeLeft = op.left as FQualifiedElementRef
		val qeRight = op.right as FQualifiedElementRef

		assertTrue(qeLeft.element instanceof FConstantDef)
		assertTrue(qeRight.element instanceof FConstantDef)
		val cLeft = qeLeft.element as FConstantDef		
		val cRight = qeRight.element as FConstantDef
		assertEquals("i2", cLeft.name)		
		assertEquals("i4", cRight.name)		
	}
		

	// helpers for checking the expected results

	def private getEnum(FEnumerationType enumeration, String enumName) {
		val e = enumeration.enumerators.findFirst[name==enumName]
		assertNotNull("Cannot find enumerator '" + enumName + "'", e)
		e
	}

	def private check(FConstantDef c, long expected) {
		checkBig(c, BigInteger::valueOf(expected))
	}

	def private checkBig(FConstantDef c, BigInteger expected) {
		val rhs = c.rhs as FExpression
		val result = ExpressionEvaluator::evaluateInteger(rhs)
		assertNotNull(result)
		assertEquals(expected, result)
	}

}
