/** 
 * Copyright (c) 2014 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package org.franca.core.dsl.ui

import com.google.inject.Binder
import com.google.inject.name.Names
import org.eclipse.ui.plugin.AbstractUIPlugin
import org.eclipse.xtext.documentation.IEObjectDocumentationProvider
import org.eclipse.xtext.ide.editor.syntaxcoloring.ISemanticHighlightingCalculator
import org.eclipse.xtext.ui.editor.contentassist.PrefixMatcher
import org.eclipse.xtext.ui.editor.contentassist.XtextContentAssistProcessor
import org.eclipse.xtext.ui.editor.syntaxcoloring.AbstractAntlrTokenToAttributeIdMapper
import org.eclipse.xtext.ui.editor.syntaxcoloring.IHighlightingConfiguration
import org.franca.core.dsl.ide.highlighting.FrancaSemanticHighlightingCalculator
import org.franca.core.dsl.ui.contentassist.FrancaProposalPrefixMatcher
import org.franca.core.dsl.ui.highlighting.FrancaAntlrTokenToAttributeIdMapper
import org.franca.core.dsl.ui.highlighting.FrancaHighlightingConfiguration

/** 
 * Use this class to register components to be used within the IDE.
 * This version of the module assumes that org.eclipse.jdt.core and dependent
 * plug-ins are installed in the runtime platform. If not,
 * FrancaIDLUiModuleWithoutJDT should be used.
 * @see FrancaIDLUiModuleWithoutJDT
 */
class FrancaIDLUiModule extends AbstractFrancaIDLUiModule {
	new(AbstractUIPlugin plugin) {
		super(plugin)
	}

	override void configure(Binder binder) {
		super.configure(binder)
		binder.bind(String).annotatedWith(
			Names.named((XtextContentAssistProcessor.COMPLETION_AUTO_ACTIVATION_CHARS))).
			toInstance(":")
	}

	// inject own highlighting configuration
	def Class<? extends IHighlightingConfiguration> bindSemanticConfig() {
		return FrancaHighlightingConfiguration
	}

	// inject own semantic highlighting
	def Class<? extends ISemanticHighlightingCalculator> bindSemanticHighlightingCalculator() {
		return FrancaSemanticHighlightingCalculator
	}

	def Class<? extends AbstractAntlrTokenToAttributeIdMapper> bindAbstractAntlrTokenToAttributeIdMapper() {
		return FrancaAntlrTokenToAttributeIdMapper
	}

	override Class<? extends PrefixMatcher> bindPrefixMatcher() {
		return FrancaProposalPrefixMatcher
	}

	def Class<? extends IEObjectDocumentationProvider> bindIEObjectDocumentationProviderr() {
        return FrancaIDLDocumentationProvider
    }
}
