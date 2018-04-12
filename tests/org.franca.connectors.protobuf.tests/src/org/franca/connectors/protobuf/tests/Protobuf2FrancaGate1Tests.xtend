package org.franca.connectors.protobuf.tests

import org.eclipse.xtext.testing.InjectWith
import org.franca.core.dsl.FrancaIDLTestsInjectorProvider
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(typeof(XtextRunner2_Franca))
@InjectWith(typeof(FrancaIDLTestsInjectorProvider))
class Protobuf2FrancaGate1Tests extends TestBase {

	val MODEL_DIR = "model/testcases/gate1/"
	val REF_DIR = "model/reference/gate1/"
	val GEN_DIR = "src-gen/testcases/gate1/"
//	val DEPLOY_DIR = "model/deploy/"
//	val FIDL_DIR = "../../src-gen/testcases/gate1/"
//	val SPEC_FILE = "../specification/ProtobufSpec.fdepl"

	@Test
	def test_Astronomy_rr(){
		test("Astronomy_rr")
	}
	
	@Test
	def test_Astronomy_t(){
		test("Astronomy_t")
	}
	
	@Test
	def test_Common_t(){
		test("Common_t")
	}
	
	@Test
	def test_Ct_t(){
		test("Ct_t")
	}
	
	@Test
	def test_CtCommon_t(){
		test("CtCommon_t")
	}
	
	@Test
	def test_Infrastructure_t(){
		test("Infrastructure_t")
	}
	
	@Test
	def test_Mt_ps(){
		test("Mt_ps")
	}
	
	@Test
	def test_Mt_rr(){
		test("Mt_rr")
	}
	
	@Test
	def test_Mt_t(){
		test("Mt_t")
	}
	
	@Test
	def test_Overlay_ps(){
		test("Overlay_ps")
	}
	
	@Test
	def test_Overlay_rr(){
		test("Overlay_rr")
	}
	
	@Test
	def test_Overlay_t(){
		test("Overlay_t")
	}
	
	@Test
	def test_SL_ps(){
		test("SL_ps")
	}
	
	@Test
	def test_SL_rr(){
		test("SL_rr")
	}
	
	@Test
	def test_SL_t(){
		test("SL_t")
	}

	
	/**
	 * Utility method for executing one transformation and comparing the result with a reference model.
	 */
	def private void test(String inputfile) {
		println("----------------------- TEST Protobuf2FrancaGate1 '" + inputfile + "' -----------------------")
		testTransformation(inputfile, MODEL_DIR, GEN_DIR, REF_DIR, true)
	}

//	private def void test(String inputfile, String fidl_dir, String specificfile, String post_dir) {
//		val PROTOBUF_EXT = ".proto"
//		val FRANCA_IDL_EXT = ".fidl"
//		
//		// load the OMG IDL input model
//		val conn = new ProtobufConnector
//		val protobufidls = conn.loadModels(MODEL_DIR+post_dir + inputfile + PROTOBUF_EXT)
//		
//		val fmodelGens = conn.toFrancas(protobufidls)
//		val filenames = protobufidls.map[fileName]
//		for (var i=0; i< fmodelGens.size; i++){
//			fmodelGens.get(i).saveModel(GEN_DIR+post_dir + filenames.get(i) + FRANCA_IDL_EXT)
//			
//			fsa.outputPath = DEPLOY_DIR+post_dir
//			fsa.generateFile(filenames.get(i) +".fdepl", conn.generateFrancaDeployment(protobufidls.get(i), specificfile, fidl_dir, filenames.get(i)))
//			
//			val fmodelRef = loadModel(REF_DIR+post_dir + filenames.get(i) + FRANCA_IDL_EXT)
//			EcoreUtil.resolveAll(fmodelRef.eResource)
//			
//			// use EMF Compare to compare both Franca IDL models (the generated and the reference model)
//			val rset2 = fmodelRef.eResource.resourceSet
//			val rset1 = fmodelGens.get(i).eResource.resourceSet //TODO
//	
//			val scope = new DefaultComparisonScope(rset1, rset2, null)
//			println("scope rset1:")
//				for(r : scope.getCoveredResources(rset1).toIterable) {
//					println("   " + r)
//				}
//			
//			val comparison = EMFCompare.builder.build.compare(scope)
//			val List<Diff> differences = comparison.differences
//			var nDiffs = 0
//			for (diff : differences) {
//				if (! (diff instanceof ResourceAttachmentChangeSpec)) {
//					System.out.println(diff.toString)
//					nDiffs++
//				}
//			}
//			assertEquals(0, nDiffs)
//		}
//	}

}
