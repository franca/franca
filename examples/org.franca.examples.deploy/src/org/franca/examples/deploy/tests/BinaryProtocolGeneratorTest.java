/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.examples.deploy.tests;

import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;

import java.util.List;

import org.eclipse.emf.common.util.URI;
import org.eclipse.xtext.testing.InjectWith;
import org.eclipse.xtext.testing.XtextRunner;
import org.franca.deploymodel.core.FDModelExtender;
import org.franca.deploymodel.core.FDeployedInterface;
import org.franca.deploymodel.dsl.tests.FDeployInjectorProvider;
import org.franca.deploymodel.dsl.FDeployPersistenceManager;
import org.franca.deploymodel.dsl.fDeploy.FDInterface;
import org.franca.deploymodel.dsl.fDeploy.FDModel;
import org.franca.examples.deploy.generators.ExampleBinaryProtocolGenerator;
import org.junit.Test;
import org.junit.runner.RunWith;

import com.google.inject.Inject;

/**
 * Testcase for using code generators based on Franca deployment models.
 * 
 * @author Klaus Birken (itemis AG)
 */
@RunWith(XtextRunner.class)
@InjectWith(FDeployInjectorProvider.class)
public class BinaryProtocolGeneratorTest {

	@Inject
	FDeployPersistenceManager loader;

	@Test
	public void testInterfaceGeneration() {
		System.out.println("*** BinaryProtocolGeneratorTest / Datatype Generation");

		// load example Franca IDL interface
		String inputfile = TestConfiguration.fdeployBinaryProtocolFile; 
    	URI root = URI.createURI("classpath:/");
    	URI loc = URI.createFileURI(inputfile);
		FDModel fdmodel = loader.loadModel(loc, root);
		assertNotNull(fdmodel);
		
		// get first interface referenced by FDeploy model
		FDModelExtender fdmodelExt = new FDModelExtender(fdmodel);
		List<FDInterface> interfaces = fdmodelExt.getFDInterfaces();
		assertTrue(interfaces.size()>0);
		FDInterface api = interfaces.get(0);
		
		// create wrapper and generate code from it 
		FDeployedInterface deployed = new FDeployedInterface(api);
		ExampleBinaryProtocolGenerator generator =
				new ExampleBinaryProtocolGenerator();
		String code = generator.generateProtocol(deployed).toString();
		
		// simply print the generated code to console
		System.out.println("Generated code:\n" + code);
		System.out.println("-----------------------------------------------------");
	}

}
