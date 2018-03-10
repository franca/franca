/*******************************************************************************
 * Copyright (c) 2016 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.deploymodel.dsl.tests

import com.google.inject.Inject
import org.eclipse.xtext.resource.SaveOptions
import org.eclipse.xtext.serializer.ISerializer
import org.franca.deploymodel.core.FDPropertyHost
import org.eclipse.xtext.testing.InjectWith
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.franca.deploymodel.dsl.FDeployTestsInjectorProvider
import org.franca.deploymodel.dsl.fDeploy.FDBuiltInPropertyHost
import org.franca.deploymodel.dsl.fDeploy.FDPredefinedTypeId
import org.franca.deploymodel.dsl.fDeploy.FDeployFactory
import org.junit.Test
import org.junit.runner.RunWith

import static org.junit.Assert.*

@RunWith(typeof(XtextRunner2_Franca))
@InjectWith(typeof(FDeployTestsInjectorProvider))
class SerializerTests {
	
	@Inject ISerializer serializer

	val SaveOptions options = SaveOptions.newBuilder.format.options

	@Test
	def void testEscapeKeywordsInSpecification() {
		// build test model
		val fmodel = f.createFDModel => [
			specifications.add(
				f.createFDSpecification => [
					name = "Spec1"
					declarations.add(
						f.createFDDeclaration => [
							host = FDPropertyHost.builtIn(FDBuiltInPropertyHost.STRINGS)
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
		val result = serializer.serialize(fmodel, options)
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
