/** 
 * Copyright (c) 2018 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package org.franca.deploymodel.dsl.ide.highlighting

import com.google.inject.Inject
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.EcoreUtil2
import org.eclipse.xtext.RuleCall
import org.eclipse.xtext.ide.editor.syntaxcoloring.IHighlightedPositionAcceptor
import org.eclipse.xtext.ide.editor.syntaxcoloring.ISemanticHighlightingCalculator
import org.eclipse.xtext.nodemodel.INode
import org.eclipse.xtext.nodemodel.util.NodeModelUtils
import org.eclipse.xtext.resource.XtextResource
import org.eclipse.xtext.util.CancelIndicator
import org.franca.deploymodel.dsl.fDeploy.FDAbstractExtensionElement
import org.franca.deploymodel.dsl.fDeploy.FDExtensionType
import org.franca.deploymodel.dsl.fDeploy.FDModel
import org.franca.deploymodel.dsl.fDeploy.FDeployPackage
import org.franca.deploymodel.dsl.services.FDeployGrammarAccess

class FDeploySemanticHighlightingCalculator implements ISemanticHighlightingCalculator {

	@Inject
	FDeployGrammarAccess ga

	// @Override
	override void provideHighlightingFor(
		XtextResource resource,
		IHighlightedPositionAcceptor acceptor,
		CancelIndicator cancelIndicator
	) {
		if (resource?.parseResult === null)
			return

		// highlight hosts from extensions as normal keywords
		val INode root = resource.parseResult.rootNode
		for(INode node : root.getAsTreeIterable) {
			val EObject ruleCall = node.grammarElement
			if (ruleCall instanceof RuleCall) {
				val String name = ruleCall.rule.name
				if (name == ga.PROPERTY_HOSTRule.name) {
					//println("Highlighting node " + node.offset + ", length " + node.length)
					acceptor.addPosition(node.offset, node.length, FDeployHighlightingStyles.KEYWORD_ID)
				}
			}
		}
		// highlight all tags of extension roots and extension elements as normal keywords
		val model = resource.parseResult.rootASTElement
		if (model!==null && model instanceof FDModel) {
			val elements = EcoreUtil2.getAllContentsOfType(model, FDAbstractExtensionElement)
			for(elem : elements) {
				for(INode node : NodeModelUtils.findNodesForFeature(elem,
					FDeployPackage.Literals.FD_ABSTRACT_EXTENSION_ELEMENT__TAG)) {
					acceptor.addPosition(node.offset, node.length, FDeployHighlightingStyles.KEYWORD_ID)
				}
			}
		}
		// highlight all names of extension types as normal keywords
		if (model!==null && model instanceof FDModel) {
			val types = EcoreUtil2.getAllContentsOfType(model, FDExtensionType)
			for(type : types) {
				for(INode node : NodeModelUtils.findNodesForFeature(type,
					FDeployPackage.Literals.FD_EXTENSION_TYPE__NAME)) {
					acceptor.addPosition(node.offset, node.length, FDeployHighlightingStyles.KEYWORD_ID)
				}
			}
		}
	}
}
