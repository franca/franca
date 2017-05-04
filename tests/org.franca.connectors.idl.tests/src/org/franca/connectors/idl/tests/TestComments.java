package org.franca.connectors.idl.tests;

import java.io.File;
import java.io.IOException;

import org.franca.connectors.idl.Franca2IdlConverter;
import org.franca.core.franca.FModel;
import org.junit.Test;

import com.google.common.base.Charsets;
import com.google.common.io.Files;


public class TestComments extends IdlTestBase {

	@Test
	public void testCommentsInterface() {
		testComments("TestCommentsInterface");
	}

	@Test
	public void testCommentsTypes() {
		testComments("TestCommentsTypes");
	}

	private void testComments(String basename) {
		FModel fmodel = loadModel("testcases/model/" + basename + ".fidl");
		Franca2IdlConverter converter = new Franca2IdlConverter();
		CharSequence generateContents = converter.generateAll(fmodel);
		try {
			Files.write(generateContents, new File("testcases/testResult/" + basename + ".idl"), Charsets.UTF_8);
			
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		System.out.println(generateContents);
		compare(basename + ".idl");
	}

}
