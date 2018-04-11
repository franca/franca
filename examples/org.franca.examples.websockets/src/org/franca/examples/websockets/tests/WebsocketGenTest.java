/*******************************************************************************
 * Copyright (c) 2013 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.examples.websockets.tests;

import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;

import org.eclipse.emf.common.util.URI;
import org.eclipse.xtext.testing.InjectWith;
import org.eclipse.xtext.testing.XtextRunner;
import org.franca.core.dsl.tests.FrancaIDLInjectorProvider;
import org.franca.core.dsl.FrancaPersistenceManager;
import org.franca.core.franca.FModel;
import org.franca.generators.FrancaGenerators;
import org.junit.Test;
import org.junit.runner.RunWith;

import com.google.inject.Inject;

/**
 * Testcase for the Franca=>Websocket generator.
 * 
 * @author kbirken
 */
@RunWith(XtextRunner.class)
@InjectWith(FrancaIDLInjectorProvider.class)
public class WebsocketGenTest {

	final static String SERVER_GEN_DIR = "server/gen";
	final static String CLIENT_GEN_DIR = "client/gen";

	@Inject
	FrancaPersistenceManager loader;
	
	@Test
	public void test01() {
		genAndSave("org/example/SimpleUI.fidl", CLIENT_GEN_DIR, false);
	}


	private void genAndSave(
		String filename,
		String clientGenDir,
		boolean genAutobahnClient
	) {
		// load example Franca IDL interface
    	URI root = URI.createURI("classpath:/");
    	URI loc = URI.createFileURI(filename);
    	FModel fmodel = loader.loadModel(loc, root);
		assertNotNull(fmodel);
		//System.out.println("Franca IDL: package '" + fmodel.getName() + "'");
		
		// create HTML documentation from Franca model
		assertTrue(FrancaGenerators.instance().genWebsocket(fmodel,
				SERVER_GEN_DIR, clientGenDir, genAutobahnClient));
	}

}
