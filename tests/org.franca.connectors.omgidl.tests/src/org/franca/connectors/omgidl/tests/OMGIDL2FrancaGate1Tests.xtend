/*******************************************************************************
 * Copyright (c) 2016 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.connectors.omgidl.tests

import org.eclipse.xtext.testing.InjectWith
import org.franca.core.dsl.FrancaIDLTestsInjectorProvider
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(typeof(XtextRunner2_Franca))
@InjectWith(typeof(FrancaIDLTestsInjectorProvider))
class OMGIDL2FrancaGate1Tests extends TestBase {

	val MODEL_DIR = "model/testcases/gate1/"
	val REF_DIR = "model/reference/gate1/"
	val GEN_DIR = "src-gen/testcases/gate1/"
	
	@Test
	def void test_20() {
		test("bn_ev")
	}
	
	@Test
	def void test_21() {
		test("bn_t")
	}
	
	@Test
	def void test_22() {
		test("csm_cs")
	}
	
	@Test
	def void test_23() {
		test("csm_t")
	}
	
	@Test
	def void test_24() {
		test("db_cs")
	}
	
	@Test
	def void test_25() {
		test("db_ev")
	}
	
	@Test
	def void test_26() {
		test("db_t")
	}
	
	@Test
	def void test_27() {
		test("de_ev")
	}
	
	@Test
	def void test_28() {
		test("de")
	}
	
	@Test
	def void test_29() {
		test("evc_t")
	}
	
	@Test
	def void test_30() {
		test("evm_ev")
	}
	
	@Test
	def void test_31() {
		test("evm")
	}
	
	@Test
	def void test_32() {
		test("evs")
	}


	/**
	 * Utility method for executing one transformation and comparing the result with a reference model.
	 */
	def private test(String inputfile) {
		testTransformation(inputfile, MODEL_DIR, GEN_DIR, REF_DIR)
	}

}
