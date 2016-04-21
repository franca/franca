/*******************************************************************************
 * Copyright (c) 2016 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.connectors.omgidl.tests

import org.franca.connectors.omgidl.OMGIDLConnector
import org.franca.connectors.omgidl.OMGIDLModelContainer
import org.franca.core.dsl.tests.util.TransformationTestBase

import static org.junit.Assert.assertEquals
import static org.junit.Assert.assertNotNull

class TestBase extends TransformationTestBase {

	val OMG_IDL_EXT = ".idl"

	def protected testTransformation(String inputfile, String model_dir, String gen_dir, String ref_dir) {
		// load the OMG IDL input model (may consist of multiple files)
		val conn = new OMGIDLConnector
		val omgidl = conn.loadModel(model_dir + inputfile + OMG_IDL_EXT) as OMGIDLModelContainer

		// validate input model(s)
		val nErrors = validateModel(omgidl.model, true)
		assertEquals("Errors during validation of input model", 0, nErrors)

		// transform to Franca 
		val fmodelGen = conn.toFranca(omgidl)
		assertNotNull("Tranformation to Franca return null", fmodelGen)
		val rootModelName = fmodelGen.modelName

		// save transformed Franca file(s)
		fmodelGen.model.saveModel(gen_dir + rootModelName + FRANCA_IDL_EXT, fmodelGen)
		
		// load the reference Franca IDL model
		val fmodelRef = loadModel(ref_dir + rootModelName + FRANCA_IDL_EXT)

		// we expect that both Franca IDL models are identical 
		val nDiffs = finalizeTest(fmodelGen, fmodelRef, inputfile, "target/surefire-reports")
		assertEquals(0, nDiffs)
	}
	
	
}