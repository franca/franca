package org.franca.connectors.omgidl.tests

import com.google.inject.Inject
import java.util.List
import org.csu.idl.idlmm.IdlmmPackage
import org.eclipse.emf.compare.Diff
import org.eclipse.emf.compare.EMFCompare
import org.eclipse.emf.compare.internal.spec.ResourceAttachmentChangeSpec
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.xtext.junit4.InjectWith
import org.eclipselabs.xtext.utils.unittesting.XtextRunner2
import org.franca.connectors.omgidl.OMGIDLConnector
import org.franca.connectors.omgidl.OMGIDLModelContainer
import org.franca.core.dsl.FrancaIDLTestsInjectorProvider
import org.franca.core.dsl.FrancaPersistenceManager
import org.junit.Test
import org.junit.runner.RunWith

import static org.junit.Assert.assertEquals

@RunWith(typeof(XtextRunner2))
@InjectWith(typeof(FrancaIDLTestsInjectorProvider))
class OMGIDL2FrancaTests {

	val MODEL_DIR = "model/testcases/"
	val REF_DIR = "model/reference/"
	val GEN_DIR = "src-gen/testcases/"
	
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
	def void test_15() {
		test("csm_t", "model/testcases/gate1/", GEN_DIR, "model/reference/gate1/")
	}

	/**
	 * Utility method for executing one transformation and comparing the result with a reference model.
	 */
	def private test(String inputfile) {
		val OMG_IDL_EXT = ".idl"
		val FRANCA_IDL_EXT = ".fidl"
		// load the OMG IDL input model
		val conn = new OMGIDLConnector
		val map_OMGIDLModelContainer_FileName = conn.loadModels(MODEL_DIR + inputfile + OMG_IDL_EXT)
		// for each generated OMG IDL model
		for (iomgidl: map_OMGIDLModelContainer_FileName.keySet.toArray.reverseView) {
			val omgidl = iomgidl as OMGIDLModelContainer
			val fmodelGens = conn.toFrancas(omgidl)
			val fileName = map_OMGIDLModelContainer_FileName.get(iomgidl)
			for (fmodelGen: fmodelGens) {
				var name = fileName
				if (fmodelGens.size > 1) {
					name = name + '-' + fmodelGen.name
				}
				fmodelGen.saveModel(GEN_DIR + name + FRANCA_IDL_EXT)
				// load the reference Franca IDL model
				val fmodelRef = loadModel(REF_DIR + name + FRANCA_IDL_EXT)
				EcoreUtil.resolveAll(fmodelRef)
				// use EMF Compare to compare both Franca IDL models (the generated and the reference model)
				val rset1 = fmodelGen.eResource.resourceSet
				val rset2 = fmodelRef.eResource.resourceSet
				val scope = EMFCompare.createDefaultScope(rset1, rset2)
				val comparison = EMFCompare.builder.build.compare(scope)
				val List<Diff> differences = comparison.differences
				var nDiffs = 0
				for(diff : differences) {
					if (! (diff instanceof ResourceAttachmentChangeSpec)) {
						System.out.println(diff.toString)
						nDiffs++
					}
				}
				assertEquals(0, nDiffs)
			}
		}
		// do the actual transformation to Franca IDL and save the result
//		val fmodelGen = conn.toFranca(omgidl)
//		fmodelGen.saveModel(GEN_DIR + inputfile + FRANCA_IDL_EXT)
		
//		// load the reference Franca IDL model
//		val fmodelRef = loadModel(REF_DIR + inputfile + FRANCA_IDL_EXT)
//
//		// use EMF Compare to compare both Franca IDL models (the generated and the reference model)
//		val rset1 = fmodelGen.eResource.resourceSet
//		val rset2 = fmodelRef.eResource.resourceSet
//		val scope = EMFCompare.createDefaultScope(rset1, rset2)
//		val comparison = EMFCompare.builder.build.compare(scope)
//		val List<Diff> differences = comparison.differences
//		var nDiffs = 0
//		for(diff : differences) {
//			if (! (diff instanceof ResourceAttachmentChangeSpec)) {
//				System.out.println(diff.toString)
//				nDiffs++
//			}
//		}
		// TODO: is there a way to show the difference in a side-by-side view if the test fails?
		// (EMF Compare should provide a nice view for this...)
		
		/* 
		 * Only work in a standalone environment (need to be put in a plugin project and used through a new Eclipse runtime)
		 * https://www.eclipse.org/forums/index.php?t=msg&th=853557/
		 */
//		val editingDomain = EMFCompareEditingDomain.create(scope.left,scope.right,null)
//		val adapterFactory = new ComposedAdapterFactory(ComposedAdapterFactory.Descriptor.Registry.INSTANCE)
//		val input = new ComparisonEditorInput(new EMFCompareConfiguration(new CompareConfiguration()), comparison, editingDomain, adapterFactory)
//		CompareUI.openCompareEditor(input)
		
		// we expect that both Franca IDL models are identical 
//		assertEquals(0, nDiffs)
	}
	
	def private test(String inputfile, String model_dir, String gen_dir, String ref_dir) {
		val OMG_IDL_EXT = ".idl"
		val FRANCA_IDL_EXT = ".fidl"
		// load the OMG IDL input model
		val conn = new OMGIDLConnector
		val map_OMGIDLModelContainer_FileName = conn.loadModels(model_dir + inputfile + OMG_IDL_EXT)
		// for each generated OMG IDL model
		for (iomgidl: map_OMGIDLModelContainer_FileName.keySet.toArray.reverseView) {
			val omgidl = iomgidl as OMGIDLModelContainer
			val fmodelGens = conn.toFrancas(omgidl)
			val fileName = map_OMGIDLModelContainer_FileName.get(iomgidl)
			for (fmodelGen: fmodelGens) {
				var name = fileName
				if (fmodelGens.size > 1) {
					name = name + '-' + fmodelGen.name
				}
				fmodelGen.saveModel(gen_dir + name + FRANCA_IDL_EXT)
				// load the reference Franca IDL model
				val fmodelRef = loadModel(ref_dir + name + FRANCA_IDL_EXT)
				EcoreUtil.resolveAll(fmodelRef)
				// use EMF Compare to compare both Franca IDL models (the generated and the reference model)
				val rset1 = fmodelGen.eResource.resourceSet
				val rset2 = fmodelRef.eResource.resourceSet
				val scope = EMFCompare.createDefaultScope(rset1, rset2)
				val comparison = EMFCompare.builder.build.compare(scope)
				val List<Diff> differences = comparison.differences
				var nDiffs = 0
				for(diff : differences) {
					if (! (diff instanceof ResourceAttachmentChangeSpec)) {
						System.out.println(diff.toString)
						nDiffs++
					}
				}
				assertEquals(0, nDiffs)
			}
		}
	}
}
