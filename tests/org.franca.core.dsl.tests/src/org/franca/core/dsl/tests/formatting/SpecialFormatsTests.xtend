/*******************************************************************************
 * Copyright (c) 2016 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.core.dsl.tests.formatting

import java.math.BigInteger
import org.eclipse.xtext.testing.InjectWith
import org.franca.core.dsl.FrancaIDLTestsInjectorProvider
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.franca.core.franca.FBasicTypeId
import org.franca.core.franca.FOperator
import org.franca.core.franca.FrancaFactory
import org.junit.Test
import org.junit.runner.RunWith

import static org.junit.Assert.*

@RunWith(typeof(XtextRunner2_Franca))
@InjectWith(typeof(FrancaIDLTestsInjectorProvider))
class SpecialFormatsTests extends FormatterTestBase{
	
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
		val result = fmodel.format
		//println(result)
		
		// compare with expected
		val expected = '''
			package the.package
			
			typeCollection TC1 {
				const Float c1 = 12345.67f
			}
		'''

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
		val result = fmodel.format
		//println(result)
		
		// compare with expected
		val expected = '''
			package the.package
			
			typeCollection TC1 {
				const Double c1 = 12345.67d
			}
		'''

		assertEquals(expected, result)		
	}
	
	@Test
	def void testNegativeEnumeratorValue1() {
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
										// NB: the grammar FrancaIDL.xtext doesn't allow negative integer constants,
										// but the serialization is working nevertheless.
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
		val result = fmodel.format
		//println(result)
		
		// compare with expected
		val expected = '''
			package the.package
			
			typeCollection TC1 {
				enumeration Enum1 {
					E1 = -123
				}
			}
		'''

		assertEquals(expected, result)		
	}

	@Test
	def void testNegativeEnumeratorValue2() {
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
									value = f.createFUnaryOperation => [
										op = FOperator.SUBTRACTION
										operand = f.createFIntegerConstant => [
											^val = BigInteger.valueOf(123L)
										]
									]
								]
							)
						]
					)
				]
			)
		] 
		
		// serialize to string
		val result = fmodel.format
		//println(result)
		
		// compare with expected
		val expected = '''
			package the.package
			
			typeCollection TC1 {
				enumeration Enum1 {
					E1 = -123
				}
			}
		'''

		assertEquals(expected, result)		
	}


	@Test
	def void testEscapeKeywords() {
		// build test model
		val fmodel = f.createFModel => [
			name = "the.package"
			typeCollections.add(
				f.createFTypeCollection => [
					name = "TC1"
					types.add(
						f.createFEnumerationType => [
							name = "Enum2"
							enumerators.add(
								f.createFEnumerator => [ name = "attribute" ]
							)
							enumerators.add(
								f.createFEnumerator => [ name = "method" ]
							)
							enumerators.add(
								f.createFEnumerator => [ name = "broadcast" ]
							)
						]
					)
				]
			)
		] 
		
		// serialize to string
		val result = fmodel.format
		//println(result)
		
		// compare with expected
		val expected = '''
			package the.package
			
			typeCollection TC1 {
				enumeration Enum2 {
					^attribute
					^method
					^broadcast
				}
			}
		'''

		assertEquals(expected, result)		
	}
	
	
	def private f() {
		FrancaFactory.eINSTANCE
	}

}
