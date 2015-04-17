package org.franca.deploymodel.dsl.tests

import com.google.inject.Inject
import java.util.ArrayList
import java.util.Arrays
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.generator.IGenerator
import org.eclipse.xtext.generator.InMemoryFileSystemAccess
import org.eclipse.xtext.junit4.InjectWith
import org.eclipselabs.xtext.utils.unittesting.XtextRunner2
import org.eclipselabs.xtext.utils.unittesting.XtextTest
import org.franca.deploymodel.dsl.FDeployTestsInjectorProvider
import org.franca.deploymodel.dsl.tests.memcompiler.ClassAnalyzer
import org.franca.deploymodel.dsl.tests.memcompiler.InMemoryFileSystemAccessCompiler
import org.junit.Test
import org.junit.runner.RunWith

import static org.junit.Assert.*

@RunWith(typeof(XtextRunner2))
@InjectWith(typeof(FDeployTestsInjectorProvider))
class CodeGeneratorTest extends XtextTest {

	@Inject
	IGenerator generator;
	
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
		val nameOfTheClassUnderTest = "SpecSimple40TypeCollectionPropertyAccessor"
		val fsa = new InMemoryFileSystemAccess
		generator.doGenerate(root.eResource, fsa)
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

		val fsa = new InMemoryFileSystemAccess
		generator.doGenerate(root.eResource, fsa)

		assertEquals(1, fsa.textFiles.size)
		println("Generated:\n" + fsa.textFiles.values().get(0))		
	}
		
}
