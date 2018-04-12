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
import org.eclipse.xtext.testing.InjectWith;
import org.eclipse.xtext.testing.XtextRunner;
import org.franca.deploymodel.core.FDModelExtender;
import org.franca.deploymodel.core.FDeployedInterface;
import org.franca.deploymodel.dsl.FDeployPersistenceManager;
import org.franca.deploymodel.dsl.fDeploy.FDExtensionRoot;
import org.franca.deploymodel.dsl.fDeploy.FDInterface;
import org.franca.deploymodel.dsl.fDeploy.FDModel;
import org.franca.deploymodel.dsl.tests.FDeployInjectorProvider;
import org.franca.deploymodel.ext.providers.FDeployedProvider;
import org.franca.deploymodel.ext.providers.ProviderExtension;
import org.franca.deploymodel.ext.providers.ProviderUtils;
import org.franca.deploymodel.extensions.ExtensionRegistry;
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
		
		ExtensionRegistry.addExtension(new ProviderExtension());
		
		// load example Franca IDL interface
		String inputfile = TestConfiguration.fdeployArchFile; 
    	URI root = URI.createURI("classpath:/");
    	URI loc = URI.createFileURI(inputfile);
		FDModel fdmodel = loader.loadModel(loc, root);
		assertNotNull(fdmodel);
		
		// get first provider definition referenced by FDeploy model
		List<FDExtensionRoot> providers = ProviderUtils.getProviders(fdmodel); 
		assert(! providers.isEmpty());
		
		// create wrapper and generate configuration file from it
		FDeployedProvider deployed = new FDeployedProvider(providers.get(0));
		ExampleRuntimeConfigGenerator generator = new ExampleRuntimeConfigGenerator();
		String code = generator.generateRuntimeConfig(deployed).toString();

		ExtensionRegistry.reset();

		// simply print the generated config file to console
		System.out.println("Generated configuration file:\n" + code);
		System.out.println("-----------------------------------------------------");
	}

}
