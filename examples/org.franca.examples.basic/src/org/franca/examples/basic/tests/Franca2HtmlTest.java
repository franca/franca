package org.franca.examples.basic.tests;

import static org.junit.Assert.*;

import org.franca.core.dsl.FrancaIDLHelpers;
import org.franca.core.franca.FModel;
import org.franca.generators.FrancaGenerators;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

/**
 * Testcase for the Franca=>HTML transformation toolchain.
 * 
 * @author kbirken
 *
 */
public class Franca2HtmlTest {

	@Before
	public void setUp() throws Exception {
	}

	@After
	public void tearDown() throws Exception {
	}

	@Test
	public void test() {
		System.out.println("*** Franca2HtmlTest");
		
		// load example Franca IDL interface
		String inputfile = "examples/" + TestConfiguration.francaFile; 
		FModel fmodel = FrancaIDLHelpers.instance().loadModel(inputfile);
		assertNotNull(fmodel);
		System.out.println("Franca IDL: package '" + fmodel.getName() + "'");
		
		// create HTML documentation from Franca model
		assertTrue(FrancaGenerators.instance().genHTML(fmodel, TestConfiguration.outputDir));
	}

}
