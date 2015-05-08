package org.franca.deploymodel.dsl.tests

import org.eclipse.xtext.junit4.InjectWith
import org.eclipselabs.xtext.utils.unittesting.XtextRunner2
import org.example.spec.SpecCompoundHostsRef.InterfacePropertyAccessor
import org.example.spec.SpecCompoundHostsRef.Enums.StringProp
import org.example.spec.SpecCompoundHostsRef.Enums.StringEnumArrayProp
import org.franca.core.franca.FArrayType
import org.franca.core.franca.FEnumerationType
import org.franca.core.franca.FInterface
import org.franca.core.franca.FStructType
import org.franca.core.franca.FUnionType
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
	def void test_70DefTypesOverwrite_attrB() {
		val attrB = fidl.attributes.get(0)
		assertEquals("attrB", attrB.name)
		assertEquals(110, accessor.getAttributeProp(attrB))

		assertEquals(StringProp.v, accessor.getStringProp(attrB))
		assertEquals(#[ 2, 3, 5, 7 ], accessor.getStringIntArrayProp(attrB))
		assertEquals(
			#[
				StringEnumArrayProp.b,
				StringEnumArrayProp.a,
				StringEnumArrayProp.c
			],
			accessor.getStringEnumArrayProp(attrB)
		)
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
		val e1 = enumerationType.enumerators.get(0)
		val e2 = enumerationType.enumerators.get(1)
		val e3 = enumerationType.enumerators.get(2)
		
		// access ignoring overwrites
		assertEquals(30, accessor.getEnumerationProp(enumerationType))
		assertEquals(35, accessor.getEnumeratorProp(e1))
		assertEquals(36, accessor.getEnumeratorProp(e2))
		assertEquals(37, accessor.getEnumeratorProp(e3))
		
		// access including overwrites (there are none)
		val acc = accessor.getOverwriteAccessor(attrE)
		assertEquals(135, acc.getEnumerationProp(enumerationType))
		assertEquals(136, acc.getEnumeratorProp(e1))
		assertEquals(36, acc.getEnumeratorProp(e2))
		assertEquals(37, acc.getEnumeratorProp(e3))
	}

	@Test
	def void test_70DefTypesOverwrite_attrS() {
		val attrS = fidl.attributes.get(3)
		assertEquals("attrS", attrS.name)
		assertEquals(140, accessor.getAttributeProp(attrS))

		val type = attrS.type.actualDerived
		assertTrue(type instanceof FStructType)
		val structType = type as FStructType
		val f1 = structType.elements.get(0)
		val f2 = structType.elements.get(1)
		val f3 = structType.elements.get(2)
		
		// access ignoring overwrites
		assertEquals(40, accessor.getStructProp(structType))
		assertEquals(45, accessor.getSFieldProp(f1))
		assertEquals(46, accessor.getSFieldProp(f2))
		assertEquals(47, accessor.getSFieldProp(f3))
		assertEquals(#[ 10, 20, 30 ], accessor.getStringIntArrayProp(f2))
		assertEquals(
			#[
				StringEnumArrayProp.b,
				StringEnumArrayProp.a
			],
			accessor.getStringEnumArrayProp(f2)
		)
		assertEquals(#[ 11, 22, 33 ], accessor.getStringIntArrayProp(f3))
		assertEquals(
			#[
				StringEnumArrayProp.c,
				StringEnumArrayProp.a
			],
			accessor.getStringEnumArrayProp(f3)
		)
		
		// access including overwrites (there are none)
		val acc = accessor.getOverwriteAccessor(attrS)
		assertEquals(145, acc.getStructProp(structType))
		assertEquals(146, acc.getSFieldProp(f1))
		assertEquals(46, acc.getSFieldProp(f2))
		assertEquals(47, acc.getSFieldProp(f3))
		assertEquals(#[ 2, 4, 8, 16 ], acc.getStringIntArrayProp(f2))
		assertEquals(
			#[
				StringEnumArrayProp.a,
				StringEnumArrayProp.b,
				StringEnumArrayProp.b,
				StringEnumArrayProp.a
			],
			acc.getStringEnumArrayProp(f2)
		)
		assertEquals(#[ 11, 22, 33 ], acc.getStringIntArrayProp(f3))
		assertEquals(
			#[
				StringEnumArrayProp.c,
				StringEnumArrayProp.a
			],
			acc.getStringEnumArrayProp(f3)
		)
	}

	@Test
	def void test_70DefTypesOverwrite_attrU() {
		val attrU = fidl.attributes.get(4)
		assertEquals("attrU", attrU.name)
		assertEquals(150, accessor.getAttributeProp(attrU))

		val type = attrU.type.actualDerived
		assertTrue(type instanceof FUnionType)
		val unionType = type as FUnionType
		val f1 = unionType.elements.get(0)
		val f2 = unionType.elements.get(1)
		
		// access ignoring overwrites
		assertEquals(50, accessor.getUnionProp(unionType))
		assertEquals(55, accessor.getUFieldProp(f1))
		assertEquals(56, accessor.getUFieldProp(f2))
		assertEquals(StringProp.q, accessor.getStringProp(f2))
		
		// access including overwrites (there are none)
		val acc = accessor.getOverwriteAccessor(attrU)
		assertEquals(151, acc.getUnionProp(unionType))
		assertEquals(155, acc.getUFieldProp(f1))
		assertEquals(56, acc.getUFieldProp(f2))
		assertEquals(StringProp.t, acc.getStringProp(f2))
	}

	// TODO: add more tests for other derived elements
}
