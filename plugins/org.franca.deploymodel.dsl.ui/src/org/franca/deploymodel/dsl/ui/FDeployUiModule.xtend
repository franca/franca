/** 
 * Copyright (c) 2014 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package org.franca.deploymodel.dsl.ui

import org.eclipse.ui.plugin.AbstractUIPlugin
import org.eclipse.xtext.ide.editor.syntaxcoloring.ISemanticHighlightingCalculator
import org.franca.deploymodel.dsl.ide.highlighting.FDeploySemanticHighlightingCalculator

/** 
 * Use this class to register components to be used within the IDE.
 * This version of the module assumes that org.eclipse.jdt.core and dependent 
 * plug-ins are installed in the runtime platform. If not, FDeployUiModuleWithoutJDT
 * should be used.
 * @see FDeployUiModuleWithoutJDT
 */
class FDeployUiModule extends AbstractFDeployUiModule {
	new(AbstractUIPlugin plugin) {
		super(plugin)
	}

	// inject own semantic highlighting
	def Class<? extends ISemanticHighlightingCalculator> bindSemanticHighlightingCalculator() {
		return FDeploySemanticHighlightingCalculator
	}

}
