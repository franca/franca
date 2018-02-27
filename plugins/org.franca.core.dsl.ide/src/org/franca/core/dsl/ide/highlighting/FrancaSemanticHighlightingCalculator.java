/** 
 * Copyright (c) 2018 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package org.franca.core.dsl.ide.highlighting;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.xtext.RuleCall;
import org.eclipse.xtext.ide.editor.syntaxcoloring.IHighlightedPositionAcceptor;
import org.eclipse.xtext.ide.editor.syntaxcoloring.ISemanticHighlightingCalculator;
import org.eclipse.xtext.nodemodel.INode;
import org.eclipse.xtext.resource.XtextResource;
import org.eclipse.xtext.util.CancelIndicator;

public class FrancaSemanticHighlightingCalculator implements ISemanticHighlightingCalculator {

	// @Override
	public void provideHighlightingFor(XtextResource resource, IHighlightedPositionAcceptor acceptor, CancelIndicator cancelIndicator) {
		if (resource == null || resource.getParseResult() == null)
			return;

		INode root = resource.getParseResult().getRootNode();
		for (INode node : root.getAsTreeIterable()) {
			EObject obj = node.getGrammarElement();
			if (obj instanceof RuleCall) {
				RuleCall ruleCall = (RuleCall) obj;
				String name = ruleCall.getRule().getName();
				if (name.equals("FAnnotationBlock") || name.equals("CommentString")) {
					// System.out.println("Highlighting node " +
					// node.getOffset() + ", length " + node.getLength());
					acceptor.addPosition(node.getOffset(), node.getLength(),
							FrancaHighlightingStyles.HL_ANNOTATION_BLOCK_ID);
				}
			}
		}

	}

}
