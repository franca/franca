/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.deploymodel.dsl.formatting;

import org.eclipse.xtext.IGrammarAccess;
import org.eclipse.xtext.Keyword;
import org.eclipse.xtext.formatting.impl.AbstractDeclarativeFormatter;
import org.eclipse.xtext.formatting.impl.FormattingConfig;
import org.eclipse.xtext.util.Pair;
import org.franca.deploymodel.dsl.services.FDeployGrammarAccess;

/**
 * This class contains custom formatting description.
 * 
 * see : http://www.eclipse.org/Xtext/documentation/latest/xtext.html#formatting
 * on how and when to use it 
 * 
 * Also see {@link org.eclipse.xtext.xtext.XtextFormattingTokenSerializer} as an example
 */
public class FDeployFormatter extends AbstractDeclarativeFormatter {
	
	@Override
	protected void configureFormatting(FormattingConfig c) {
		IGrammarAccess ga = getGrammarAccess();
		if (! (ga instanceof FDeployGrammarAccess))
			return;
		
		FDeployGrammarAccess f = (FDeployGrammarAccess)ga;
		
		// add newlines around comments
		c.setLinewrap(0, 1, 2).before(f.getSL_COMMENTRule());
		c.setLinewrap(0, 1, 2).before(f.getML_COMMENTRule());
		c.setLinewrap(0, 1, 1).after(f.getML_COMMENTRule());
		
		// standard comma formatting
		for(Keyword comma: f.findKeywords(",")) {
			c.setNoLinewrap().before(comma);
			c.setNoSpace().before(comma);
//			c.setLinewrap().after(comma);
		}

		// generic formatting of curly bracket sections
		for(Pair<Keyword, Keyword> pair: f.findKeywordPairs("{", "}")) {
			c.setIndentationIncrement().after(pair.getFirst());
			c.setIndentationDecrement().before(pair.getSecond());
//			c.setIndentation(pair.getFirst(), pair.getSecond());
			c.setLinewrap(1).after(pair.getFirst());
			c.setLinewrap(1).before(pair.getSecond());
			c.setLinewrap(1).after(pair.getSecond());
		}

		// property declaration lists in deployment specification
		c.setLinewrap(1).around(f.getFDPropertyDeclRule());

		// property lists
		c.setLinewrap(1).around(f.getFDPropertyRule());

		// top-level formatting
		c.setLinewrap(1).around(f.getImportRule());
		c.setLinewrap(1).before(f.getFDSpecificationRule());
		c.setLinewrap(2).before(f.getFDTypesRule());
		c.setLinewrap(2).before(f.getFDInterfaceRule());
		c.setLinewrap(2).around(f.getFDAttributeRule());
		c.setLinewrap(2).around(f.getFDMethodRule());
		c.setLinewrap(2).around(f.getFDBroadcastRule());
		c.setLinewrap(2).around(f.getFDTypeDefinitionRule());
		
		// some details...
		c.setNoLinewrap().after(f.getFDTypesAccess().getAsKeyword_5_0());
		c.setNoLinewrap().after(f.getFDTypesAccess().getForKeyword_2());
		c.setNoLinewrap().after(f.getFDInterfaceAccess().getAsKeyword_5_0());
		c.setNoLinewrap().after(f.getFDInterfaceAccess().getForKeyword_2());
	}
}
