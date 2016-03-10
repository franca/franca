package org.franca.connectors.omgidl.tests

import static org.junit.Assert.assertEquals
import org.eclipse.emf.compare.Comparison
import org.eclipse.emf.compare.Diff
import org.eclipse.emf.compare.EMFCompare
import com.google.inject.Inject
import java.util.List
import org.eclipse.xtext.junit4.InjectWith
import org.eclipselabs.xtext.utils.unittesting.XtextRunner2
import org.franca.connectors.omgidl.OMGIDLConnector
import org.franca.connectors.omgidl.OMGIDLModelContainer
import org.franca.core.dsl.FrancaIDLTestsInjectorProvider
import org.franca.core.dsl.FrancaPersistenceManager
import org.junit.Test
import org.junit.runner.RunWith
import org.eclipse.emf.compare.internal.spec.ResourceAttachmentChangeSpec

@RunWith(typeof(XtextRunner2))
@InjectWith(typeof(FrancaIDLTestsInjectorProvider))
class OMGIDL2FrancaTests {

	val MODEL_DIR = "model/testcases/"
	val REF_DIR = "model/reference/"
	val GEN_DIR = "src-gen/testcases/"
	
	@Inject	extension FrancaPersistenceManager

	@Test
	def test_10() {
		test("10-EmptyInterface")
	}

	// TODO: add more testcases here


	/**
	 * Utility method for executing one transformation and comparing the result with a reference model.
	 */
	def private test(String inputfile) {
		val OMG_IDL_EXT = ".idl"
		val FRANCA_IDL_EXT = ".fidl"

		// load the OMG IDL input model
		val conn = new OMGIDLConnector
		val omgidl = conn.loadModel(MODEL_DIR + inputfile + OMG_IDL_EXT) as OMGIDLModelContainer
		
		// do the actual transformation to Franca IDL and save the result
		val fmodelGen = conn.toFranca(omgidl)
		fmodelGen.saveModel(GEN_DIR + inputfile + FRANCA_IDL_EXT)
		
		// load the reference Franca IDL model
		val fmodelRef = loadModel(REF_DIR + inputfile + FRANCA_IDL_EXT)

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

		// TODO: is there a way to show the difference in a side-by-side view if the test fails?
		// (EMF Compare should provide a nice view for this...)		

		// we expect that both Franca IDL models are identical 
		assertEquals(0, nDiffs)
	}
}
