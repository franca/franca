package org.franca.examples.basic.tests;

import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;

import java.util.List;

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
import org.franca.examples.basic.generators.ExampleHppGeneratorWithDeployment;
import org.franca.examples.basic.generators.ExampleRuntimeConfigGenerator;
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
		String inputfile = "examples/" + TestConfiguration.fdeployInterfaceFile; 
		FDModel fdmodel = loader.loadModel(inputfile);
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
		String inputfile = "examples/" + TestConfiguration.fdeployArchFile; 
		FDModel fdmodel = loader.loadModel(inputfile);
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
