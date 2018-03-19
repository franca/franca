/** 
 * Copyright (c) 2018 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package org.franca.deploymodel.dsl.ide.highlighting;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.xtext.EcoreUtil2;
import org.eclipse.xtext.RuleCall;
import org.eclipse.xtext.ide.editor.syntaxcoloring.IHighlightedPositionAcceptor;
import org.eclipse.xtext.ide.editor.syntaxcoloring.ISemanticHighlightingCalculator;
import org.eclipse.xtext.nodemodel.INode;
import org.eclipse.xtext.nodemodel.util.NodeModelUtils;
import org.eclipse.xtext.resource.XtextResource;
import org.eclipse.xtext.util.CancelIndicator;
import org.franca.deploymodel.dsl.fDeploy.FDAbstractExtensionElement;
import org.franca.deploymodel.dsl.fDeploy.FDModel;
import org.franca.deploymodel.dsl.fDeploy.FDeployPackage;

public class FDeploySemanticHighlightingCalculator implements ISemanticHighlightingCalculator {

	// @Override
	public void provideHighlightingFor(XtextResource resource, IHighlightedPositionAcceptor acceptor, CancelIndicator cancelIndicator) {
		if (resource == null || resource.getParseResult() == null)
			return;

		// highlight hosts from extensions as normal keywords
		INode root = resource.getParseResult().getRootNode();
		for (INode node : root.getAsTreeIterable()) {
			EObject obj = node.getGrammarElement();
			if (obj instanceof RuleCall) {
				RuleCall ruleCall = (RuleCall) obj;
				String name = ruleCall.getRule().getName();
				if (name.equals("PROPERTY_HOST")) {
					//System.out.println("Highlighting node " + node.getOffset() + ", length " + node.getLength());
					acceptor.addPosition(node.getOffset(), node.getLength(), FDeployHighlightingStyles.KEYWORD_ID);
				}
			}
		}

		// highlight all tags of extension roots and extension elements as normal keywords
		FDModel model = (FDModel) resource.getContents().get(0);
		for(FDAbstractExtensionElement elem : EcoreUtil2.getAllContentsOfType(model, FDAbstractExtensionElement.class)) {
			for(INode node : NodeModelUtils.findNodesForFeature(elem, FDeployPackage.Literals.FD_ABSTRACT_EXTENSION_ELEMENT__TAG)) {
				acceptor.addPosition(node.getOffset(), node.getLength(), FDeployHighlightingStyles.KEYWORD_ID);
			}
		}
	}

}
