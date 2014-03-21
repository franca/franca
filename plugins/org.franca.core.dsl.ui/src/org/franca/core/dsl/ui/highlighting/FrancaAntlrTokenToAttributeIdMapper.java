package org.franca.core.dsl.ui.highlighting;

import org.eclipse.xtext.ui.editor.syntaxcoloring.DefaultAntlrTokenToAttributeIdMapper;
import org.eclipse.xtext.ui.editor.syntaxcoloring.DefaultHighlightingConfiguration;

public class FrancaAntlrTokenToAttributeIdMapper extends
		DefaultAntlrTokenToAttributeIdMapper {

	@Override
	protected String calculateId(String tokenName, int tokenType) {
		if("RULE_HEX".equals(tokenName)) {
			return DefaultHighlightingConfiguration.NUMBER_ID;
		}
		return super.calculateId(tokenName, tokenType);
	}
}
