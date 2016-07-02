/*******************************************************************************
 * Copyright (c) 2016 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.core.dsl.tests.util

import com.google.inject.Inject
import java.util.List
import org.eclipse.emf.compare.Diff
import org.eclipse.emf.compare.EMFCompare
import org.eclipse.emf.compare.internal.spec.ResourceAttachmentChangeSpec
import org.eclipse.emf.compare.scope.DefaultComparisonScope
import org.eclipse.emf.ecore.util.EcoreUtil
import org.franca.core.dsl.FrancaPersistenceManager
import org.franca.core.dsl.tests.compare.ComparisonHtmlReportGenerator
import org.franca.core.dsl.tests.compare.ComparisonTextReportGenerator
import org.franca.core.framework.FrancaModelContainer
import org.franca.core.franca.FModel
import org.franca.core.utils.FileHelper

class TransformationTestBase extends ModelValidator {

	val protected FRANCA_IDL_EXT = "." + FrancaPersistenceManager.FRANCA_FILE_EXTENSION

	@Inject
	protected extension FrancaPersistenceManager
	

	/**
	 * Compare two Franca models using EMFCompare and report the differences.</p>
	 * 
	 * The first Franca model has been created during the transformation under test.
	 * It should have been saved to file because EMFCompare needs a proper resource.</p>
	 * 
	 * The second Franca model is the reference model which has been loaded from the
	 * filesystem.</p>
	 */
	def protected int finalizeTest(
		FrancaModelContainer fmodelGen,
		FModel fmodelRef,
		String inputFileName, String diffReportFolder
	) {
		// resolve all references in reference model
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
				FileHelper.save(diffReportFolder, inputFileName + "_diff.html", html)
			}
		}
		
		/* 
		 * Only works in a standalone environment (need to be put in a plug-in project and
		 * used through a new Eclipse runtime).
		 * See: https://www.eclipse.org/forums/index.php?t=msg&th=853557/
		 */
//			val editingDomain = EMFCompareEditingDomain.create(scope.left,scope.right,null)
//			val adapterFactory = new ComposedAdapterFactory(ComposedAdapterFactory.Descriptor.Registry.INSTANCE)
//			val input = new ComparisonEditorInput(new EMFCompareConfiguration(new CompareConfiguration()), comparison, editingDomain, adapterFactory)
//			CompareUI.openCompareEditor(input)

		nDiffs
	}
}