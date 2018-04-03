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
public class ModelDefinitionTests extends XtextTest {

	@Before
	public void before() {
		suppressSerialization();
	}

	@Test
	public void test_20_DefEmpty() {
		testFile("testcases/20-DefEmpty.fdepl",
				"fidl/01-EmptyInterface.fidl");
	}

	@Test
	public void test_24_DefDataPropertiesInteger() {
		testFile("testcases/24-DefDataPropertiesInteger.fdepl",
				"testcases/10-SpecPropertyIntegerTypes.fdepl",
				"fidl/05-CoverageInterface.fidl");
	}

	@Test
	public void test_25_DefDataPropertiesSimple() {
		testFile("testcases/25-DefDataPropertiesSimple.fdepl",
				"testcases/10-SpecPropertySimpleTypes.fdepl",
				"fidl/05-CoverageInterface.fidl");
	}

	@Test
	public void test_26_DefDataPropertiesArray() {
		testFile("testcases/26-DefDataPropertiesArray.fdepl", 
				"testcases/11-SpecPropertyArrayTypes.fdepl",
				"fidl/05-CoverageInterface.fidl");
	}

	@Test
	public void test_28_DefDataPropertiesCoverage() {
		testFile("testcases/28-DefDataPropertiesCoverage.fdepl",
				"testcases/03-SpecDataHostsSimple.fdepl",
				"fidl/05-CoverageInterface.fidl");
	}

	@Test
	public void test_29_DefDataPropertiesInlineArray() {
		testFile("testcases/29-DefDataPropertiesInlineArray.fdepl",
				"testcases/03-SpecDataHostsSimple.fdepl",
				"fidl/07-InlineArrayInterface.fidl");
	}

	@Test
	public void test_30_DefDataPropertiesInterfaceRef() {
		testFile("testcases/30-DefDataPropertiesInterfaceRef.fdepl",
				"testcases/12-SpecPropertyInterfaceRef.fdepl",
				"fidl/05-CoverageInterface.fidl");
	}

	@Test
	public void test_35_DefDataPropertiesInstance() {
		ExtensionRegistry.addExtension(new ProviderExtension());
		testFile("testcases/35-DefDataPropertiesInstance.fdepl",
				"testcases/18-SpecPropertyInstanceType.fdepl",
				"fidl/01-EmptyInterface.fidl");
		ExtensionRegistry.reset();
	}

	@Test
	public void test_42_DefTypeCollection() {
		testFile("testcases/42-DefTypeCollection.fdepl",
				"testcases/40-SpecSimple.fdepl",
				"fidl/10-TypeCollection.fidl");
	}

	@Test
	public void test_45_DefInterfaceWithUse() {
		testFile("testcases/45-DefInterfaceWithUse.fdepl",
				"testcases/40-SpecSimple.fdepl",
				"fidl/20-InterfaceUsingTC.fidl",
				"testcases/42-DefTypeCollection.fdepl");
	}

	@Test
	public void test_50_DefAnonTypeCollection() {
		testFile("testcases/50-DefAnonTypeCollection.fdepl",
				"testcases/40-SpecSimple.fdepl",
				"fidl/15-AnonTypeCollection.fidl");
	}

	@Test
	public void test_52_DefInterfaceWithUseAnon() {
		testFile("testcases/52-DefInterfaceWithUseAnon.fdepl",
				"testcases/40-SpecSimple.fdepl",
				"testcases/50-DefAnonTypeCollection.fdepl",
				"fidl/25-InterfaceUsingAnonTC.fidl");
	}

	@Test
	public void test_80_DefInterfaceWithOverload() {
		testFile("testcases/80-DefInterfaceWithOverload.fdepl",
				"testcases/41-SpecSimple.fdepl",
				"fidl/40-InterfaceWithOverloading.fidl");
	}

	@Test
	public void test_90_DefKeywordClash() {
		testFile("testcases/90-DefKeywordClash.fdepl",
				"testcases/08-SpecDeplKeyword.fdepl",
				"fidl/80-InterfaceWithDeplKeywords.fidl");
	}

}

