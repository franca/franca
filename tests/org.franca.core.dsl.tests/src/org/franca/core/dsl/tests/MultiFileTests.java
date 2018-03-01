package org.franca.core.dsl.tests;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;

import java.util.List;

import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.xtext.resource.IResourceServiceProvider;
import org.eclipse.xtext.testing.InjectWith;
import org.eclipse.xtext.validation.CheckMode;
import org.eclipse.xtext.validation.Issue;
import org.franca.core.dsl.FrancaIDLTestsInjectorProvider;
import org.franca.core.dsl.FrancaPersistenceManager;
import org.franca.core.dsl.tests.util.XtextRunner2_Franca;
import org.franca.core.franca.FInterface;
import org.franca.core.franca.FModel;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;

import com.google.inject.Inject;
import com.itemis.xtext.testing.XtextTest;

@RunWith(XtextRunner2_Franca.class)
@InjectWith(FrancaIDLTestsInjectorProvider.class)
public class MultiFileTests extends XtextTest {

	@Inject
	private FrancaPersistenceManager fidlLoader;
    @Inject
    private IResourceServiceProvider.Registry serviceProviderRegistry;

    @Before
    public void before() {
        suppressSerialization();
    }

    @Test
    public void test_1_1() {
    	testFile("multifile/first1/model1_1.fidl");
    }

    @Test
    public void test_1_1_loader_deprec() {
    	@SuppressWarnings("deprecation")
		FModel fmodel = fidlLoader.loadModel("model/multifile/first1/model1_1.fidl");
    	validate(fmodel,0);
    	assertInterfaceExtendsChain(fmodel, "Model0");
    }

    @Test
    public void test_1_1_loader() {
    	URI root = URI.createURI("classpath:/");
    	URI loc = URI.createFileURI("multifile/first1/model1_1.fidl");
    	FModel fmodel = fidlLoader.loadModel(loc, root);
    	validate(fmodel,0);
    	assertInterfaceExtendsChain(fmodel, "Model0");
    }


    @Test
    public void test_1_2() {
    	testFile("multifile/first1/model1_2.fidl");
    }

    @Test
    public void test_1_2_loader_deprec() {
    	@SuppressWarnings("deprecation")
		FModel fmodel = fidlLoader.loadModel("model/multifile/first1/model1_2.fidl");
    	validate(fmodel,0);
    	assertInterfaceExtendsChain(fmodel, "Model0");
   }

    @Test
    public void test_1_2_loader() {
    	URI root = URI.createURI("classpath:/");
    	URI loc = URI.createFileURI("multifile/first1/model1_2.fidl");
    	FModel fmodel = fidlLoader.loadModel(loc, root);
    	validate(fmodel,0);
    	assertInterfaceExtendsChain(fmodel, "Model0");
    }



    @Test
    public void test_1_3() {
    	testFile("multifile/first1/model1_3.fidl");
    }

    @Test
    public void test_1_3_loader_deprec() {
    	@SuppressWarnings("deprecation")
		FModel fmodel = fidlLoader.loadModel("model/multifile/first1/model1_3.fidl");
    	validate(fmodel,0);
    	assertInterfaceExtendsChain(fmodel, "Model0");
    }

    @Test
    public void test_1_3_loader() {
    	URI root = URI.createURI("classpath:/");
    	URI loc = URI.createFileURI("multifile/first1/model1_3.fidl");
    	FModel fmodel = fidlLoader.loadModel(loc, root);
    	validate(fmodel,0);
    	assertInterfaceExtendsChain(fmodel, "Model0");
    }


    @Test
    public void test_1_4() {
    	testFile("multifile/first1/model1_4.fidl");
    }

    @Test
    public void test_1_4_loader_deprec() {
    	@SuppressWarnings("deprecation")
		FModel fmodel = fidlLoader.loadModel("model/multifile/first1/model1_4.fidl");
    	validate(fmodel,0);
    	assertInterfaceExtendsChain(fmodel, "Model0");
    }

