package org.franca.core.dsl.tests;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;

import org.eclipse.emf.common.util.URI;
import org.eclipse.xtext.junit4.InjectWith;
import org.eclipselabs.xtext.utils.unittesting.XtextRunner2;
import org.eclipselabs.xtext.utils.unittesting.XtextTest;
import org.franca.core.dsl.FrancaIDLTestsInjectorProvider;
import org.franca.core.dsl.FrancaPersistenceManager;
import org.franca.core.franca.FInterface;
import org.franca.core.franca.FModel;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;

import com.google.inject.Inject;

@RunWith(XtextRunner2.class)
@InjectWith(FrancaIDLTestsInjectorProvider.class)
public class MultiFileTests extends XtextTest {

	@Inject	FrancaPersistenceManager fidlLoader;
	
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
    	FModel fmodel = fidlLoader.loadModel("model/multifile/first1/model1_1.fidl");
    	assertInterfaceExtendsChain(fmodel, "Model0");
    }

    @Test
    public void test_1_1_loader() {
    	URI root = URI.createURI("classpath:/");
    	URI loc = URI.createFileURI("multifile/first1/model1_1.fidl");
    	FModel fmodel = fidlLoader.loadModel(loc, root);
    	assertInterfaceExtendsChain(fmodel, "Model0");
    }


    @Test
    public void test_1_2() {
    	testFile("multifile/first1/model1_2.fidl");
    }

    @Test
    public void test_1_2_loader_deprec() {
    	FModel fmodel = fidlLoader.loadModel("model/multifile/first1/model1_2.fidl");
    	assertInterfaceExtendsChain(fmodel, "Model0");
    }

    @Test
    public void test_1_2_loader() {
    	URI root = URI.createURI("classpath:/");
    	URI loc = URI.createFileURI("multifile/first1/model1_2.fidl");
    	FModel fmodel = fidlLoader.loadModel(loc, root);
    	assertInterfaceExtendsChain(fmodel, "Model0");
    }



    @Test
    public void test_1_3() {
    	testFile("multifile/first1/model1_3.fidl");
    }

    @Test
    public void test_1_3_loader_deprec() {
    	FModel fmodel = fidlLoader.loadModel("model/multifile/first1/model1_3.fidl");
    	assertInterfaceExtendsChain(fmodel, "Model0");
    }

    @Test
    public void test_1_3_loader() {
    	URI root = URI.createURI("classpath:/");
    	URI loc = URI.createFileURI("multifile/first1/model1_3.fidl");
    	FModel fmodel = fidlLoader.loadModel(loc, root);
    	assertInterfaceExtendsChain(fmodel, "Model0");
    }


    @Test
    public void test_1_4() {
    	testFile("multifile/first1/model1_4.fidl");
    }

    @Test
    public void test_1_4_loader_deprec() {
    	FModel fmodel = fidlLoader.loadModel("model/multifile/first1/model1_4.fidl");
    	assertInterfaceExtendsChain(fmodel, "Model0");
    }

    @Test
    public void test_1_4_loader() {
    	URI root = URI.createURI("classpath:/");
    	URI loc = URI.createFileURI("multifile/first1/model1_4.fidl");
    	FModel fmodel = fidlLoader.loadModel(loc, root);
    	assertInterfaceExtendsChain(fmodel, "Model0");
    }

    
    @Test
    public void test_1_5() {
    	testFile("multifile/first1/model1_5.fidl");
    }

    @Test
    public void test_1_5_loader_deprec() {
    	FModel fmodel = fidlLoader.loadModel("model/multifile/first1/model1_5.fidl");
    	assertInterfaceExtendsChain(fmodel, "Model0");
    }

    @Test
    public void test_1_5_loader() {
    	URI root = URI.createURI("classpath:/");
    	URI loc = URI.createFileURI("multifile/first1/model1_5.fidl");
    	FModel fmodel = fidlLoader.loadModel(loc, root);
    	assertInterfaceExtendsChain(fmodel, "Model0");
    }


    @Test
    public void test_2_2() {
    	testFile("multifile/first2/second1/model2_2.fidl");
    }

    @Test
    public void test_2_2_loader_deprec() {
    	FModel fmodel = fidlLoader.loadModel("model/multifile/first2/second1/model2_2.fidl");
    	assertInterfaceExtendsChain(fmodel, "Model1_2", "Model0");
    }

    @Test
    public void test_2_2_loader() {
    	URI root = URI.createURI("classpath:/");
    	URI loc = URI.createFileURI("multifile/first2/second1/model2_2.fidl");
    	FModel fmodel = fidlLoader.loadModel(loc, root);
    	assertInterfaceExtendsChain(fmodel, "Model1_2", "Model0");
    }

    
    @Test
    public void test_2_5() {
    	testFile("multifile/first2/second1/model2_5.fidl");
    }

    @Test
    public void test_2_5_loader_deprec() {
    	FModel fmodel = fidlLoader.loadModel("model/multifile/first2/second1/model2_5.fidl");
    	assertInterfaceExtendsChain(fmodel, "Model1_5", "Model0");
    }

    @Test
    public void test_2_5_loader() {
    	URI root = URI.createURI("classpath:/");
    	URI loc = URI.createFileURI("multifile/first2/second1/model2_5.fidl");
    	FModel fmodel = fidlLoader.loadModel(loc, root);
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
}
