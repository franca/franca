/*******************************************************************************
 * Copyright (c) 2015 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.deploymodel.dsl.tests

import com.itemis.xtext.testing.XtextTest
import java.util.ArrayList
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EObject
import org.example.spec.SpecCompoundHostsRef.Enums.StringProp
import org.example.spec.SpecCompoundHostsRef.IDataPropertyAccessor
import org.franca.core.franca.FStructType

import static org.junit.Assert.*

abstract class DeployAccessorTestBase extends XtextTest {

	/**
	 * Helper method for loading a deployment model from file and some 
	 * other model files needed for the loaded model. 
	 */
	def protected loadModel(String fileToTest, String... referencedResources) {
		val resList = new ArrayList(referencedResources);
		resList += fileToTest
		var EObject result = null
		for (res : resList) {
			val uri = URI::createURI(resourceRoot + "/" + res);
			result = loadModel(resourceSet, uri, getRootObjectType(uri));
		}
		result
	}
	
	/**
	 * Helper for checking the retrieved property values of a StructA
	 * with and without overwrite.
	 * 
	 * @param acc the accessor for the context where this StructA instance has been defined 
	 */
	def protected checkStructA(
		FStructType structA,
		IDataPropertyAccessor accessor,
		IDataPropertyAccessor acc,
		Integer pSField1,
		Integer pSField2, StringProp pString2,
		Integer pSField3, StringProp pString3, Integer pArray3
	) {
		// check struct name
		assertEquals("StructA", structA.name)

		// get struct fields
		assertEquals(3, structA.elements.size)
		val f1 = structA.elements.get(0)
		assertEquals("field1", f1.name)
		val f2 = structA.elements.get(1)
		assertEquals("field2", f2.name)
		val f3 = structA.elements.get(2)
		assertEquals("field3", f3.name)

		// access ignoring overwrites
		assertEquals(1, accessor.getSFieldProp(f1))
		assertEquals(2, accessor.getSFieldProp(f2))
		assertEquals(StringProp.u, accessor.getStringProp(f2))
		assertEquals(3, accessor.getSFieldProp(f3))
		assertEquals(StringProp.u, accessor.getStringProp(f3))
		assertEquals(0, accessor.getArrayProp(f3))
		
		if (acc!==null) {
			// access including overwrites (if any)
			assertEquals(pSField1, acc.getSFieldProp(f1))
			assertEquals(pSField2, acc.getSFieldProp(f2))
			assertEquals(pString2, acc.getStringProp(f2))
			assertEquals(pSField3, acc.getSFieldProp(f3))
			assertEquals(pString3, acc.getStringProp(f3))
			assertEquals(pArray3, acc.getArrayProp(f3))
		}
	}


}