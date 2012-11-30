package org.franca.examples.basic.tests;

import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;

import org.eclipse.xtext.junit4.InjectWith;
import org.eclipse.xtext.junit4.XtextRunner;
import org.franca.core.dsl.FrancaIDLInjectorProvider;
import org.franca.core.dsl.FrancaPersistenceManager;
import org.franca.core.franca.FInterface;
import org.franca.core.franca.FModel;
import org.franca.examples.basic.generators.ExampleHppGenerator;
import org.junit.Test;
import org.junit.runner.RunWith;

import com.google.inject.Inject;

/**
 * Testcase for the example C++ header generator from Franca IDL interfaces.
 * 
 * @author kbirken
 *
 */
@RunWith(XtextRunner.class)
@InjectWith(FrancaIDLInjectorProvider.class)
public class HppGeneratorTest {

	@Inject
	FrancaPersistenceManager loader;
	
	@Test
	public void test() {
		System.out.println("*** HppGeneratorTest");
		
		// load example Franca IDL interface
		String inputfile = "examples/" + TestConfiguration.francaFile; 
		FModel fmodel = loader.loadModel(inputfile);
		assertNotNull(fmodel);
		System.out.println("Franca IDL: package '" + fmodel.getName() + "'");
		
		// generate code from first interface in Franca model
		assertTrue(fmodel.getInterfaces().size()>0);
		FInterface api = fmodel.getInterfaces().get(0);
		ExampleHppGenerator generator = new ExampleHppGenerator();
		String code = generator.generateInterface(api).toString();
		System.out.println("Generated code:\n" + code);
	}

}
