/*******************************************************************************
 * Copyright (c) 2016 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.deploymodel.dsl.tests

import com.google.inject.Inject
import org.eclipse.xtext.junit4.InjectWith
import org.eclipse.xtext.serializer.ISerializer
import org.eclipselabs.xtext.utils.unittesting.XtextRunner2
import org.franca.deploymodel.dsl.FDeployTestsInjectorProvider
import org.franca.deploymodel.dsl.fDeploy.FDPredefinedTypeId
import org.franca.deploymodel.dsl.fDeploy.FDPropertyHost
import org.franca.deploymodel.dsl.fDeploy.FDeployFactory
import org.junit.Test
import org.junit.runner.RunWith

import static org.junit.Assert.*

@RunWith(typeof(XtextRunner2))
@InjectWith(typeof(FDeployTestsInjectorProvider))
class SerializerTests {
	
	@Inject ISerializer serializer

	@Test
	def void testEscapeKeywordsInSpecification() {
		// build test model
		val fmodel = f.createFDModel => [
			specifications.add(
				f.createFDSpecification => [
					name = "Spec1"
					declarations.add(
						f.createFDDeclaration => [
							host = FDPropertyHost.STRINGS
							properties.add(
								f.createFDPropertyDecl => [
									name = "attribute"
									type = f.createFDTypeRef => [
										predefined = FDPredefinedTypeId.INTEGER
									]
								]
							)
							properties.add(
								f.createFDPropertyDecl => [
									name = "method"
									type = f.createFDTypeRef => [
										predefined = FDPredefinedTypeId.INTEGER
									]
								]
							)
							properties.add(
								f.createFDPropertyDecl => [
									name = "broadcast"
									type = f.createFDTypeRef => [
										predefined = FDPredefinedTypeId.INTEGER
									]
								]
							)
							properties.add(
								f.createFDPropertyDecl => [
									name = "struct"
									type = f.createFDTypeRef => [
										predefined = FDPredefinedTypeId.INTEGER
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
		//println(result)
		
		// compare with expected
		val expected = '''
			specification Spec1 {
				for strings {
					^attribute : Integer ;
					^method : Integer ;
					^broadcast : Integer ;
					^struct : Integer ;
				}
			}'''

		assertEquals(expected, result)		
	}
	
	
	def private f() {
		FDeployFactory.eINSTANCE
	}
}
