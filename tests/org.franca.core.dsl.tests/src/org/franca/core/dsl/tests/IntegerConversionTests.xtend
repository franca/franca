/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.core.dsl.tests

import com.google.inject.Inject
import com.itemis.xtext.testing.XtextTest
import org.eclipse.emf.common.util.URI
import org.eclipse.xtend.typesystem.emf.EcoreUtil2
import org.eclipse.xtext.testing.InjectWith
import org.franca.core.dsl.FrancaIDLTestsInjectorProvider
import org.franca.core.dsl.FrancaPersistenceManager
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.franca.core.franca.FBasicTypeId
import org.franca.core.franca.FModel
import org.franca.core.franca.FStructType
import org.franca.core.franca.FTypeRef
import org.franca.core.utils.IntegerTypeConverter
import org.junit.Test
import org.junit.runner.RunWith

import static org.junit.Assert.*

@RunWith(typeof(XtextRunner2_Franca))
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


	@Test
	def void testAllBasicTypes() {
		val fmodel = loadAndTransform("testcases/23-IntegerTypes.fidl")
		assertEquals(1, fmodel.typeCollections.size)

		val tc = fmodel.typeCollections.get(0)
		assertEquals(1, tc.types.size)

		val struct = tc.types.get(0) as FStructType
		var nPredefined = 0
		var nInterval = 0
		for(f : struct.elements) {
			if (f.type.predefined!=null && f.type.predefined!=FBasicTypeId::UNDEFINED)
				nPredefined = nPredefined + 1
			if (f.type.interval!=null)
				nInterval = nInterval + 1
		}
		assertEquals(8, nInterval)    // these should have been converted
		assertEquals(5, nPredefined)  // these are non-int types and must not be converted
	}


	@Test
	def void testAllLocationsForBasicTypes() {
		val fmodel = loadAndTransform("testcases/71-IntegerTypes.fidl")

		// check if all FTypeRefs have been converted
		val all = EcoreUtil2::allContents(fmodel)
		val typerefs = all.filter(typeof(FTypeRef))
		var nPredefined = 0
		var nInterval = 0
		for(tref : typerefs) {
			if (tref.predefined!=null && tref.predefined!=FBasicTypeId::UNDEFINED)
				nPredefined = nPredefined + 1
			if (tref.interval!=null)
				nInterval = nInterval + 1
		}
		assertEquals(11, nInterval)   // these should have been converted
		assertEquals(0, nPredefined)  // these are non-int types and must not be converted
	}


	/**
	 * Load Franca model and transform all ranged integers to predefined int types.
	 */
	def private FModel loadAndTransform(String filename, boolean haveUnsigned) {
		// load input model
		val root = URI::createURI("classpath:/")
		val loc = URI::createFileURI(filename)
		val fmodel = fidlLoader.loadModel(loc, root)
		
		// transform typerefs in this model
		IntegerTypeConverter::removeRangedIntegers(fmodel, haveUnsigned)
		
		// save resulting model
		val outdir = "model-gen/from_ranged/" +
					(if (haveUnsigned) "with" else "without") + "_unsigned"
		fidlLoader.saveModel(fmodel, outdir + "/" + filename)

		return fmodel
	}
	
	/**
	 * Load Franca model and transform all predefined int types to ranged integers.
	 */
	def private FModel loadAndTransform(String filename) {
		// load input model
		val root = URI::createURI("classpath:/")
		val loc = URI::createFileURI(filename)
		val fmodel = fidlLoader.loadModel(loc, root)
		
		// transform typerefs in this model
		IntegerTypeConverter::removePredefinedIntegers(fmodel)
		
		// save resulting model
		val outdir = "model-gen/to_ranged"
		fidlLoader.saveModel(fmodel, outdir + "/" + filename)

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
