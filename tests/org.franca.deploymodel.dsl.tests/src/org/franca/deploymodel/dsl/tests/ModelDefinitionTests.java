package org.franca.deploymodel.dsl.tests;

import org.eclipse.emf.ecore.EPackage;
import org.eclipse.xtext.junit4.InjectWith;
import org.eclipselabs.xtext.utils.unittesting.XtextRunner2;
import org.eclipselabs.xtext.utils.unittesting.XtextTest;
import org.franca.core.franca.FrancaPackage;
import org.franca.deploymodel.dsl.FDeployTestsInjectorProvider;
import org.franca.deploymodel.dsl.fDeploy.FDeployPackage;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;
import org.junit.runner.RunWith;

@RunWith(XtextRunner2.class)
@InjectWith(FDeployTestsInjectorProvider.class)
public class ModelDefinitionTests extends XtextTest {

    @Before
    public void before() {
        suppressSerialization();
    }


    @Test
    public void test_20_DefEmpty() {
    	testFile("testcases/20-DefEmpty.fdepl", "fidl/01-EmptyInterface.fidl");
    }
}
