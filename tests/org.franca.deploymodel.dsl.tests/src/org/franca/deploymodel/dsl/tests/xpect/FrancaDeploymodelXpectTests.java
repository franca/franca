package org.franca.deploymodel.dsl.tests.xpect;

import java.util.ArrayList;
import java.util.List;

import org.eclipse.xtext.XtextStandaloneSetup;
import org.eclipse.xtext.resource.XtextResource;
import org.eclipse.xtext.validation.Issue;
import org.franca.deploymodel.dsl.tests.xpect.util.FDeployXpectRunner;
import org.junit.runner.RunWith;
import org.xpect.expectation.ILinesExpectation;
import org.xpect.expectation.LinesExpectation;
import org.xpect.runner.Xpect;
import org.xpect.runner.XpectTestFiles;
import org.xpect.setup.XpectSetup;
import org.xpect.xtext.lib.setup.ThisOffset;
import org.xpect.xtext.lib.setup.ThisResource;
import org.xpect.xtext.lib.tests.ValidationTestModuleSetup.IssuesByLine;
import org.xpect.xtext.lib.tests.XtextTests;

import com.google.common.collect.Multimap;

@RunWith(FDeployXpectRunner.class)
@XpectTestFiles(files={"SpecNameValidationTest.fdepl.xt", "PropDeclClashValidationTest.fdepl.xt"})
@XpectSetup({ XtextStandaloneSetup.class })
public class FrancaDeploymodelXpectTests extends XtextTests {
	@Xpect
	public void lineErrors(@LinesExpectation ILinesExpectation expectation, @ThisResource XtextResource resource, 
			@IssuesByLine Multimap<Integer, Issue> line2issue,  @ThisOffset int offset) {
		List<String> formattedIssues = new ArrayList<String>();
		for (Issue issue : line2issue.get(offset)) {
			formattedIssues.add("\"" + issue.getMessage() + "\"");
		}

		expectation.assertEquals(formattedIssues);
	}

}
