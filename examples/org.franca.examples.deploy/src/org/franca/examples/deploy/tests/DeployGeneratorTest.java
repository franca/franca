/*******************************************************************************
 * Copyright (c) 2013 itemis AG (http://www.itemis.de).
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
import org.eclipse.xtext.junit4.InjectWith;
import org.eclipse.xtext.junit4.XtextRunner;
import org.franca.deploymodel.core.FDModelExtender;
import org.franca.deploymodel.core.FDeployedInterface;
import org.franca.deploymodel.core.FDeployedProvider;
import org.franca.deploymodel.dsl.FDeployInjectorProvider;
import org.franca.deploymodel.dsl.FDeployPersistenceManager;
import org.franca.deploymodel.dsl.fDeploy.FDInterface;
import org.franca.deploymodel.dsl.fDeploy.FDModel;
import org.franca.deploymodel.dsl.fDeploy.FDProvider;
import org.franca.examples.deploy.generators.ExampleHppGeneratorWithDeployment;
import org.franca.examples.deploy.generators.ExampleRuntimeConfigGenerator;
import org.junit.Test;
import org.junit.runner.RunWith;

import com.google.inject.Inject;

/**
 * Testcase for using code generators based on Franca deployment models.
 * 
 * @author kbirken
 */
@RunWith(XtextRunner.class)
@InjectWith(FDeployInjectorProvider.class)
public class DeployGeneratorTest {

	@Inject
	FDeployPersistenceManager loader;

	@Test
	public void testInterfaceGeneration() {
		System.out.println("*** DeployGeneratorTest / Interface Generation");

		// load example Franca IDL interface
		String inputfile = TestConfiguration.fdeployInterfaceFile; 
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
		ExampleHppGeneratorWithDeployment generator =
				new ExampleHppGeneratorWithDeployment();
		String code = generator.generateInterface(deployed).toString();
		
		// simply print the generated code to console
		System.out.println("Generated code:\n" + code);
		System.out.println("-----------------------------------------------------");
	}

	
	@Test
	public void testRuntimeConfigGeneration() {
		System.out.println("*** DeployGeneratorTest / Runtime Config Generation");
		
		// load example Franca IDL interface
		String inputfile = TestConfiguration.fdeployArchFile; 
    	URI root = URI.createURI("classpath:/");
    	URI loc = URI.createFileURI(inputfile);
		FDModel fdmodel = loader.loadModel(loc, root);
		assertNotNull(fdmodel);
		
		// get first provider definition referenced by FDeploy model
		FDModelExtender fdmodelExt = new FDModelExtender(fdmodel);
		List<FDProvider> providers = fdmodelExt.getFDProviders(); 
		assert(providers.size() > 0);
		FDProvider provider = providers.get(0);
		
		// create wrapper and generate cnfiguration file from it
		FDeployedProvider deployed = new FDeployedProvider(provider);
		ExampleRuntimeConfigGenerator generator = new ExampleRuntimeConfigGenerator();
		String code = generator.generateRuntimeConfig(deployed).toString();

		// simply print the generated config file to console
		System.out.println("Generated configuration file:\n" + code);
		System.out.println("-----------------------------------------------------");
	}

}
