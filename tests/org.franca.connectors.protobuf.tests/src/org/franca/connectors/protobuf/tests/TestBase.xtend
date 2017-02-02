/*******************************************************************************
 * Copyright (c) 2016 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.connectors.protobuf.tests

import org.franca.connectors.protobuf.ProtobufConnector
import org.franca.connectors.protobuf.ProtobufModelContainer
import org.franca.core.dsl.tests.util.TransformationTestBase

import static org.junit.Assert.assertEquals
import static org.junit.Assert.assertNotNull

class TestBase extends TransformationTestBase {

	val PROTOBUF_EXT = ".proto"

	def protected testTransformation(String inputfile, String modelDir, String genDir, String refDir, boolean normalizeIds) {
		// load the Protobuf input model (may consist of multiple files)
		val conn = new ProtobufConnector(normalizeIds)
		val proto = conn.loadModel(modelDir + inputfile + PROTOBUF_EXT) as ProtobufModelContainer

		// validate input model(s)
		val nErrors = validateModel(proto.model, true)
		assertEquals("Errors during validation of input model", 0, nErrors)

		// transform to Franca 
		val fmodelGen = conn.toFranca(proto)
		assertNotNull("Transformation to Franca returned null", fmodelGen)
		val rootModelName = fmodelGen.modelName

		// save transformed Franca file(s)
		fmodelGen.model.saveModel(genDir + rootModelName + FRANCA_IDL_EXT, fmodelGen)
		
		// load the reference Franca IDL model
		val fmodelRef = loadModel(refDir + rootModelName + FRANCA_IDL_EXT)

		// we expect that both Franca IDL models are identical 
		val nDiffs = finalizeTest(fmodelGen, fmodelRef, inputfile, "target/surefire-reports")
		assertEquals(0, nDiffs)
	}
	
}
