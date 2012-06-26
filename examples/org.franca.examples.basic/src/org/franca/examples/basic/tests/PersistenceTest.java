package org.franca.examples.basic.tests;

import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;

import java.util.List;

import org.franca.deploymodel.core.FDModelExtender;
import org.franca.deploymodel.core.FDeployedInterface;
import org.franca.deploymodel.dsl.FDModelHelper;
import org.franca.deploymodel.dsl.fDeploy.FDInterface;
import org.franca.deploymodel.dsl.fDeploy.FDModel;
import org.franca.examples.basic.generators.ExampleHppGeneratorWithDeployment;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;


/**
 * Testcase for Franca persistence: load/save model files.
 * 
 * @author Florentin Picioroaga
 */
public class PersistenceTest {

	@Before
	public void setUp() throws Exception {
	}

	@After
	public void tearDown() throws Exception {
	}

	@Test
	public void testInterfaceGeneration() {
		System.out.println("*** PersistenceTest");
		
		// load example Franca IDL interface
		String inputfile = "examples/fdeploy/testPersistence3.fdepl"; 
		FDModel fdmodel = FDModelHelper.instance().loadModel(inputfile);
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
}