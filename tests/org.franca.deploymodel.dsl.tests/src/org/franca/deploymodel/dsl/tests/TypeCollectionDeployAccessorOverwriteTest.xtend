/*******************************************************************************
 * Copyright (c) 2015 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.deploymodel.dsl.tests

import org.eclipse.xtext.testing.InjectWith
import org.example.spec.SpecCompoundHostsRef.Enums.StringProp
import org.example.spec.SpecCompoundHostsRef.TypeCollectionPropertyAccessor
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.franca.core.franca.FStructType
import org.franca.core.franca.FTypeCollection
import org.franca.core.franca.FUnionType
import org.franca.deploymodel.core.FDeployedTypeCollection
import org.franca.deploymodel.dsl.FDeployTestsInjectorProvider
import org.franca.deploymodel.dsl.fDeploy.FDModel
import org.franca.deploymodel.dsl.fDeploy.FDTypes
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith

import static org.junit.Assert.*

import static extension org.franca.core.framework.FrancaHelpers.*

@RunWith(typeof(XtextRunner2_Franca))
@InjectWith(typeof(FDeployTestsInjectorProvider))
class TypeCollectionDeployAccessorOverwriteTest extends DeployAccessorTestBase {

	FTypeCollection tc
	TypeCollectionPropertyAccessor accessor
	
	@Before
	def void setup() {
		val root = loadModel(
			"testcases/66-DefCompoundOverwrite.fdepl",
			"fidl/31-TypeCollectionUsingCompounds.fidl"
		);

		val model = root as FDModel
		assertFalse(model.deployments.empty)
		
		val first = model.deployments.get(0) as FDTypes
		val deployed = new FDeployedTypeCollection(first)
		accessor = new TypeCollectionPropertyAccessor(deployed)
		tc = first.target
	}

	
	@Test
	def void test_66DefCompoundOverwrite_StructA() {
		val type = tc.types.get(0)
		assertTrue(type instanceof FStructType)
		val structA = type as FStructType

		checkStructA(structA, accessor, null,
			0, 0, StringProp.p,
			0, StringProp.p, 0
		)
	}

	@Test
	def void test_66DefCompoundOverwrite_StructB() {
		// get struct fields
		val type = tc.types.get(1)
		assertTrue(type instanceof FStructType)
		val structB = type as FStructType
		assertEquals("StructB", structB.name)
		assertEquals(3, structB.elements.size)
		val field1 = structB.elements.get(0)
		val nested1 = structB.elements.get(1)
		val nested2 = structB.elements.get(2)

		// check field 'field1'
		assertEquals(StringProp.u, accessor.getStringProp(field1))
		assertEquals(11, accessor.getSFieldProp(field1))
		
		// check field 'nested1'
		assertEquals(12, accessor.getSFieldProp(nested1))
		val typeA1 = nested1.type.actualDerived
		assertTrue(typeA1 instanceof FStructType)
		val structA1 = typeA1 as FStructType
		val acc1 = accessor.getOverwriteAccessor(nested1)
		checkStructA(structA1, accessor, acc1,
			15,
			16, StringProp.x,
			17, StringProp.y, 11
		)

		// check field 'nested2'
		assertEquals(12, accessor.getSFieldProp(nested2))
		assertEquals(0, accessor.getArrayProp(nested2))
		val typeA2 = nested2.type.actualDerived
		assertTrue(typeA2 instanceof FStructType)
		val structA2 = typeA2 as FStructType
		val acc2 = accessor.getOverwriteAccessor(nested2)
		checkStructA(structA2, accessor, acc2,
			25,
			26, StringProp.x,
			27, StringProp.z, 21
		)
	}

	@Test
	def void test_66DefCompoundOverwrite_StructC() {
		// get struct fields
		val type = tc.types.get(4)
		assertTrue(type instanceof FStructType)
		val structC = type as FStructType
		assertEquals("StructC", structC.name)
		assertEquals(333, accessor.getStructProp(structC))
		assertEquals(1, structC.elements.size)
		val nested1 = structC.elements.get(0)

		// check field 'nested1'
		val typeA = nested1.type.actualDerived
		assertTrue(typeA instanceof FUnionType)
		val unionA = typeA as FUnionType
		assertEquals("UnionA", typeA.name)
		assertEquals(1, unionA.elements.size)
		val field1 = unionA.elements.get(0)

		// access ignoring overwrites
		assertEquals(33301, accessor.getSFieldProp(nested1))
		assertEquals(StringProp.u, accessor.getStringProp(field1))
		assertEquals(0, accessor.getUFieldProp(field1))

		// access including overwrites (if any)
		val acc1 = accessor.getOverwriteAccessor(nested1)
		assertEquals(33301, acc1.getSFieldProp(nested1))
		assertEquals(StringProp.y, acc1.getStringProp(field1))
		assertEquals(33330, acc1.getUFieldProp(field1))
	}
	
}
