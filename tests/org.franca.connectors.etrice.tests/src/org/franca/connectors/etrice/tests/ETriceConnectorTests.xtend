/*******************************************************************************
 * Copyright (c) 2012 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.connectors.etrice.tests

import com.google.inject.Inject
import org.eclipse.xtext.junit4.InjectWith
import org.eclipse.xtext.junit4.XtextRunner
import org.franca.connectors.etrice.ROOMConnector
import org.franca.connectors.etrice.ROOMModelContainer
import org.franca.core.dsl.FrancaPersistenceManager
import org.junit.Test
import org.junit.runner.RunWith

import static org.junit.Assert.*

@RunWith(typeof(XtextRunner))
@InjectWith(typeof(ETriceFrancaTestInjectorProvider))
class ETriceConnectorTests {

	@Inject	FrancaPersistenceManager fidlLoader
	@Inject ROOMConnector etrice

	@Test
	def void transformFranca2ETrice() {
		// The folder of the Eclipse workspace is needed. It will be used
		// to find the root folder of the eTrice modellib project in your workspace
		// (which is named org.eclipse.etrice.modellib.java). In order to set the
		// property properly, open the Run Configuration of the JUnit test,
		// go to "Arguments" / "VM Arguments" and enter the following string:
		//     -Dworkspace.loc=${workspace_loc}
		val workspaceFolder = System::getProperty("workspace.loc")
		assertNotNull(workspaceFolder)
		etrice.setModellibFolder(workspaceFolder + "/org.eclipse.etrice.modellib.java/models")

		val fmodel = fidlLoader.loadModel("model/example1.fidl")
		assertNotNull(fmodel)	
		
		// transform Franca model to ROOM model
		val result = etrice.fromFranca(fmodel) as ROOMModelContainer
		val rmodel = result.model
		assertNotNull(rmodel)
		
		// save the resulting model
		val outfile = "model-gen/example1.room"
		assertTrue(etrice.saveModel(result, outfile))
		
		// give advice to the caller
		println("Next steps:")
		println("  Execute gen_example1.launch to generate Java code from the generated ROOM model.")
		println("  Execute the generated Java code by running SubSystemRunner.")
		println("  You may also open example1.room with eTrice and examine the model.")
	}
	
}

