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
class OMGIDL2FrancaBasicTests extends TestBase {

	val MODEL_DIR = "model/testcases/"
	val REF_DIR = "model/reference/"
	val GEN_DIR = "src-gen/testcases/"
	
	@Test
	def test_10() {
		test("10-EmptyInterface")
	}

	@Test
	def test_11() {
		test("11-EmptyInterfacesWithIncludes")
	}
	
	@Test
	def test_12() {
		test("12-TypeDeclarations")
	}
	
	@Test
	def test_13() {
		test("13-ConstantDeclarations")
	}
	
	@Test
	def test_14() {
		test("14-InterfaceDeclarations")
	}
	
	@Test
	def test_24() {
		test("24-FixedType")
	}
	
	@Test
	def test_35() {
		test("35-NestedModules")
	}

	@Test
	def test_60() {
		test("60-DiscriminatedUnion")
	}
		

	/**
	 * Utility method for executing one transformation and comparing the result with a reference model.
	 */
	def private test(String inputfile) {
		testTransformation(inputfile, MODEL_DIR, GEN_DIR, REF_DIR)
	}

}
