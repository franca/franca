package org.franca.connectors.omgidl.tests

import java.io.ByteArrayOutputStream
import java.io.File
import java.io.PrintStream
import org.franca.connectors.omgidl.OMGIDL2FrancaStandalone
import org.junit.Before
import org.junit.Ignore
import org.junit.Test

import static org.junit.Assert.*

class OMGIDLCommandLineTests {

//	@Before
//	def void setup() {
//		val cfg = new File(".", File.separatorChar+"log4j.properties")
//		println("cfg file exists? " + cfg.exists)
//		System.setProperty("log4j.configuration", cfg.toURL().toString)
//	}
	
	@Test
	@Ignore
	def void testOMGIDL2FrancaCommandLine_Help() {
		val String[] args = #{ "-h" }
		val output = doTest(args, 0)
		println("///" + output + "///")

		assertTrue(output.contains("Tool version"))
		assertTrue(output.contains("Franca IDL language version"))
		assertTrue(output.contains("usage: java -jar OMGIDL2FrancaStandalone.jar [OPTIONS]"))
	}

	@Test
	@Ignore
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
