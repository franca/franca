/*******************************************************************************
 * Copyright (c) 2016 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.core.dsl.tests

import com.google.inject.Inject
import org.eclipse.xtext.junit4.InjectWith
import org.eclipse.xtext.serializer.ISerializer
import org.eclipselabs.xtext.utils.unittesting.XtextRunner2
import org.franca.core.dsl.FrancaIDLTestsInjectorProvider
import org.franca.core.franca.FBasicTypeId
import org.franca.core.franca.FrancaFactory
import org.junit.Test
import org.junit.runner.RunWith

import static org.junit.Assert.*
import java.math.BigInteger

@RunWith(typeof(XtextRunner2))
@InjectWith(typeof(FrancaIDLTestsInjectorProvider))
class SerializerTests {
	
	@Inject ISerializer serializer
	
	@Test
	def void testFloatConst() {
		// build test model
		val fmodel = f.createFModel => [
			name = "the.package"
			typeCollections.add(
				f.createFTypeCollection => [
					name = "TC1"
					constants.add(
						f.createFConstantDef => [
							name = "c1"
							type = f.createFTypeRef => [ predefined = FBasicTypeId.FLOAT ]
							rhs = f.createFFloatConstant => [ ^val = 12345.67f ]
						]
					)
				]
			)
		] 
		
		// serialize to string
		val result = serializer.serialize(fmodel)
		//println(result)
		
		// compare with expected
		val expected = '''
			package the.package
			
			typeCollection TC1 {
				const Float c1 = 12345.67f
			}'''

		assertEquals(expected, result)		
	}
	
	@Test
	def void testDoubleConst() {
		// build test model
		val fmodel = f.createFModel => [
			name = "the.package"
			typeCollections.add(
				f.createFTypeCollection => [
					name = "TC1"
					constants.add(
						f.createFConstantDef => [
							name = "c1"
							type = f.createFTypeRef => [ predefined = FBasicTypeId.DOUBLE ]
							rhs = f.createFDoubleConstant => [ ^val = 12345.67 ]
						]
					)
				]
			)
		] 
		
		// serialize to string
		val result = serializer.serialize(fmodel)
		//println(result)
		
		// compare with expected
		val expected = '''
			package the.package
			
			typeCollection TC1 {
				const Double c1 = 12345.67d
			}'''

		assertEquals(expected, result)		
	}
	
	@Test
	def void testNegativeEnumeratorValue() {
		// build test model
		val fmodel = f.createFModel => [
			name = "the.package"
			typeCollections.add(
				f.createFTypeCollection => [
					name = "TC1"
					types.add(
						f.createFEnumerationType => [
							name = "Enum1"
							enumerators.add(
								f.createFEnumerator => [
									name = "E1"
									value = f.createFIntegerConstant => [
										^val = BigInteger.valueOf(-123L)
									]
								]
							)
						]
					)
				]
			)
		] 
		
		// serialize to string
		val result = serializer.serialize(fmodel)
		println(result)
		
		// compare with expected
		val expected = '''
			package the.package
			
			typeCollection TC1 {
				enumeration Enum1 {
					E1 = -123
				}
			
			}'''

		assertEquals(expected, result)		
	}
	
	def private f() {
		FrancaFactory.eINSTANCE
	}
}
