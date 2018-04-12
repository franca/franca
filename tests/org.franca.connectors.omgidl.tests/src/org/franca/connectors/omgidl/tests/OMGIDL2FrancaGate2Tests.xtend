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
class OMGIDL2FrancaGate2Tests extends TestBase {

	val MODEL_DIR = "model/testcases/gate2/"
	val REF_DIR = "model/reference/gate2/"
	val GEN_DIR = "src-gen/testcases/gate2/"
	
	@Test
	def void test_20() {
		test("evc_t")
	}
	
	@Test
	def void test_21() {
		test("evs")
	}
	
	@Test
	def void test_22() {
		test("oe")
	}
	
	@Test
	def void test_23() {
		test("ose")
	}
	
	@Test
	def void test_24() {
		test("TypedEventService")
	}
	
	@Test
	def void test_25() {
		test("UntypedEventService")
	}
	
	
	/**
	 * Utility method for executing one transformation and comparing the result with a reference model.
	 */
	def private test(String inputfile) {
		testTransformation(inputfile, MODEL_DIR, GEN_DIR, REF_DIR)
	}

}
