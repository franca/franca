package org.franca.deploymodel.dsl.tests;

import org.eclipse.xtext.testing.InjectWith;
import org.franca.core.dsl.tests.util.XtextRunner2_Franca;
import org.franca.deploymodel.dsl.FDeployTestsInjectorProvider;
import org.franca.deploymodel.ext.providers.ProviderExtension;
import org.franca.deploymodel.extensions.ExtensionRegistry;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;

import com.itemis.xtext.testing.XtextTest;

@RunWith(XtextRunner2_Franca.class)
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
		ExtensionRegistry.addExtension(new ProviderExtension());
		testFile("testcases/05-SpecInterfaceHostsEmpty.fdepl");
		ExtensionRegistry.reset();
	}

	@Test
	public void test_06_SpecInterfaceHostsSimple() {
		ExtensionRegistry.addExtension(new ProviderExtension());
		testFile("testcases/06-SpecInterfaceHostsSimple.fdepl");
		ExtensionRegistry.reset();
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
	public void test_12_SpecPropertyInterfaceRef() {
		testFile("testcases/12-SpecPropertyInterfaceRef.fdepl",
				"fidl/01-EmptyInterface.fidl");
	}

	@Test
	public void test_15_SpecInheritance() {
		testFile("testcases/15-SpecInheritance.fdepl");
	}

	@Test
	public void test_40_SpecSimple() {
		testFile("testcases/40-SpecSimple.fdepl");
	}

	@Test
	public void test_41_SpecSimple() {
		testFile("testcases/41-SpecSimple.fdepl");
	}

}
