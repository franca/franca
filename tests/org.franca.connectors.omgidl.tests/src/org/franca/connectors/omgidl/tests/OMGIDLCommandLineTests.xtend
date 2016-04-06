package org.franca.connectors.omgidl.tests

import java.io.ByteArrayOutputStream
import java.io.PrintStream
import org.franca.connectors.omgidl.OMGIDL2FrancaStandalone
import org.junit.Test

import static org.junit.Assert.*

class OMGIDLCommandLineTests {
	
	@Test
	def void testOMGIDL2FrancaCommandLine_Help() {
		val String[] args = #{ "-h" }
		val output = doTest(args, 0)

		assertEquals(
			'''
				0    [main] INFO  tors.omgidl.OMGIDL2FrancaStandalone  - Tool version 0.1.0, Franca IDL language version 3.0
				usage: java -jar OMGIDL2FrancaStandalone.jar [OPTIONS]
				 -h                      Print usage information
				 -o <output directory>   Directory where the generated files will be
				                         stored
				 -v                      Activate verbose mode
			'''.toString,
			output
		)
	}
	
	@Test
	def void testOMGIDL2FrancaCommandLine_TransformVerbose() {
		val String[] args = #{ "-v", "-osrc-gen/commandline", "model/testcases/gate1/bn_t.idl" }
		val output = doTest(args, 0)
		println(output)

		assertTrue(output.contains("Input model consists of 2 files"))
		assertTrue(output.contains("Saved Franca IDL file 'src-gen/commandline/bn_t.fidl'."))
	}
	

	def private String doTest(String[] args, int expectedExitCode) {
		// redirect stdout in order to capture it
		val stdout = new ByteArrayOutputStream
		val stdoutOrig = System.out
		System.setOut(new PrintStream(stdout));

		// activate test mode
		OMGIDL2FrancaStandalone.setTestMode
		
		// execute command line tool
		OMGIDL2FrancaStandalone.main(args)
		
		// check return value
		assertEquals(expectedExitCode, OMGIDL2FrancaStandalone.getExitCode)
		
		// restore stdout
		System.setOut(stdoutOrig)
		
		// return console output
		stdout.toString
	}
}
