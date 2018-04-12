/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.deploymodel.dsl.tests

import com.google.inject.Inject
import java.util.ArrayList
import java.util.Arrays
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.generator.IGenerator2
import org.eclipse.xtext.generator.InMemoryFileSystemAccess
import org.eclipse.xtext.testing.InjectWith
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.franca.deploymodel.dsl.FDeployTestsInjectorProvider
import org.franca.deploymodel.dsl.tests.memcompiler.ClassAnalyzer
import org.franca.deploymodel.dsl.tests.memcompiler.InMemoryFileSystemAccessCompiler
import org.junit.Ignore
import org.junit.Test
import org.junit.runner.RunWith

import static org.junit.Assert.*

@RunWith(typeof(XtextRunner2_Franca))
@InjectWith(typeof(FDeployTestsInjectorProvider))
class CodeGeneratorTest extends GeneratorTestBase {

	@Inject
	IGenerator2 generator;
	
	def private loadModel(String fileToTest, String... referencedResources) {
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
	 * Asserts that Franca generates a TypeCollectionPropertyAccessor 
	 * for a given "specification" given in an fdepl file. 
	 */
	@Ignore
	@Test
	def void test_40_DefTypeCollection() {
		val root = loadModel("testcases/40-SpecSimple.fdepl", "fidl/10-TypeCollection.fidl");
		/*  This is 40-SpecSimple.fdepl: 
		specification SpecSimple40 {
			for strings {
				StringPropMandatory : String;
			}
			
			for struct_fields {
				FieldPropMandatory : Integer;
			}
		} 
		*/
		val nameOfTheClassUnderTest = "SpecSimple40TypeCollectionPropertyAccessor"
		val fsa = new InMemoryFileSystemAccess
		generator.doGenerate(root.eResource, fsa, null)
		val compiler = new InMemoryFileSystemAccessCompiler(fsa);
		val expectedJavaClasses = compiler.expectedJavaClasses
		assertTrue("Missing generated java-file for " + nameOfTheClassUnderTest, expectedJavaClasses.contains(nameOfTheClassUnderTest))
		val theClass = compiler.getJavaClass(nameOfTheClassUnderTest)
		assertNotNull("No class for " + nameOfTheClassUnderTest, theClass)
		val classInfo = new ClassAnalyzer(theClass)
		assertTrue("The generated java class lacks some methods " + Arrays::toString(classInfo.allMethods), 
			classInfo.allMethodNames.containsAll(newArrayList("getStringPropMandatory","getFieldPropMandatory"))
		)
	}
	
	@Test
	def void test_60_SpecCompoundHosts() {
		val root = loadModel("testcases/60-SpecCompoundHosts.fdepl");

		// generate code in memory
		val fsa = new InMemoryFileSystemAccess
		generator.doGenerate(root.eResource, fsa, null)

		assertEquals(3, fsa.textFiles.size)
//		for(f : fsa.textFiles.keySet) {
//			val gen = fsa.textFiles.get(f).toString
//			gen.printMultiLine("Generated:")
//		}

		val generated = fsa.textFiles.values().get(0).toString
		
		// load expected result code and patch class name 
		val expected =
			readFile("src/org/example/spec/SpecCompoundHostsRef.java")
				.replace("SpecCompoundHostsRef", "SpecCompoundHosts")

		// do actual line-by-line comparison
		assertTrue(isEqualJava(expected, generated))
	}

	@Test
	def void test_61_SpecTypeCollection() {
		val root = loadModel("testcases/61-SpecTypeCollection.fdepl");

		// generate code in memory
		val fsa = new InMemoryFileSystemAccess
		generator.doGenerate(root.eResource, fsa, null)

		assertEquals(3, fsa.textFiles.size)
//		for(f : fsa.textFiles.keySet) {
//			val gen = fsa.textFiles.get(f).toString
//			gen.printMultiLine("Generated:")
//		}

		val generated = fsa.textFiles.values().get(0).toString
		
		// load expected result code and patch class name 
		val expected =
			readFile("src/org/example/spec/SpecTypeCollectionRef.java")
				.replace("SpecTypeCollectionRef", "SpecTypeCollection")

		// do actual line-by-line comparison
		assertTrue(isEqualJava(expected, generated))
	}

}
