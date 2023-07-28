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
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.generator.IGenerator2
import org.eclipse.xtext.generator.InMemoryFileSystemAccess
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.XtextRunner
import org.eclipse.xtext.xbase.testing.OnTheFlyJavaCompiler2
import org.franca.deploymodel.dsl.FDeployTestsInjectorProvider
import org.franca.core.franca.FField
import org.junit.Test
import org.junit.runner.RunWith

import static org.junit.Assert.*

@RunWith(typeof(XtextRunner))
@InjectWith(typeof(FDeployTestsInjectorProvider))
class CodeGeneratorTest extends GeneratorTestBase {
	@Inject
	OnTheFlyJavaCompiler2 javaCompiler;

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

		// generate PropertyAccessor code for the given deployment specification 
		val nameOfTheClassUnderTest = "SpecSimple40"
		val fsa = new InMemoryFileSystemAccess
		generator.doGenerate(root.eResource, fsa, null)
		
		// compile the generated code in-memory		
		val file = fsa.textFiles.entrySet.findFirst[it.key.contains(nameOfTheClassUnderTest + ".java")]
		assertNotNull(file)
		val theClass = javaCompiler.compileToClass(nameOfTheClassUnderTest, file.value.toString)
		assertNotNull("No class for " + nameOfTheClassUnderTest, theClass)

		// check inner classes of the generated class
		val nameOfIPAClass = "InterfacePropertyAccessor"
		val inner1 = theClass.classes.findFirst[name.endsWith(nameOfIPAClass)]
		assertNotNull("No inner class for " + nameOfIPAClass, inner1)
		inner1.checkMethod("getStringPropMandatory", typeof(EObject), typeof(String))
		inner1.checkMethod("getFieldPropMandatory", typeof(FField), typeof(Integer))

		val nameOfTCPAClass = "TypeCollectionPropertyAccessor"
		val inner2 = theClass.classes.findFirst[name.endsWith(nameOfTCPAClass)]
		assertNotNull("No inner class for " + nameOfTCPAClass, inner2)
		inner2.checkMethod("getStringPropMandatory", typeof(EObject), typeof(String))
		inner2.checkMethod("getFieldPropMandatory", typeof(FField), typeof(Integer))
	}
	
	def private void checkMethod(Class<?> clazz, String expectedName, Class<?> expParamType, Class<?> expReturnType) {
		val method = clazz.methods.findFirst[m | m.name == expectedName]
		assertNotNull("Missing method '" + expectedName + "' in class '" + clazz.simpleName + "'", method)

		assertEquals("Wrong number of parameters in method '" + expectedName + "'", 1, method.parameterCount)
		assertEquals("Wrong type of first parameter in method '" + expectedName + "'", expParamType, method.parameterTypes.get(0))

		assertEquals("Wrong return type in method '" + expectedName + "'", expReturnType, method.returnType)		
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
