/*******************************************************************************
 * Copyright (c) 2018 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.deploymodel.dsl.tests.xpect.util

import com.google.inject.Inject
import com.google.inject.Injector
import org.eclipse.jface.text.contentassist.ICompletionProposal
import org.eclipse.xtext.resource.XtextResource
import org.eclipse.xtext.ui.editor.contentassist.ConfigurableCompletionProposal
import org.eclipse.xtext.ui.editor.model.DocumentPartitioner
import org.eclipse.xtext.ui.editor.model.XtextDocument
import org.eclipse.xtext.util.IResourceScopeCache
import org.junit.runner.RunWith
import org.xpect.XpectImport
import org.xpect.expectation.CommaSeparatedValuesExpectation
import org.xpect.expectation.ICommaSeparatedValuesExpectation
import org.xpect.parameter.ParameterParser
import org.xpect.runner.Xpect
import org.xpect.xtext.lib.setup.ThisResource
import org.xpect.xtext.lib.setup.XtextStandaloneSetup
import org.xpect.xtext.lib.setup.XtextWorkspaceSetup
import org.xpect.xtext.lib.tests.ValidationTestModuleSetup
import org.xpect.xtext.lib.tests.ValidationTestModuleSetup.IssuesByLineProvider
import org.xpect.xtext.lib.tests.XtextTests

/**
 * Xpect-based UI test class for DSL content-assist and proposal providers.   
 */
@RunWith(FDeployXpectRunner)
@XpectImport(#[
	IssuesByLineProvider,
	ValidationTestModuleSetup,
	XtextStandaloneSetup,
	XtextWorkspaceSetup
])
class ProposalProviderUITest extends XtextTests {
	@Inject package IResourceScopeCache cache
	@Inject package Injector injector
	@Inject package XpectContentAssistProcessorTestBuilder.Factory factory

	@ParameterParser(syntax="('at' arg2=OFFSET)?")
	//@ConsumedIssues({ Severity.ERROR, Severity.WARNING })
	@Xpect
	def void proposals(
		@CommaSeparatedValuesExpectation ICommaSeparatedValuesExpectation expectation,
		@ThisResource XtextResource resource,
		int arg2
	) throws Exception {
		var fixture = factory.create(resource.xtextDocument)
		val offset = arg2
		var ICompletionProposal[] proposals = fixture.computeCompletionProposals(offset)

		// get list of proposals and compare
		val Iterable<String> replacementStrings = proposals.filter(ConfigurableCompletionProposal).map[replacementString]
		expectation.assertEquals(replacementStrings)
	}

	def private XtextDocument getXtextDocument(XtextResource xtextResource) {
		return cache.get(xtextResource, xtextResource, [
			var XtextDocument document = injector.getInstance(XtextDocument)
			document.set(xtextResource.getParseResult().getRootNode().getText())
			document.setInput(xtextResource)
			var DocumentPartitioner partitioner = injector.getInstance(DocumentPartitioner)
			partitioner.connect(document)
			document.setDocumentPartitioner(partitioner)
			return document
		])
	}
}
