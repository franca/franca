package org.franca.examples.basic.tests;

import static org.junit.Assert.*;

import org.franca.core.dsl.FrancaIDLHelpers;
import org.franca.core.franca.FInterface;
import org.franca.core.franca.FModel;
import org.franca.examples.basic.generators.ExampleHppGenerator;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

/**
 * Testcase for the example C++ header generator from Franca IDL interfaces.
 * 
 * @author kbirken
 *
 */
public class HppGeneratorTest {

	@Before
	public void setUp() throws Exception {
	}

	@After
	public void tearDown() throws Exception {
	}

	@Test
	public void test() {
		System.out.println("*** HppGeneratorTest");
		
		// load example Franca IDL interface
		String inputfile = "examples/" + TestConfiguration.francaFile; 
		FModel fmodel = FrancaIDLHelpers.instance().loadModel(inputfile);
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
