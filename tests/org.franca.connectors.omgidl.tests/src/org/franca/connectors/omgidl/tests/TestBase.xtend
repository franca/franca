/*******************************************************************************
 * Copyright (c) 2016 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.connectors.omgidl.tests

import com.google.inject.Inject
import java.util.List
import org.eclipse.emf.compare.Diff
import org.eclipse.emf.compare.EMFCompare
import org.eclipse.emf.compare.internal.spec.ResourceAttachmentChangeSpec
import org.eclipse.emf.compare.scope.DefaultComparisonScope
import org.eclipse.emf.ecore.util.EcoreUtil
import org.franca.connectors.omgidl.OMGIDLConnector
import org.franca.connectors.omgidl.OMGIDLModelContainer
import org.franca.core.dsl.FrancaPersistenceManager
import org.franca.core.dsl.tests.compare.ComparisonHtmlReportGenerator
import org.franca.core.dsl.tests.compare.ComparisonTextReportGenerator
import org.franca.core.utils.FileHelper

import static org.junit.Assert.assertEquals

class TestBase {

	val OMG_IDL_EXT = ".idl"
	val FRANCA_IDL_EXT = "." + FrancaPersistenceManager.FRANCA_FILE_EXTENSION

	@Inject	extension FrancaPersistenceManager
	

	def protected testTransformation(String inputfile, String model_dir, String gen_dir, String ref_dir) {
		// load the OMG IDL input model (may consist of multiple files)
		val conn = new OMGIDLConnector
		val omgidl = conn.loadModel(model_dir + inputfile + OMG_IDL_EXT) as OMGIDLModelContainer

		// transform to Franca 
		val fmodelGen = conn.toFranca(omgidl)
		val rootModelName = fmodelGen.modelName

		// save transformed Franca file(s)
		fmodelGen.model.saveModel(gen_dir + rootModelName + FRANCA_IDL_EXT, fmodelGen)
		
		// load the reference Franca IDL model and resolve whole model explicitly
		val fmodelRef = loadModel(ref_dir + rootModelName + FRANCA_IDL_EXT)
		EcoreUtil.resolveAll(fmodelRef.eResource.resourceSet)

		// use EMF Compare to compare both Franca IDL models (the generated and the reference model)
		val rset1 = fmodelGen.model.eResource.resourceSet
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
		val genText = new ComparisonTextReportGenerator
		val genHTML = new ComparisonHtmlReportGenerator
		for(m : comparison.matches) {
			if (m.allDifferences.size() > 0) {
				println(genText.generateReport(m))
				val html = genHTML.generateReport(m)
				FileHelper.save("target/surefire-reports", inputfile + "_diff.html", html)
			}
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