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
import org.example.spec.SpecCompoundHostsRef.IDataPropertyAccessor
import org.example.spec.SpecCompoundHostsRef.InterfacePropertyAccessor
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.franca.core.franca.FField
import org.franca.core.franca.FInterface
import org.franca.core.franca.FStructType
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
class InterfaceDeployAccessorTest extends DeployAccessorTestBase {

	FInterface fidl
	InterfacePropertyAccessor accessor

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
		accessor = new InterfacePropertyAccessor(deployed)
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

		// access property on struct level (cannot be overwritten)
		assertEquals(111, accessor.getStructProp(struct))
				
		// local accessor is needed for accessing overwritten properties
		val acc = accessor.getOverwriteAccessor(attr2)
		assertEquals(222, acc.getStructProp(struct))
		checkStructA(struct, accessor, acc,
			10,
			20, StringProp.v,
			30, StringProp.v, 7
		)
	}

	@Test
	def void test_65DefCompoundOverwrite_attr3() {
		val attr3 = fidl.attributes.get(2)
		assertEquals(3, accessor.getAttributeProp(attr3))

		val acc = accessor.getOverwriteAccessor(attr3)
		checkStructB(attr3.type, acc)
	}

	@Test
	def void test_65DefCompoundOverwrite_method1_arg2() {
		val method1 = fidl.methods.get(0)
		assertEquals("method1", method1.name)
		assertEquals(2, method1.inArgs.size)
		val arg2 = method1.inArgs.get(1)
		assertEquals(102, accessor.getArgumentProp(arg2))

		// get struct fields
		val type = arg2.type.actualDerived
		assertTrue(type instanceof FStructType)
		val struct = type as FStructType

		// access property on struct level (cannot be overwritten)
		assertEquals(111, accessor.getStructProp(struct))
				
		// local accessor is needed for accessing overwritten properties
		val acc = accessor.getOverwriteAccessor(arg2)
		checkStructA(struct, accessor, acc,
			110,
			120, StringProp.p,
			130, StringProp.q, 107
		)
	}

	@Test
	def void test_65DefCompoundOverwrite_method2_arg2() {
		val method2 = fidl.methods.get(1)
		assertEquals("method2", method2.name)
		assertEquals(2, method2.outArgs.size)
		val arg2 = method2.outArgs.get(1)
		assertEquals(202, accessor.getArgumentProp(arg2))

		// get struct fields
		val type = arg2.type.actualDerived
		assertTrue(type instanceof FStructType)
		val struct = type as FStructType

		// access property on struct level (cannot be overwritten)
		assertEquals(111, accessor.getStructProp(struct))
				
		// local accessor is needed for accessing overwritten properties
		val acc = accessor.getOverwriteAccessor(arg2)
		checkStructA(struct, accessor, acc,
			210,
			220, StringProp.q,
			230, StringProp.r, 207
		)
	}

	@Test
	def void test_65DefCompoundOverwrite_method3_arg2() {
		val method3 = fidl.methods.get(2)
		assertEquals("method3", method3.name)
		assertEquals(2, method3.inArgs.size)
		val arg2 = method3.inArgs.get(1)
		assertEquals(302, accessor.getArgumentProp(arg2))
		
		val acc = accessor.getOverwriteAccessor(arg2)
		checkStructB(arg2.type, acc)
	}

	@Test
	def void test_65DefCompoundOverwrite_method4_arg1() {
		val method4 = fidl.methods.get(3)
		assertEquals("method4", method4.name)
		assertEquals(1, method4.inArgs.size)
		val arg1 = method4.inArgs.get(0)
		assertEquals(401, accessor.getArgumentProp(arg1))

		// get union fields
		val type = arg1.type.actualDerived
		assertTrue(type instanceof FUnionType)
		val union = type as FUnionType
		assertEquals(1, union.elements.size)
		val field1 = union.elements.get(0)

		// access property on union level (cannot be overwritten)
		assertEquals(111, accessor.getUnionProp(union))

		// local accessor is needed for accessing overwritten properties
		val acc = accessor.getOverwriteAccessor(arg1)
		assertEquals(51413, acc.getUnionProp(union))
		checkUnionA(field1, acc, 100, StringProp.v)				
	}

	@Test
	def void test_65DefCompoundOverwrite_method4_ret1() {
		val method4 = fidl.methods.get(3)
		assertEquals("method4", method4.name)
		assertEquals(2, method4.outArgs.size)
		val ret1 = method4.outArgs.get(0)
		assertEquals(401, accessor.getArgumentProp(ret1))

		// get union fields
		val type = ret1.type.actualDerived
		assertTrue(type instanceof FUnionType)
		val union = type as FUnionType
		assertEquals("UnionB", union.name)
		assertEquals(2, union.elements.size)
		val field1 = union.elements.get(0)
		val field2 = union.elements.get(1)

		// access property on union level (cannot be overwritten)
		assertEquals(222, accessor.getUnionProp(union))
				
		// access ignoring overwrites
		assertEquals(StringProp.r, accessor.getStringProp(field1))
		assertEquals(22201, accessor.getUFieldProp(field1))
		assertEquals(22202, accessor.getUFieldProp(field2))
		
		// access including overwrites (if any)
		val acc = accessor.getOverwriteAccessor(ret1)
		assertEquals(StringProp.w, acc.getStringProp(field1))
		assertEquals(4011, acc.getUFieldProp(field1))
		assertEquals(4012, acc.getUFieldProp(field2))

		// check nested overwrites
		val type2 = field2.type.actualDerived
		assertTrue(type2 instanceof FUnionType)
		val union2 = type2 as FUnionType
		assertEquals("UnionA", union2.name)
		assertEquals(1, union2.elements.size)
		val fieldA1 = union2.elements.get(0)
		
		// local accessor acc1 will access overwritten properties in
		// deployment definition of UnionB (as field2 is a member of UnionB)
		val acc1 = accessor.getOverwriteAccessor(field2)
		checkUnionA(fieldA1, acc1, 22220, StringProp.x) 
		
		// local accessor acc2 will access overwritten properties in
		// deployment definition of ret1 (as acc is the overwrite accessor of method4.ret1)
		val acc2 = acc.getOverwriteAccessor(field2)
		checkUnionA(fieldA1, acc2, 105, StringProp.w) 
	}
	
	@Test
	def void test_65DefCompoundOverwrite_method4_ret2() {
		val method4 = fidl.methods.get(3)
		assertEquals("method4", method4.name)
		assertEquals(2, method4.outArgs.size)
		val ret2 = method4.outArgs.get(1)
		assertEquals(402, accessor.getArgumentProp(ret2))

		// get union fields
		val type = ret2.type.actualDerived
		assertTrue(type instanceof FStructType)
		val struct = type as FStructType
		assertEquals("StructC", struct.name)
		assertEquals(1, struct.elements.size)
		val nested1 = struct.elements.get(0)

		// access property on struct level (cannot be overwritten)
		assertEquals(333, accessor.getStructProp(struct))
				
		// access ignoring overwrites
		assertEquals(33301, accessor.getSFieldProp(nested1))
		
		// access including overwrites (if any)
		val acc = accessor.getOverwriteAccessor(ret2)
		assertEquals(123, acc.getSFieldProp(nested1))

		// check nested overwrites
		val type2 = nested1.type.actualDerived
		assertTrue(type2 instanceof FUnionType)
		val union2 = type2 as FUnionType
		assertEquals("UnionA", union2.name)
		assertEquals(1, union2.elements.size)
		val fieldA1 = union2.elements.get(0)
		
		// local accessor acc1 will access overwritten properties in
		// deployment definition of StructC (as nested1 is a member of StructC)
		val acc1 = accessor.getOverwriteAccessor(nested1)
		checkUnionA(fieldA1, acc1, 33330, StringProp.y) 
		
		// local accessor acc2 will access overwritten properties in
		// deployment definition of ret2 (as acc is the overwrite accessor of method4.ret2)
		val acc2 = acc.getOverwriteAccessor(nested1)
		checkUnionA(fieldA1, acc2, 42, StringProp.s) 
	}
	

	/**
	 * Helper for checking the retrieved property values of a StructB
	 * with and without overwrite.
	 * 
	 * @param acc the accessor for the context where this StructB instance has been defined 
	 */
	def private checkStructB(
		FTypeRef typeRef,
		IDataPropertyAccessor acc
	) {
		// get struct fields
		val type = typeRef.actualDerived
		assertTrue(type instanceof FStructType)
		val struct = type as FStructType
		assertEquals("StructB", struct.name)
		assertEquals(3, struct.elements.size)
		val field1 = struct.elements.get(0)
		val nested1 = struct.elements.get(1)
		val nested2 = struct.elements.get(2)

		// access property on struct level (cannot be overwritten)
		assertEquals(222, accessor.getStructProp(struct))
				
		// access ignoring overwrites
		assertEquals(StringProp.u, accessor.getStringProp(field1))
		assertEquals(11, accessor.getSFieldProp(field1))

		assertEquals(12, accessor.getSFieldProp(nested1))
		
		assertEquals(0, accessor.getArrayProp(nested2))
		assertEquals(12, accessor.getSFieldProp(nested2))

		
		// access including overwrites (if any)
		assertEquals(StringProp.v, acc.getStringProp(field1))
		assertEquals(10, acc.getSFieldProp(field1))

		assertEquals(20, acc.getSFieldProp(nested1))
		checkNested1(nested1, acc);

		assertEquals(66, acc.getArrayProp(nested2))
		assertEquals(12, acc.getSFieldProp(nested2)) // not overwritten
		checkNested2(nested2, acc);
	}


	/**
	 * Helper for checking the property values retrieved from accessors
	 * for the field StructB.nested1 in various contexts.
	 */
	def private checkNested1(FField nested1, IDataPropertyAccessor acc) {
		// get struct fields
		val type = nested1.type.actualDerived
		assertTrue(type instanceof FStructType)
		val struct = type as FStructType
		
		// local accessor acc1 will access overwritten properties in
		// deployment definition of StructB (as nested1 is a member of StructB)
		val acc1 = accessor.getOverwriteAccessor(nested1)
		checkStructA(struct, accessor, acc1,
			15,
			16, StringProp.x, 
			17, StringProp.y, 11
		)
		
		// local accessor acc2 will access overwritten properties in
		// deployment definition of attr3 (as acc is the overwrite accessor of attr3)
		val acc2 = acc.getOverwriteAccessor(nested1)
		checkStructA(struct, accessor, acc2,
			11,
			21, StringProp.w, 
			31, StringProp.w, 88
		)
	}

	/**
	 * Helper for checking the property values retrieved from accessors
	 * for the field StructB.nested2 in various contexts.
	 */
	def private checkNested2(FField nested2, IDataPropertyAccessor acc) {
		// get struct fields
		assertTrue(nested2.isArray)
		val type = nested2.type.actualDerived
		assertTrue(type instanceof FStructType)
		val struct = type as FStructType
		
		// local accessor acc1 will access overwritten properties in
		// deployment definition of StructB (as nested2 is a member of StructB)
		val acc1 = accessor.getOverwriteAccessor(nested2)
		checkStructA(struct, accessor, acc1,
			25,
			26, StringProp.x, 
			27, StringProp.z, 21
		)
		
		// local accessor acc2 will access overwritten properties in
		// deployment definition of attr3 (as acc is the overwrite accessor of attr3)
		val acc2 = acc.getOverwriteAccessor(nested2)
		assertEquals(31415, acc2.getStructProp(struct))
		checkStructA(struct, accessor, acc2,
			12,
			22, StringProp.w, 
			32, StringProp.w, 77
		)
		
	}


	/**
	 * Helper for checking the retrieved property values of a UnionA
	 * with and without overwrite.
	 * 
	 * @param acc the accessor for the context where this UnionA instance has been defined 
	 */
	def private checkUnionA(
		FField f1,
		IDataPropertyAccessor acc,
		Integer pSField1, StringProp pString1
	) {
		// access ignoring overwrites
		assertEquals(0, accessor.getUFieldProp(f1))
		assertEquals(StringProp.u, accessor.getStringProp(f1))
		
		// access including overwrites (if any)
		assertEquals(pSField1, acc.getUFieldProp(f1))
		assertEquals(pString1, acc.getStringProp(f1))
	}

}
