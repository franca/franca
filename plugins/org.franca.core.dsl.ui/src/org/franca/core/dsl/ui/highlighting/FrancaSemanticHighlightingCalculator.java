package org.franca.core.dsl.ui.highlighting;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.xtext.RuleCall;
import org.eclipse.xtext.nodemodel.INode;
import org.eclipse.xtext.resource.XtextResource;
import org.eclipse.xtext.ui.editor.syntaxcoloring.IHighlightedPositionAcceptor;
import org.eclipse.xtext.ui.editor.syntaxcoloring.ISemanticHighlightingCalculator;

public class FrancaSemanticHighlightingCalculator implements ISemanticHighlightingCalculator {

	// @Override
	public void provideHighlightingFor(XtextResource resource, IHighlightedPositionAcceptor acceptor) {
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
							FrancaHighlightingConfiguration.HL_ANNOTATION_BLOCK_ID);
				}
			}
		}

	}

}
