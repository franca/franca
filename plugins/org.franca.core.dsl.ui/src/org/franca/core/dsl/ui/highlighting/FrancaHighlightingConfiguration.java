package org.franca.core.dsl.ui.highlighting;

import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.RGB;
import org.eclipse.xtext.ui.editor.syntaxcoloring.DefaultHighlightingConfiguration;
import org.eclipse.xtext.ui.editor.syntaxcoloring.IHighlightingConfigurationAcceptor;
import org.eclipse.xtext.ui.editor.utils.TextStyle;


public class FrancaHighlightingConfiguration extends DefaultHighlightingConfiguration {

	// provide an id string for the highlighting calculator
	public static final String HL_ANNOTATION_BLOCK_ID = "hl_annotation_block";

	// default fonts used by this specific highlighting (defaults)
//	private static FontData defaultAnnotationBlockFont = new FontData("Courier New", 12);

	// configure the acceptor providing the id, the description string
	// that will appear in the preference page and the initial text style
	public void configure(IHighlightingConfigurationAcceptor acceptor) {
		super.configure(acceptor);
		acceptor.acceptDefaultHighlighting(HL_ANNOTATION_BLOCK_ID, "Annotation block", typeAnnotationBlock());
	}

	// method for calculating an actual text styles
	public TextStyle typeAnnotationBlock() {
		TextStyle textStyle = new TextStyle();
		//textStyle.setBackgroundColor(new RGB(155, 55, 255));
		textStyle.setColor(new RGB(100, 149, 237));
		textStyle.setStyle(SWT.ITALIC);
//		textStyle.setFontData(defaultCommentFont);
		return textStyle;
	}

}

