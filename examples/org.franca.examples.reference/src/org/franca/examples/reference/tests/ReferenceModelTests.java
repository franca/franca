package org.franca.examples.reference.tests;

import org.eclipse.xtext.testing.InjectWith;
import org.franca.core.dsl.FrancaIDLTestsInjectorProvider;
import org.franca.core.dsl.tests.util.XtextRunner2_Franca;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;

import com.itemis.xtext.testing.XtextTest;

@RunWith(XtextRunner2_Franca.class)
@InjectWith(FrancaIDLTestsInjectorProvider.class)
public class ReferenceModelTests extends XtextTest {

	private static final String REF_EXAMPLE_FRANCA_MODELS =
			"org/reference";

	@Before
    public void before() {
        suppressSerialization();
    }

	public ReferenceModelTests() {
		super(REF_EXAMPLE_FRANCA_MODELS);
	}

    @Test
    public void test_10_TypesInTypeCollection() {
    	testFile("10-TypesInTypeCollection.fidl");
    	handleEnumValueDeprecated(2);
    }

    @Test
    public void test_15_InterTypeCollection() {
    	testFile("15-InterTypeCollection.fidl");
    }

    @Test
    public void test_30_PrimitiveConstants() {
    	testFile("30-PrimitiveConstants.fidl");
    }

    @Test
    public void test_32_ComplexConstants() {
    	testFile("32-ComplexConstants.fidl");
    }

    @Test
    public void test_35_ComplexConstants() {
    	testFile("35-ImplicitArrayConstants.fidl");
    }

    @Test
    public void test_60_Interface() {
    	testFile("60-Interface.fidl");
    	assertConstraints(issues.nOfThemContain(14, "not covered by contract"));
    }

    @Test
    public void test_61_Interface() {
    	testFile("61-Interface.fidl");
    	handleEnumValueDeprecated(2);
    }

    @Test
    public void test_65_InterfaceUsingTypeCollection() {
    	testFile("65-InterfaceUsingTypeCollection.fidl");
    }

    @Test
    public void test_70_Overloading() {
    	testFile("70-Overloading.fidl");
    }

    @Test
    public void test_71_Overloading() {
    	testFile("71-Overloading.fidl");
    }

    @Test
    public void test_80_Contract() {
    	testFile("80-Contract.fidl");
    	assertConstraints(issues.nOfThemContain(2, "This transition's guard might overlap with other transitions with same trigger"));
    }


    private void handleEnumValueDeprecated(int n) {
    	// check that there _are_ a given number of "Deprecated" warnings.
    	// this will help us to adapt the testcases as soon as the deprecated phase is over.
    	assertConstraints(issues.nOfThemContain(n, "Deprecated"));
    }


}