    @Test
    public void test_1_4_loader() {
    	URI root = URI.createURI("classpath:/");
    	URI loc = URI.createFileURI("multifile/first1/model1_4.fidl");
    	FModel fmodel = fidlLoader.loadModel(loc, root);
    	validate(fmodel,0);
    	assertInterfaceExtendsChain(fmodel, "Model0");
    }

    
    @Test
    public void test_1_5() {
    	testFile("multifile/first1/model1_5.fidl");
    }

    @Test
    public void test_1_5_loader_deprec() {
    	@SuppressWarnings("deprecation")
		FModel fmodel = fidlLoader.loadModel("model/multifile/first1/model1_5.fidl");
    	validate(fmodel,0);
    	assertInterfaceExtendsChain(fmodel, "Model0");
    }

    @Test
    public void test_1_5_loader() {
    	URI root = URI.createURI("classpath:/");
    	URI loc = URI.createFileURI("multifile/first1/model1_5.fidl");
    	FModel fmodel = fidlLoader.loadModel(loc, root);
    	validate(fmodel,0);
    	assertInterfaceExtendsChain(fmodel, "Model0");
    }


    @Test
    public void test_2_2() {
    	testFile("multifile/first2/second1/model2_2.fidl");
    }

    @Test
    public void test_2_2_loader_deprec() {
    	@SuppressWarnings("deprecation")
		FModel fmodel = fidlLoader.loadModel("model/multifile/first2/second1/model2_2.fidl");
    	validate(fmodel,0);
    	assertInterfaceExtendsChain(fmodel, "Model1_2", "Model0");
    }

    @Test
    public void test_2_2_loader() {
    	URI root = URI.createURI("classpath:/");
    	URI loc = URI.createFileURI("multifile/first2/second1/model2_2.fidl");
    	FModel fmodel = fidlLoader.loadModel(loc, root);
    	validate(fmodel,0);
    	assertInterfaceExtendsChain(fmodel, "Model1_2", "Model0");
    }

    @Test
    public void test_2_5() {
    	testFile("multifile/first2/second1/model2_5.fidl");
    }

    @Test
    public void test_2_5_loader_deprec() {
    	@SuppressWarnings("deprecation")
		FModel fmodel = fidlLoader.loadModel("model/multifile/first2/second1/model2_5.fidl");
    	validate(fmodel,0);
    	assertInterfaceExtendsChain(fmodel, "Model1_5", "Model0");
    }

    @Test
    public void test_2_5_loader() {
    	URI root = URI.createURI("classpath:/");
    	URI loc = URI.createFileURI("multifile/first2/second1/model2_5.fidl");
    	FModel fmodel = fidlLoader.loadModel(loc, root);
    	validate(fmodel,0);
    	assertInterfaceExtendsChain(fmodel, "Model1_5", "Model0");
    }

    
    private void assertInterfaceExtendsChain(FModel fmodel, String... basenames) {
    	assertEquals(fmodel.getInterfaces().size(), 1);
    	FInterface i = fmodel.getInterfaces().get(0);
    	
    	// check extends-chain for this interface
    	for(String basename : basenames) {
        	i = i.getBase();
        	assertNotNull(i);
        	assertEquals(i.getName(), basename);
    	}
    }
    
    
    private void validate (FModel fmodel, int expectedErrorCount) {
		Resource res = fmodel.eResource();
		IResourceServiceProvider provider = serviceProviderRegistry
				.getResourceServiceProvider(res.getURI());
		List<Issue> result = provider.getResourceValidator().validate(res,
				CheckMode.ALL, null);
		for(Issue issue : result) {
			String line = issue.getLineNumber()==null ? "" : " (line " + issue.getLineNumber() + ")";
			String text = issue.getSeverity() + line + ": " + issue.getMessage();
			System.out.println("Validation issue: " + text);
		}
    	assertEquals(expectedErrorCount, result.size());
    }
}
