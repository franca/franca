package org.franca.core.dsl.tests;

import org.eclipse.emf.codegen.ecore.genmodel.GenModelPackage;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EPackage;
import org.eclipse.emf.ecore.plugin.EcorePlugin;
import org.eclipse.xtext.junit4.InjectWith;
import org.franca.core.dsl.FrancaIDLTestsInjectorProvider;
import org.eclipselabs.xtext.utils.unittesting.XtextRunner2;
import org.eclipselabs.xtext.utils.unittesting.XtextTest;
import org.junit.Before;
import org.junit.Ignore;
import org.junit.Test;
import org.junit.runner.RunWith;


@RunWith(XtextRunner2.class)
@InjectWith(FrancaIDLTestsInjectorProvider.class)
public class ValidationRulesTest extends XtextTest {
    @Before
    public void before() {
        super.before();
        suppressSerialization();
        EPackage.Registry.INSTANCE.put(GenModelPackage.eNS_URI, GenModelPackage.eINSTANCE);
    }

    @Test
    public void test_10_DuplicateArrayName() {
    	testFile("validation/10-DuplicateArrayName.fidl");
        assertConstraints(issues.errorsOnly().sizeIs(2));
        assertConstraints(issues.allOfThemContain("Duplicate type name 'MyArray'"));
    }

}
