package org.franca.examples.webidl.tests;

import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;

import org.franca.connectors.webidl.WebIDLConnector;
import org.franca.connectors.webidl.WebIDLModelContainer;
import org.franca.core.dsl.FrancaIDLHelpers;
import org.franca.core.franca.FModel;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

/**
 * Test case for the WebIDL=>Franca transformation toolchain.
 * 
 * @author kbirken
 *
 */
public class WebIDL2FrancaTest {

	@Before
	public void setUp() throws Exception {
	}

	@After
	public void tearDown() throws Exception {
	}

	@Test
	public void test() {
		System.out.println("*** WebIDL2FrancaTest");
		
		// create WebIDL/Franca connector
		WebIDLConnector webidlConn = new WebIDLConnector();
		
		// load example WebIDL interface
		WebIDLModelContainer webidl = (WebIDLModelContainer) webidlConn.loadModel(TestConfiguration.webidlFile);
		assertNotNull(webidl);
		System.out.println("WebIDL: Loaded " + webidl.model().getDefinitions().size() + " definitions.");
		
		// transform to Franca interface and save it
		FModel fmodel = webidlConn.toFranca(webidl);
		
		assertTrue(FrancaIDLHelpers.instance().saveModel(fmodel, TestConfiguration.webidlFile.replaceFirst(
		      ".webidl", "." + FrancaIDLHelpers.instance().getFileExtension()), 
		      TestConfiguration.outputDir));

		
	}

}
