package org.franca.deploymodel.dsl.tests;

import org.eclipse.emf.ecore.EPackage;
import org.eclipse.xtext.junit4.InjectWith;
import org.eclipselabs.xtext.utils.unittesting.XtextRunner2;
import org.eclipselabs.xtext.utils.unittesting.XtextTest;
import org.franca.deploymodel.dsl.FDeployTestsInjectorProvider;
import org.franca.deploymodel.dsl.fDeploy.FDeployPackage;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;
import org.junit.runner.RunWith;

@RunWith(XtextRunner2.class)
@InjectWith(FDeployTestsInjectorProvider.class)
public class ValidationRulesTest extends XtextTest {
    @BeforeClass
    public static void init() {
		EPackage.Registry.INSTANCE.put(FDeployPackage.eNS_URI, FDeployPackage.eINSTANCE);
    }

    @Before
    public void before() {
        suppressSerialization();
    }

    @Test
    public void test_10_DuplicateSpecName() {
    	testFile("validation/10-DuplicateSpecName.fdepl");
        assertConstraints(issues.errorsOnly().sizeIs(2));
        assertConstraints(issues.allOfThemContain("Duplicate specification name 'MySpec'"));
    }

}
