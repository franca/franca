package org.franca.connectors.idl.tests;

import java.io.File;
import java.io.IOException;

import org.franca.connectors.idl.Franca2IdlConverter;
import org.junit.Test;

import com.google.common.base.Charsets;
import com.google.common.io.Files;

public class TestAttributes extends FileContentsComparator{
	@Test
	public void testAttributes() throws IOException{
		Franca2IdlConverter converter = new Franca2IdlConverter("testcases/model/TestAttributes.fidl");
		CharSequence generateContents = converter.generateContents();
		try {
			Files.write(generateContents, new File("testcases/testResult/TestAttributes.idl"), Charsets.UTF_8);
			
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		System.out.println(generateContents);
		compare("TestAttributes.idl");

	}

	

}
