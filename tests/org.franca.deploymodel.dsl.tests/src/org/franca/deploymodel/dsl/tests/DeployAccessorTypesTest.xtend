/*******************************************************************************
 * Copyright (c) 2015 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.deploymodel.dsl.tests

import org.eclipse.xtext.testing.InjectWith
import org.example.spec.SpecCompoundHostsRef.Enums.StringEnumArrayProp
import org.example.spec.SpecCompoundHostsRef.Enums.StringProp
import org.example.spec.SpecCompoundHostsRef.InterfacePropertyAccessor
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.franca.core.franca.FArrayType
import org.franca.core.franca.FEnumerationType
import org.franca.core.franca.FInterface
import org.franca.core.franca.FStructType
import org.franca.core.franca.FTypeDef
import org.franca.core.franca.FTypeRef
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

@RunWith(typeof(XtextRunner2_Franca))
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
	def void test_70DefTypesOverwrite_typedef() {
		val typedefs = fidl.types.filter(FTypeDef)
		assertEquals(1, typedefs.size)

		val typedef1 = typedefs.get(0)
		assertEquals(90, accessor.getTypedefProp(typedef1))
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
		
		// access including overwrites
		val acc = accessor.getOverwriteAccessor(attrA)
		assertEquals(125, acc.getArrayProp(arrayType))
	}

	@Test
	def void test_70DefTypesOverwrite_attrE() {
		val attrE = fidl.attributes.get(2)
		assertEquals("attrE", attrE.name)
		assertEquals(130, accessor.getAttributeProp(attrE))

		// access ignoring overwrites
		val enumerationType = attrE.type.checkEnumeration
		val e1 = enumerationType.enumerators.get(0)
		val e2 = enumerationType.enumerators.get(1)
		val e3 = enumerationType.enumerators.get(2)
		
		// access including overwrites
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
		
		// access including overwrites
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

		// access ignoring overwrites
		val unionType = attrU.type.checkUnion
		val f1 = unionType.elements.get(0)
		val f2 = unionType.elements.get(1)
		
		// access including overwrites
		val acc = accessor.getOverwriteAccessor(attrU)
		assertEquals(151, acc.getUnionProp(unionType))
		assertEquals(155, acc.getUFieldProp(f1))
		assertEquals(56, acc.getUFieldProp(f2))
		assertEquals(StringProp.t, acc.getStringProp(f2))
	}


	@Test
	def void test_70DefTypesOverwrite_method1_argB() {
		val m1 = fidl.methods.get(0)
		assertEquals("method1", m1.name)

		val arg = m1.inArgs.get(0)
		assertEquals("argB", arg.name)
		assertEquals(210, accessor.getArgumentProp(arg))

		// access ignoring overwrites
		assertEquals(StringProp.r, accessor.getStringProp(arg))

		// access including overwrites (there are none)
		val acc = accessor.getOverwriteAccessor(arg)
		assertEquals(StringProp.r, acc.getStringProp(arg))
	}

	@Test
	def void test_70DefTypesOverwrite_method1_argA() {
		val m1 = fidl.methods.get(0)
		assertEquals("method1", m1.name)

		val arg = m1.inArgs.get(1)
		assertEquals("argA", arg.name)
		assertEquals(220, accessor.getArgumentProp(arg))

		val type = arg.type.actualDerived
		assertTrue(type instanceof FArrayType)
		val arrayType = type as FArrayType

		// access ignoring overwrites
		assertEquals(20, accessor.getArrayProp(arrayType))

		// access including overwrites
		val acc = accessor.getOverwriteAccessor(arg)
		assertEquals(225, acc.getArrayProp(arrayType))
	}

	@Test
	def void test_70DefTypesOverwrite_method1_argE() {
		val m1 = fidl.methods.get(0)
		assertEquals("method1", m1.name)

		val arg = m1.inArgs.get(2)
		assertEquals("argE", arg.name)
		assertEquals(230, accessor.getArgumentProp(arg))

		// access ignoring overwrites
		val enumerationType = arg.type.checkEnumeration
		val e1 = enumerationType.enumerators.get(0)
		val e2 = enumerationType.enumerators.get(1)
		val e3 = enumerationType.enumerators.get(2)

		// access including overwrites
		val acc = accessor.getOverwriteAccessor(arg)
		assertEquals(235, acc.getEnumerationProp(enumerationType))
		assertEquals(35, acc.getEnumeratorProp(e1))
		assertEquals(236, acc.getEnumeratorProp(e2))
		assertEquals(37, acc.getEnumeratorProp(e3))
	}


	// arrays which overwrite properties of their element type 

	@Test
	def void test_70DefTypesOverwrite_arrayA() {
		val array = fidl.types.findFirst[name=="OtherArrayA"]
		assertNotNull(array)
		assertTrue(array instanceof FArrayType)

		val arrayType = array as FArrayType
		assertEquals(510, accessor.getArrayProp(arrayType))

		val elementType = arrayType.elementType.actualDerived
		assertTrue(elementType instanceof FArrayType)
		val arrayTypeElem = elementType as FArrayType

		// access ignoring overwrites
		assertEquals(20, accessor.getArrayProp(arrayTypeElem))

		// access including overwrites
		val acc = accessor.getOverwriteAccessor(arrayType)
		assertEquals(515, acc.getArrayProp(arrayTypeElem))
	}

	@Test
	def void test_70DefTypesOverwrite_arrayE() {
		val array = fidl.types.findFirst[name=="OtherArrayE"]
		assertNotNull(array)
		assertTrue(array instanceof FArrayType)

		val arrayType = array as FArrayType
		assertEquals(520, accessor.getArrayProp(arrayType))

		// access ignoring overwrites
		val enumerationType = arrayType.elementType.checkEnumeration
		val e1 = enumerationType.enumerators.get(0)
		val e2 = enumerationType.enumerators.get(1)
		val e3 = enumerationType.enumerators.get(2)

		// access including overwrites
		val acc = accessor.getOverwriteAccessor(arrayType)
		assertEquals(525, acc.getEnumerationProp(enumerationType))
		assertEquals(35, acc.getEnumeratorProp(e1))
		assertEquals(36, acc.getEnumeratorProp(e2))
		assertEquals(537, acc.getEnumeratorProp(e3))
	}


	// structs which overwrite properties of their fields' types 

	@Test
	def void test_70DefTypes_struct_fieldE() {
		val struct = fidl.types.findFirst[name=="OtherStruct"]
		assertNotNull(struct)
		assertTrue(struct instanceof FStructType)

		val structType = struct as FStructType
		assertEquals(600, accessor.getStructProp(structType))

		val field = structType.elements.get(2)
		assertEquals("fieldE", field.name)
		assertEquals(630, accessor.getSFieldProp(field))
				
		// access ignoring overwrites
		val enumerationType = field.type.checkEnumeration
		val e1 = enumerationType.enumerators.get(0)
		val e2 = enumerationType.enumerators.get(1)
		val e3 = enumerationType.enumerators.get(2)

		// access including overwrites
		val acc = accessor.getOverwriteAccessor(field)
		assertEquals(635, acc.getEnumerationProp(enumerationType))
		assertEquals(636, acc.getEnumeratorProp(e1))
		assertEquals(36, acc.getEnumeratorProp(e2))
		assertEquals(37, acc.getEnumeratorProp(e3))
	}

	@Test
	def void test_70DefTypes_struct_fieldU() {
		val struct = fidl.types.findFirst[name=="OtherStruct"]
		assertNotNull(struct)
		assertTrue(struct instanceof FStructType)

		val structType = struct as FStructType
		assertEquals(600, accessor.getStructProp(structType))

		val field = structType.elements.get(4)
		assertEquals("fieldU", field.name)
		assertEquals(650, accessor.getSFieldProp(field))
				
		// access ignoring overwrites
		val unionType = field.type.checkUnion
		val f1 = unionType.elements.get(0)
		val f2 = unionType.elements.get(1)
		
		// access including overwrites
		val acc = accessor.getOverwriteAccessor(field)
		assertEquals(655, acc.getUnionProp(unionType))
		assertEquals(656, acc.getUFieldProp(f1))
		assertEquals(56, acc.getUFieldProp(f2))
		assertEquals(StringProp.q, acc.getStringProp(f2))
	}
	
	
	// some helper functions
	
	def private FEnumerationType checkEnumeration(FTypeRef typeRef) {
		val type = typeRef.actualDerived
		assertNotNull(type)
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
		
		enumerationType
	}
	
	def private FUnionType checkUnion(FTypeRef typeRef) {
		val type = typeRef.actualDerived
		assertNotNull(type)
		assertTrue(type instanceof FUnionType)
		val unionType = type as FUnionType
		val f1 = unionType.elements.get(0)
		val f2 = unionType.elements.get(1)
		
		// access ignoring overwrites
		assertEquals(50, accessor.getUnionProp(unionType))
		assertEquals(55, accessor.getUFieldProp(f1))
		assertEquals(56, accessor.getUFieldProp(f2))
		assertEquals(StringProp.q, accessor.getStringProp(f2))

		unionType		
	}

}
