package org.franca.deploymodel.dsl.tests

import org.eclipse.xtext.junit4.InjectWith
import org.eclipselabs.xtext.utils.unittesting.XtextRunner2
import org.example.spec.SpecCompoundHostsRef.InterfacePropertyAccessor
import org.franca.core.franca.FArrayType
import org.franca.core.franca.FEnumerationType
import org.franca.core.franca.FInterface
import org.franca.deploymodel.core.FDeployedInterface
import org.franca.deploymodel.dsl.FDeployTestsInjectorProvider
import org.franca.deploymodel.dsl.fDeploy.FDInterface
import org.franca.deploymodel.dsl.fDeploy.FDModel
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith

import static org.junit.Assert.*

import static extension org.franca.core.framework.FrancaHelpers.*

@RunWith(typeof(XtextRunner2))
@InjectWith(typeof(FDeployTestsInjectorProvider))
class DeployAccessorTypesTest extends DeployAccessorTestBase {

	FInterface fidl
	InterfacePropertyAccessor accessor

	@Before
	def void setup() {
		val root = loadModel(
			"testcases/70-DefTypesOverwrite.fdepl",
			"fidl/35-InterfaceUsingTypes.fidl"
		);

		val model = root as FDModel
		assertFalse(model.deployments.empty)
		
		val first = model.deployments.get(0) as FDInterface
		val deployed = new FDeployedInterface(first)
		accessor = new InterfacePropertyAccessor(deployed)
		fidl = first.target
	}

	
	@Test
	def void test_70DefTypesOverwrite_attrA() {
		val attrA = fidl.attributes.get(1)
		assertEquals("attrA", attrA.name)
		assertEquals(120, accessor.getAttributeProp(attrA))

		val type = attrA.type.actualDerived
		assertTrue(type instanceof FArrayType)
		val arrayType = type as FArrayType
		
		// access ignoring overwrites
		assertEquals(20, accessor.getArrayProp(arrayType))
		
		// access including overwrites (there are none)
		val acc = accessor.getOverwriteAccessor(attrA)
		assertEquals(125, acc.getArrayProp(arrayType))
	}

	@Test
	def void test_70DefTypesOverwrite_attrE() {
		val attrE = fidl.attributes.get(2)
		assertEquals("attrE", attrE.name)
		assertEquals(130, accessor.getAttributeProp(attrE))

		val type = attrE.type.actualDerived
		assertTrue(type instanceof FEnumerationType)
		val enumerationType = type as FEnumerationType
		
		// access ignoring overwrites
		assertEquals(30, accessor.getEnumerationProp(enumerationType))
		
		// access including overwrites (there are none)
		val acc = accessor.getOverwriteAccessor(attrE)
		assertEquals(135, acc.getEnumerationProp(enumerationType))
	}

	// TODO: add more tests for other derived elements
}
