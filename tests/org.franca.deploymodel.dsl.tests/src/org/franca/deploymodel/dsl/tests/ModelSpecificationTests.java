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
public class ModelSpecificationTests extends XtextTest {

    @Before
    public void before() {
        suppressSerialization();
    }


    @Test
    public void test_01_SpecEmpty() {
    	testFile("testcases/01-SpecEmpty.fdepl");
    }

    @Test
    public void test_02_SpecDataHostsEmpty() {
    	testFile("testcases/02-SpecDataHostsEmpty.fdepl");
    }

    @Test
    public void test_03_SpecDataHostsSimple() {
    	testFile("testcases/03-SpecDataHostsSimple.fdepl");
    }

    @Test
    public void test_05_SpecInterfaceHostsEmpty() {
    	testFile("testcases/05-SpecInterfaceHostsEmpty.fdepl");
    }

    @Test
    public void test_06_SpecInterfaceHostsSimple() {
    	testFile("testcases/06-SpecInterfaceHostsSimple.fdepl");
    }

    @Test
    public void test_10_SpecPropertySimpleTypes() {
    	testFile("testcases/10-SpecPropertySimpleTypes.fdepl");
    }

    @Test
    public void test_11_SpecPropertyArrayTypes() {
    	testFile("testcases/11-SpecPropertyArrayTypes.fdepl");
    }

    @Test
    public void test_15_SpecInheritance() {
    	testFile("testcases/15-SpecInheritance.fdepl");
    }

}
