package org.franca.connectors.idl.tests;

import java.io.File;
import java.io.IOException;

import org.franca.connectors.idl.Franca2IdlConverter;
import org.franca.core.franca.FModel;
import org.junit.Test;

import com.google.common.base.Charsets;
import com.google.common.io.Files;

public class TestTypeCollection extends IdlTestBase {

	@Test
	public void testTypeCollection() throws IOException{
		FModel fmodel = loadModel("testcases/model/TestTypeCollection.fidl");
		Franca2IdlConverter converter = new Franca2IdlConverter();
		CharSequence generateContents = converter.generateAll(fmodel);
		try {
			Files.write(generateContents, new File("testcases/testResult/TestTypeCollection.idl"), Charsets.UTF_8);
			
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		System.out.println(generateContents);
		compare("TestTypeCollection.idl");
	}

}
 