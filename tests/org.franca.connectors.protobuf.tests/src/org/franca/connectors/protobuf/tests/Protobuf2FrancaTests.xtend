package org.franca.connectors.protobuf.tests

import com.google.inject.Inject
import java.util.List
import org.eclipse.emf.compare.Diff
import org.eclipse.emf.compare.EMFCompare
import org.eclipse.emf.compare.internal.spec.ResourceAttachmentChangeSpec
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.xtext.generator.JavaIoFileSystemAccess
import org.eclipse.xtext.junit4.InjectWith
import org.eclipselabs.xtext.utils.unittesting.XtextRunner2
import org.franca.connectors.protobuf.ProtobufConnector
import org.franca.core.dsl.FrancaIDLTestsInjectorProvider
import org.franca.core.dsl.FrancaPersistenceManager
import org.junit.Ignore
import org.junit.Test
import org.junit.runner.RunWith

import static org.junit.Assert.*

@RunWith(typeof(XtextRunner2))
@InjectWith(typeof(FrancaIDLTestsInjectorProvider))
class Protobuf2FrancaTests {

	val MODEL_DIR = "model/testcases/"
	val REF_DIR = "model/reference/"
	val GEN_DIR = "src-gen/testcases/"
	val DEPLOY_DIR = "model/deploy/"
	val FIDL_DIR = "../../src-gen/testcases/"
	val SPEC_FILE = "../specification/ProtobufSpec.fdepl"

	@Inject extension FrancaPersistenceManager
	
	@Inject
	JavaIoFileSystemAccess fsa
	

	@Test
	def empty() {
		test("EmptyService")
		test("EmptyMessage")
	}
	
	@Test 
	def messageWithScalarValueTypeFields(){
		test("MessageWithScalarValueTypeFields")
	}

	@Test
	def serviceWithOneRPC(){
		test("ServiceWithOneRPC")
	}
	
	@Test
	def messageWithComplexTypeFields(){
		test("MessageWithComplexTypeFields")
	}
	
	@Test
	def messageWithComplexType(){
		test("MessageWithComplexType")
	}
	
	@Test
	def messageWithMessageField() {
		test("MessageWithMessageField")
	}

	@Test
	def oneOf() {
		test("MessageWithOneof")
	}
	
	@Test
	def extend() {
		test("MessageWithExtend")
	}
	
	@Test
	def extend_nested() {
		test("NestedExtensions")
	}
	
	@Test 
	def nameNotUnique(){
		test ("NameNotUnique")
	}
	
	@Test 
	def nestedTypes(){
		test ("NestedTypes")
	}
	
	@Test
	//FIXME
	@Ignore
	def test_Import() {
		test("MultiFiles")
	}

	@Test
	//FIXME implicit import
	@Ignore
	def option() {
		test("Option")
		//test("EnumWithOption")
	}
	
	@Test
	//FIXME implicit import
	@Ignore
	def customOptions() {
		test("CustomOptions")
	}
	
	@Test
	def descriptor(){
		test("descriptor")
	}
	
	@Test
	//FIXME Franca Serializer issues : the subtraction operator is separated from the number. 
	def enum_enumeratorValue(){
		test("Enum_enumeratorValue")
	}
	
	@Test
	def enum_emptyEnum(){
		test("Enum_emptyEnum")
	}
	
	@Test
	@Ignore
	def test_Astronomy_rr(){
		test("Astronomy_rr","../"+FIDL_DIR+"gate1/","../"+SPEC_FILE, "gate1/")
	}
	
	@Test
	@Ignore
	def test_Astronomy_t(){
		test("Astronomy_t","../"+FIDL_DIR+"gate1/","../"+SPEC_FILE, "gate1/")
	}
	
	@Test
	def test_Common_t(){
		test("Common_t","../"+FIDL_DIR+"gate1/","../"+SPEC_FILE, "gate1/")
	}
	
	@Test
	@Ignore
	def test_Ct_t(){
		test("Ct_t","../"+FIDL_DIR+"gate1/","../"+SPEC_FILE, "gate1/")
	}
	
