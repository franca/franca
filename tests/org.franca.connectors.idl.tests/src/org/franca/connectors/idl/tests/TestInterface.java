package org.franca.connectors.idl.tests;

import static org.junit.Assert.assertEquals;

import java.io.File;
import java.io.IOException;
import java.util.List;

import org.franca.connectors.idl.Franca2IdlConverter;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.JUnit4;
import org.junit.runners.model.TestClass;

import com.google.common.base.Charsets;
import com.google.common.io.Files;

public class TestInterface extends FileContentsComparator{
	@Test
	public void testInterface() throws IOException{
		Franca2IdlConverter converter = new Franca2IdlConverter("testcases/model/TestInterface.fidl");
		CharSequence generateContents = converter.generateContents();
		try {
			Files.write(generateContents, new File("testcases/testResult/TestInterface.idl"), Charsets.UTF_8);
			
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		System.out.println(generateContents);
		compare("TestInterface.idl");

	}

	

}
