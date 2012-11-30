package org.franca.examples.basic.tests;

import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;

import org.eclipse.xtext.junit4.InjectWith;
import org.eclipse.xtext.junit4.XtextRunner;
import org.franca.core.dsl.FrancaIDLInjectorProvider;
import org.franca.core.dsl.FrancaPersistenceManager;
import org.franca.core.franca.FModel;
import org.franca.generators.FrancaGenerators;
import org.junit.Test;
import org.junit.runner.RunWith;

import com.google.inject.Inject;

/**
 * Testcase for the Franca=>HTML transformation toolchain.
 * 
 * @author kbirken
 *
 */
@RunWith(XtextRunner.class)
@InjectWith(FrancaIDLInjectorProvider.class)
public class Franca2HtmlTest {

	@Inject
	FrancaPersistenceManager loader;
	
	@Test
	public void test() {
		System.out.println("*** Franca2HtmlTest");
		
		// load example Franca IDL interface
		String inputfile = "examples/" + TestConfiguration.francaFile; 
		FModel fmodel = loader.loadModel(inputfile);
		assertNotNull(fmodel);
		System.out.println("Franca IDL: package '" + fmodel.getName() + "'");
		
		// create HTML documentation from Franca model
		assertTrue(FrancaGenerators.instance().genHTML(fmodel, TestConfiguration.outputDir));
	}

}