	@Test
	@Ignore
	def test_CtCommon_t(){
		test("CtCommon_t","../"+FIDL_DIR+"gate1/","../"+SPEC_FILE, "gate1/")
	}
	
	@Test
	def test_Infrastructure_t(){
		test("Infrastructure_t","../"+FIDL_DIR+"gate1/","../"+SPEC_FILE, "gate1/")
	}
	
	@Test
	@Ignore
	def test_Mt_ps(){
		test("Mt_ps","../"+FIDL_DIR+"gate1/","../"+SPEC_FILE, "gate1/")
	}
	
	@Test
	@Ignore
	def test_Mt_rr(){
		test("Mt_rr","../"+FIDL_DIR+"gate1/","../"+SPEC_FILE, "gate1/")
	}
	
	@Test
	@Ignore
	def test_Mt_t(){
		test("Mt_t","../"+FIDL_DIR+"gate1/","../"+SPEC_FILE, "gate1/")
	}
	
	@Test
	@Ignore
	def test_Overlay_ps(){
		test("Overlay_ps","../"+FIDL_DIR+"gate1/","../"+SPEC_FILE, "gate1/")
	}
	
	@Test
	@Ignore
	def test_Overlay_rr(){
		test("Overlay_rr","../"+FIDL_DIR+"gate1/","../"+SPEC_FILE, "gate1/")
	}
	
	@Test
	@Ignore
	def test_Overlay_t(){
		test("Overlay_t","../"+FIDL_DIR+"gate1/","../"+SPEC_FILE, "gate1/")
	}
	
	@Test
	@Ignore
	def test_SL_ps(){
		test("SL_ps","../"+FIDL_DIR+"gate1/","../"+SPEC_FILE, "gate1/")
	}
	
	@Test
	@Ignore
	def test_SL_rr(){
		test("SL_rr","../"+FIDL_DIR+"gate1/","../"+SPEC_FILE, "gate1/")
	}
	
	@Test
	@Ignore
	def test_SL_t(){
		test("SL_t","../"+FIDL_DIR+"gate1/","../"+SPEC_FILE,"gate1/")
	}
	
	private def test(String inputfile, String fidl_dir, String specificfile, String post_dir) {
		val PROTOBUF_EXT = ".proto"
		val FRANCA_IDL_EXT = ".fidl"
		
		// load the OMG IDL input model
		val conn = new ProtobufConnector
		val protobufidls = conn.loadModels(MODEL_DIR+post_dir + inputfile + PROTOBUF_EXT)
		
		val fmodelGens = conn.toFrancas(protobufidls)
		val filenames = protobufidls.map[fileName]
		for (var i=0; i< fmodelGens.size; i++){
			fmodelGens.get(i).saveModel(GEN_DIR+post_dir + filenames.get(i) + FRANCA_IDL_EXT)
			
			fsa.outputPath = DEPLOY_DIR+post_dir		
			fsa.generateFile(filenames.get(i) +".fdepl", conn.generateFrancaDeployment(protobufidls.get(i), specificfile, fidl_dir, filenames.get(i)))
			
			val fmodelRef = loadModel(REF_DIR+post_dir + filenames.get(i) + FRANCA_IDL_EXT)
			EcoreUtil.resolveAll(fmodelRef.eResource)
			
			// use EMF Compare to compare both Franca IDL models (the generated and the reference model)
			val rset2 = fmodelRef.eResource.resourceSet
			val rset1 = fmodelGens.get(i).eResource.resourceSet //TODO
	
			val scope = EMFCompare.createDefaultScope(rset1, rset2)
			val comparison = EMFCompare.builder.build.compare(scope)
			val List<Diff> differences = comparison.differences
			var nDiffs = 0
			for (diff : differences) {
				if (! (diff instanceof ResourceAttachmentChangeSpec)) {
					System.out.println(diff.toString)
					nDiffs++
				}
			}
			assertEquals(0, nDiffs)
		}
	}

	/**
	 * Utility method for executing one transformation and comparing the result with a reference model.
	 */
	private def test(String inputfile) {
		test(inputfile,SPEC_FILE,FIDL_DIR,"")
	}
}
