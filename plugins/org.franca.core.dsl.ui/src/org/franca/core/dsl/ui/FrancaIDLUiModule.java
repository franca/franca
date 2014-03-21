/*******************************************************************************
* Copyright (c) 2014 itemis AG (http://www.itemis.de).
* All rights reserved. This program and the accompanying materials
* are made available under the terms of the Eclipse Public License v1.0
* which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/epl-v10.html
*******************************************************************************/
package org.franca.core.dsl.ui;

import org.eclipse.ui.plugin.AbstractUIPlugin;
import org.eclipse.xtext.ui.editor.syntaxcoloring.AbstractAntlrTokenToAttributeIdMapper;
import org.eclipse.xtext.ui.editor.syntaxcoloring.IHighlightingConfiguration;
import org.eclipse.xtext.ui.editor.syntaxcoloring.ISemanticHighlightingCalculator;
import org.franca.core.dsl.ui.highlighting.FrancaAntlrTokenToAttributeIdMapper;
import org.franca.core.dsl.ui.highlighting.FrancaHighlightingConfiguration;
import org.franca.core.dsl.ui.highlighting.FrancaSemanticHighlightingCalculator;

/**
 * Use this class to register components to be used within the IDE.
 * 
 * This version of the module assumes that org.eclipse.jdt.core and dependent 
 * plug-ins are installed in the runtime platform. If not, FrancaIDLUiModuleWithoutJDT
 * should be used.
 * 
 * @see FrancaIDLUiModuleWithoutJDT
 */
public class FrancaIDLUiModule extends
		org.franca.core.dsl.ui.AbstractFrancaIDLUiModule {
	public FrancaIDLUiModule(AbstractUIPlugin plugin) {
		super(plugin);
	}

	// inject own highlighting configuration
	public Class<? extends IHighlightingConfiguration> bindSemanticConfig() {
		return FrancaHighlightingConfiguration.class;
	}

	// inject own semantic highlighting
	public Class<? extends ISemanticHighlightingCalculator> bindSemanticHighlightingCalculator() {
		return FrancaSemanticHighlightingCalculator.class;
	}
	
	public Class<? extends AbstractAntlrTokenToAttributeIdMapper> bindAbstractAntlrTokenToAttributeIdMapper() {
		return FrancaAntlrTokenToAttributeIdMapper.class;
	}

}
