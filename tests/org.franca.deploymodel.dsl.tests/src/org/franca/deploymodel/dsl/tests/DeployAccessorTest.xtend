package org.franca.deploymodel.dsl.tests

import java.util.ArrayList
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.junit4.InjectWith
import org.eclipselabs.xtext.utils.unittesting.XtextRunner2
import org.eclipselabs.xtext.utils.unittesting.XtextTest
import org.example.spec.SpecCompoundHostsInterfacePropertyAccessorRef
import org.example.spec.ISpecCompoundHostsDataPropertyAccessor$StringProp
import org.franca.deploymodel.core.FDeployedInterface
import org.franca.deploymodel.dsl.FDeployTestsInjectorProvider
import org.junit.Test
import org.junit.runner.RunWith
import org.franca.deploymodel.dsl.fDeploy.FDModel

import static org.junit.Assert.*
import org.franca.deploymodel.dsl.fDeploy.FDInterface

import static extension org.franca.core.framework.FrancaHelpers.*
import org.franca.core.franca.FStructType
import org.junit.Before
import org.franca.core.franca.FInterface

@RunWith(typeof(XtextRunner2))
@InjectWith(typeof(FDeployTestsInjectorProvider))
class DeployAccessorTest extends XtextTest {

	SpecCompoundHostsInterfacePropertyAccessorRef accessor
	FInterface fidl
	
	@Before
	def void setup() {
		val root = loadModel(
			"testcases/65-DefCompoundOverwrite.fdepl",
			"fidl/30-InterfaceUsingCompounds.fidl"
		);

		val model = root as FDModel
		assertFalse(model.deployments.empty)
		
		val first = model.deployments.get(0) as FDInterface
		val deployed = new FDeployedInterface(first)
		accessor = new SpecCompoundHostsInterfacePropertyAccessorRef(deployed)
		fidl = first.target
	}

	
	@Test
	def void test_65DefCompoundOverwrite_attr1() {
		val attr1 = fidl.attributes.get(0)
		assertEquals(1, accessor.getAttributeProp(attr1))
		
		// access ignoring overwrites
		assertEquals(StringProp.u, accessor.getStringProp(attr1))
		
		// access including overwrites (there are none)
		val acc = accessor.getAttributeAccessor(attr1)
		assertEquals(StringProp.u, acc.getStringProp(attr1))
	}

	@Test
	def void test_65DefCompoundOverwrite_attr2() {
		val attr2 = fidl.attributes.get(1)
		assertEquals(1, accessor.getAttributeProp(attr2))

		// get struct fields
		val type = attr2.type.actualDerived
		assertTrue(type instanceof FStructType)
		val struct = type as FStructType
		assertEquals(3, struct.elements.size)
		val field1 = struct.elements.get(0)
		val field2 = struct.elements.get(1)
		val field3 = struct.elements.get(2)
				
		// access ignoring overwrites
		assertEquals(1, accessor.getSFieldProp(field1))
		assertEquals(2, accessor.getSFieldProp(field2))
		assertEquals(StringProp.u, accessor.getStringProp(field2))
		assertEquals(3, accessor.getSFieldProp(field3))
		assertEquals(StringProp.u, accessor.getStringProp(field3))
		assertEquals(0, accessor.getArrayProp(field3))
		
		// access including overwrites (if any)
		val acc = accessor.getAttributeAccessor(attr2)
		assertEquals(10, acc.getSFieldProp(field1))
		assertEquals(20, acc.getSFieldProp(field2))
		assertEquals(StringProp.v, acc.getStringProp(field2))
		assertEquals(30, acc.getSFieldProp(field3))
		assertEquals(StringProp.v, acc.getStringProp(field3))
		assertEquals(7, acc.getArrayProp(field3))
	}


	def private loadModel(String fileToTest, String... referencedResources) {
		val resList = new ArrayList(referencedResources);
		resList += fileToTest
		var EObject result = null
		for (res : resList) {
			val uri = URI::createURI(resourceRoot + "/" + res);
			result = loadModel(resourceSet, uri, getRootObjectType(uri));
		}
		result
	}

}
