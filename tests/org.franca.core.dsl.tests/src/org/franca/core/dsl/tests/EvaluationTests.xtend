/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.core.dsl.tests

import java.util.Map
import org.junit.Test
import org.junit.Before
import org.junit.runner.RunWith
import com.google.inject.Inject
import org.eclipse.emf.common.util.URI;
import org.eclipse.xtext.junit4.InjectWith
import org.eclipselabs.xtext.utils.unittesting.XtextRunner2
import org.eclipselabs.xtext.utils.unittesting.XtextTest
import org.franca.core.dsl.FrancaPersistenceManager
import org.franca.core.dsl.FrancaIDLTestsInjectorProvider
import org.franca.core.utils.ExpressionEvaluator
import org.franca.core.franca.FConstantDef
import org.franca.core.franca.FExpression

import static extension org.junit.Assert.*
import java.math.BigInteger

@RunWith(typeof(XtextRunner2))
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
	def testBasicOperations() {
    	check("i01", 1)
    	check("i02", 3)
    	check("i03", 56)
    	check("i04", 77)
    	check("i05", 20) 
    	check("i06", 2)
	}

	@Test
	def testComplexOperations() {
    	check("i10", 15) 
    	check("i11", 717) 
    	check("i12", 156) 
    	check("i13", 0) 
	}
		
	@Test
	def testHugeNumbers() {
    	checkBig("h10", new BigInteger("1000000000000")) 
	}

	@Test
	def testConstantDefRefs() {
    	check("r10", 6) 
    	check("r11", 8) 
	}


	def private check (String constant, long expected) {
		checkBig(constant, BigInteger.valueOf(expected))
	}

	def private checkBig (String constant, BigInteger expected) {
		assertTrue(defs.containsKey(constant))
		val c = defs.get(constant)

		assertTrue(c.rhs instanceof FExpression)
		val result = ExpressionEvaluator::evaluateInteger(c.rhs as FExpression)

		assertEquals(expected, result)
	}
	
	
}
