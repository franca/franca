/*******************************************************************************
 * Copyright (c) 2015 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.deploymodel.dsl.tests

import org.eclipse.xtext.testing.InjectWith
import org.example.spec.SpecTypeCollectionRef.Enums.PropEnum
import org.example.spec.SpecTypeCollectionRef.TypeCollectionPropertyAccessor
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.franca.core.franca.FTypeCollection
import org.franca.deploymodel.core.FDeployedTypeCollection
import org.franca.deploymodel.dsl.FDeployTestsInjectorProvider
import org.franca.deploymodel.dsl.fDeploy.FDModel
import org.franca.deploymodel.dsl.fDeploy.FDTypes
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith

import static org.junit.Assert.*

@RunWith(typeof(XtextRunner2_Franca))
@InjectWith(typeof(FDeployTestsInjectorProvider))
class TypeCollectionDeployAccessorSimpleTest extends DeployAccessorTestBase {

	FTypeCollection tc
	TypeCollectionPropertyAccessor accessor
	
	@Before
	def void setup() {
		val root = loadModel(
			"testcases/63-DefTypeCollection.fdepl",
			"fidl/10-TypeCollection.fidl"
		);

		val model = root as FDModel
		assertFalse(model.deployments.empty)
		
		val first = model.deployments.get(0) as FDTypes
		val deployed = new FDeployedTypeCollection(first)
		accessor = new TypeCollectionPropertyAccessor(deployed)
		tc = first.target
	}

	
	@Test
	def void test_63DefTypeCollection_TopProperties() {
		assertEquals(4711, accessor.getPropInteger(tc))
		assertEquals("foo", accessor.getPropString(tc))
		assertEquals(true, accessor.getPropBoolean(tc))
		assertEquals(PropEnum.a, accessor.getPropEnum(tc))
	}

}

