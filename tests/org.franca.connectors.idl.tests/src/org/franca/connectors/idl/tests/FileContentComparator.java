package org.franca.connectors.idl.tests;

import static org.junit.Assert.assertEquals;

import java.io.File;
import java.io.IOException;
import java.util.List;

import com.google.common.base.Charsets;
import com.google.common.io.Files;

public class FileContentComparator {
	private String expectedFilePath = "testcases/expectedResult/";
	private String generatedFilePath = "testcases/testResult/";
	public void compare(String TestCaseFileNmae){
		List<String> testResultFileContent = null;
		List<String> expectedFileContent = null;
		try {
			testResultFileContent = Files.readLines(new File(expectedFilePath+TestCaseFileNmae),Charsets.UTF_8);
			expectedFileContent = Files.readLines(new File(generatedFilePath+TestCaseFileNmae),Charsets.UTF_8);
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		assertEquals(testResultFileContent.size(), expectedFileContent.size());
		int i=0;
		while (i<testResultFileContent.size()) {
			String string = testResultFileContent.get(i);
			String string2 = expectedFileContent.get(i);
			boolean equals = string.trim().replaceAll("\\s+", " ").equals(string2.trim().replaceAll("\\s+", " "));
			assertEquals(equals, true);
			i++;
		}
		
	}

}
