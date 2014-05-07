/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.core.dsl.tests

import com.google.inject.Inject
import org.eclipse.emf.common.util.URI
import org.eclipse.xtend.typesystem.emf.EcoreUtil2
import org.eclipse.xtext.junit4.InjectWith
import org.eclipselabs.xtext.utils.unittesting.XtextRunner2
import org.eclipselabs.xtext.utils.unittesting.XtextTest
import org.franca.core.dsl.FrancaIDLTestsInjectorProvider
import org.franca.core.dsl.FrancaPersistenceManager
import org.franca.core.franca.FModel
import org.franca.core.franca.FStructType
import org.franca.core.franca.FTypeRef
import org.franca.core.utils.IntegerTypeConverter
import org.junit.Test
import org.junit.runner.RunWith

import static org.junit.Assert.*

@RunWith(typeof(XtextRunner2))
@InjectWith(typeof(FrancaIDLTestsInjectorProvider))
class IntegerConversionTests extends XtextTest {

	@Inject
	FrancaPersistenceManager fidlLoader

	@Test
	def void testAllRangesWithUnsigned() {
		testAllRanges(true)
	}

	@Test
	def void testAllRangesWithoutUnsigned() {
		testAllRanges(false)
	}

	def private void testAllRanges(boolean haveUnsigned) {
		val fmodel = loadAndTransform("testcases/22-IntegerTypes.fidl", haveUnsigned)
		assertEquals(1, fmodel.typeCollections.size)

		val tc = fmodel.typeCollections.get(0)
		assertEquals(1, tc.types.size)

		val struct = tc.types.get(0) as FStructType
		checkResultStruct(struct, haveUnsigned)
	}


	@Test
	def void testAllLocationsWithUnsigned() {
		testAllLocations(true)
	}

	@Test
	def void testAllLocationsWithoutUnsigned() {
		testAllLocations(false)
	}

	def private void testAllLocations(boolean haveUnsigned) {
		val fmodel = loadAndTransform("testcases/70-IntegerTypes.fidl", haveUnsigned)

		// check if all FTypeRefs have been converted
		val all = EcoreUtil2::allContents(fmodel)
		val typerefs = all.filter(typeof(FTypeRef))
		var nPredefinedTypes = 0
		for(tref : typerefs) {
			assertNull(tref.interval)
			if (tref.predefined!=null)
				nPredefinedTypes = nPredefinedTypes + 1
		}
		assertEquals(11, nPredefinedTypes)
	}

	def private FModel loadAndTransform(String filename, boolean haveUnsigned) {
		// load input model
		val root = URI::createURI("classpath:/")
		val loc = URI::createFileURI(filename)
		val fmodel = fidlLoader.loadModel(loc, root)
		
		// transform typerefs in this model
		IntegerTypeConverter::removeRangedIntegers(fmodel, haveUnsigned)
		return fmodel
	}
	

	// helpers for checking the expected results

	def private void checkResultStruct (FStructType struct, boolean haveUnsigned) {
		for(f : struct.elements) {
			assertNotNull(f.type.predefined)
			val t = f.type.predefined
			assertEquals("Invalid result type for field " + f.name,
				f.name.getExpectedType(haveUnsigned), t.getName
			)
		}
	}

	def private getExpectedType (String name, boolean haveUnsigned) {
		val parts = name.split("_")
		assertTrue(parts.size > 1)		
		
		val idx = if ((!haveUnsigned) && parts.size>2) 1 else 0
		parts.get(idx).replace("s", "Int").replace("u", "UInt")
	}
}
