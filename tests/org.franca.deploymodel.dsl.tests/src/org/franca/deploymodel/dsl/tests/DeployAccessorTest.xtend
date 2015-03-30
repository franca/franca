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
import org.franca.core.franca.FField
import org.example.spec.ISpecCompoundHostsDataPropertyAccessor

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
		val acc = accessor.getOverwriteAccessor(attr1)
		assertEquals(StringProp.u, acc.getStringProp(attr1))
	}

	@Test
	def void test_65DefCompoundOverwrite_attr2() {
		val attr2 = fidl.attributes.get(1)
		assertEquals(2, accessor.getAttributeProp(attr2))

		// get struct fields
		val type = attr2.type.actualDerived
		assertTrue(type instanceof FStructType)
		val struct = type as FStructType
		assertEquals(3, struct.elements.size)
		val field1 = struct.elements.get(0)
		val field2 = struct.elements.get(1)
		val field3 = struct.elements.get(2)

		// access property on struct level (cannot be overwritten)
		assertEquals(111, accessor.getStructProp(type))
				
		// local accessor is needed for accessing overwritten properties
		val acc = accessor.getOverwriteAccessor(attr2)
		checkStructA(field1, field2, field3, acc,
			10,
			20, StringProp.v,
			30, StringProp.v, 7
		)
	}


	@Test
	def void test_65DefCompoundOverwrite_attr3() {
		val attr3 = fidl.attributes.get(2)
		assertEquals(3, accessor.getAttributeProp(attr3))

		// get struct fields
		val type = attr3.type.actualDerived
		assertTrue(type instanceof FStructType)
		val struct = type as FStructType
		assertEquals(3, struct.elements.size)
		val field1 = struct.elements.get(0)
		val nested1 = struct.elements.get(1)
		val nested2 = struct.elements.get(2)
				
		// access property on struct level (cannot be overwritten)
		assertEquals(222, accessor.getStructProp(type))
				
		// access ignoring overwrites
		assertEquals(StringProp.u, accessor.getStringProp(field1))
		assertEquals(11, accessor.getSFieldProp(field1))

		assertEquals(12, accessor.getSFieldProp(nested1))
		
		assertEquals(0, accessor.getArrayProp(nested2))
		assertEquals(12, accessor.getSFieldProp(nested2))

		
		// access including overwrites (if any)
		val acc = accessor.getOverwriteAccessor(attr3)
		assertEquals(StringProp.v, acc.getStringProp(field1))
		assertEquals(10, acc.getSFieldProp(field1))

		assertEquals(20, acc.getSFieldProp(nested1))
		checkNested1(nested1, acc);

		assertEquals(66, acc.getArrayProp(nested2))
		assertEquals(12, acc.getSFieldProp(nested2)) // not overwritten
		// TODO: checkNested2
	}

	
	def private checkStructA(
		FField f1, FField f2, FField f3,
		ISpecCompoundHostsDataPropertyAccessor acc,
		Integer pSField1,
		Integer pSField2, StringProp pString2,
		Integer pSField3, StringProp pString3, Integer pArray3
	) {
		// access ignoring overwrites
		assertEquals(1, accessor.getSFieldProp(f1))
		assertEquals(2, accessor.getSFieldProp(f2))
		assertEquals(StringProp.u, accessor.getStringProp(f2))
		assertEquals(3, accessor.getSFieldProp(f3))
		assertEquals(StringProp.u, accessor.getStringProp(f3))
		assertEquals(0, accessor.getArrayProp(f3))
		
		// access including overwrites (if any)
		assertEquals(pSField1, acc.getSFieldProp(f1))
		assertEquals(pSField2, acc.getSFieldProp(f2))
		assertEquals(pString2, acc.getStringProp(f2))
		assertEquals(pSField3, acc.getSFieldProp(f3))
		assertEquals(pString3, acc.getStringProp(f3))
		assertEquals(pArray3, acc.getArrayProp(f3))
	}


	def private checkNested1(FField nested1, ISpecCompoundHostsDataPropertyAccessor acc) {
		// get struct fields
		val type = nested1.type.actualDerived
		assertTrue(type instanceof FStructType)
		val struct = type as FStructType
		assertEquals("StructA", struct.name)
		assertEquals(3, struct.elements.size)
		val field1 = struct.elements.get(0)
		val field2 = struct.elements.get(1)
		val field3 = struct.elements.get(2)
		
		// local accessor acc1 will access overwritten properties in
		// deployment definition of StructB (as nested1 is a member of StructB)
		val acc1 = accessor.getOverwriteAccessor(nested1)
		checkStructA(field1, field2, field3, acc1,
			15,
			16, StringProp.x, 
			17, StringProp.y, 11
		)
		
		// local accessor acc2 will access overwritten properties in
		// deployment definition of attr3 (as acc is the overwrite accessor of attr3)
		val acc2 = acc.getOverwriteAccessor(nested1)
		checkStructA(field1, field2, field3, acc2,
			11,
			21, StringProp.w, 
			31, StringProp.w, 88
		)
		
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
