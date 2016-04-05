package org.franca.connectors.omgidl.tests

import com.google.inject.Inject
import java.util.List
import java.util.Map
import org.csu.idl.idlmm.IdlmmPackage
import org.eclipse.emf.compare.Diff
import org.eclipse.emf.compare.EMFCompare
import org.eclipse.emf.compare.internal.spec.ResourceAttachmentChangeSpec
import org.eclipse.emf.compare.scope.DefaultComparisonScope
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.xtext.junit4.InjectWith
import org.eclipselabs.xtext.utils.unittesting.XtextRunner2
import org.franca.connectors.omgidl.OMGIDLConnector
import org.franca.connectors.omgidl.OMGIDLModelContainer
import org.franca.core.dsl.FrancaIDLTestsInjectorProvider
import org.franca.core.dsl.FrancaPersistenceManager
import org.franca.core.dsl.tests.compare.ComparisonTextReportGenerator
import org.junit.Test
import org.junit.runner.RunWith

import static org.junit.Assert.assertEquals

@RunWith(typeof(XtextRunner2))
@InjectWith(typeof(FrancaIDLTestsInjectorProvider))
class OMGIDL2FrancaTests {

	val MODEL_DIR = "model/testcases/"
	val REF_DIR = "model/reference/"
	val GEN_DIR = "src-gen/testcases/"
	
	val MODEL_DIR2 = "model/testcases/gate1/"
	val REF_DIR2 = "model/reference/gate1/"
	val GEN_DIR2 = "src-gen/testcases/gate1/"
	
	val OMG_IDL_EXT = ".idl"
	val FRANCA_IDL_EXT = ".fidl"

	@Inject	extension FrancaPersistenceManager
	
	@Test
	def test_10() {
		IdlmmPackage.eINSTANCE.eClass()
		test("10-EmptyInterface")
	}

	// TODO: add more testcases here
	@Test
	def test_11() {
		test("11-EmptyInterfacesWithIncludes")
	}
	
	@Test
	def test_12() {
		test("12-TypeDeclarations")
	}
	
	@Test
	def test_13() {
		test("13-ConstantDeclarations")
	}
	
	@Test
	def test_14() {
		test("14-InterfaceDeclarations")
	}
	
	@Test
	def void test_20() {
		testG1("bn_ev")
	}
	
	@Test
	def void test_21() {
		testG1("bn_t")
	}
	
	@Test
	def void test_22() {
		testG1("csm_cs")
	}
	
	@Test
	def void test_23() {
		testG1("csm_t")
	}
	
	@Test
	def void test_24() {
		testG1("db_cs")
	}
	
	@Test
	def void test_25() {
		testG1("db_ev")
	}
	
	@Test
	def void test_26() {
		testG1("db_t")
	}
	
	@Test
	def void test_27() {
		testG1("de_ev")
	}
	
	@Test
	def void test_28() {
		testG1("de")
	}
	
	@Test
	def void test_29() {
		testG1("evc_t")
	}
	
	@Test
	def void test_30() {
		testG1("evm_ev")
	}
	
	@Test
	def void test_31() {
		testG1("evm")
	}
	
	@Test
	def void test_32() {
		testG1("evs")
	}

	/**
	 * Utility method for executing one transformation and comparing the result with a reference model.
	 */
	def private test(String inputfile) {
		testAux(inputfile, MODEL_DIR, GEN_DIR, REF_DIR)
	}

	/**
	 * Utility method for executing one transformation and comparing the result with a reference model.
	 */
	def private testG1(String inputfile) {
		testAux(inputfile, MODEL_DIR2, GEN_DIR2, REF_DIR2)
	}

	def private testAux(String inputfile, String model_dir, String gen_dir, String ref_dir) {
		// load the OMG IDL input model (may consist of multiple files)
		val conn = new OMGIDLConnector
		val omgidl = conn.loadModel(model_dir + inputfile + OMG_IDL_EXT) as OMGIDLModelContainer

		// transform to Franca 
		val fmodelsGen = conn.toFrancas(omgidl)

		// the first generated model will be the root model, this determines which reference model should be loaded
		val root = fmodelsGen.entrySet.iterator.head
		val rootName = root.value

		val Map<String, EObject> importedModels = newHashMap() 
		for (fmodelGen : fmodelsGen.keySet().toList.reverseView) {
			val importURI = fmodelsGen.get(fmodelGen) + FRANCA_IDL_EXT
			//println("generated: " + importURI + ": " + fmodelGen.name)
			importedModels.put(importURI, fmodelGen)
		}
		root.key.saveModel(gen_dir + root.value + FRANCA_IDL_EXT, importedModels)
		
		// load the reference Franca IDL model and resolve whole model explicitly
		val fmodelRef = loadModel(ref_dir + rootName + FRANCA_IDL_EXT)
		EcoreUtil.resolveAll(fmodelRef.eResource.resourceSet)

		// use EMF Compare to compare both Franca IDL models (the generated and the reference model)
		val rset1 = root.key.eResource.resourceSet
		val rset2 = fmodelRef.eResource.resourceSet
		val scope = new DefaultComparisonScope(rset1, rset2, null)

		val comparison = EMFCompare.builder.build.compare(scope)
		val List<Diff> differences = comparison.differences
		var nDiffs = 0
		for(diff : differences) {
			if (! (diff instanceof ResourceAttachmentChangeSpec)) {
				System.out.println(diff.toString)
				nDiffs++
			}
		}

		// produce some nice output of the differences, if there are any
		val gen = new ComparisonTextReportGenerator
		for(m : comparison.matches) {
			if (m.allDifferences.size() > 0)
				println(gen.generateReport(m))
		}
		
		/* 
		 * Only work in a standalone environment (need to be put in a plugin project and used through a new Eclipse runtime)
		 * https://www.eclipse.org/forums/index.php?t=msg&th=853557/
		 */
//			val editingDomain = EMFCompareEditingDomain.create(scope.left,scope.right,null)
//			val adapterFactory = new ComposedAdapterFactory(ComposedAdapterFactory.Descriptor.Registry.INSTANCE)
//			val input = new ComparisonEditorInput(new EMFCompareConfiguration(new CompareConfiguration()), comparison, editingDomain, adapterFactory)
//			CompareUI.openCompareEditor(input)

		// we expect that both Franca IDL models are identical 
		assertEquals(0, nDiffs)
	}
}
