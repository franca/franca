package org.franca.core.dsl.ui.contentassist

import org.eclipse.xtext.ui.editor.contentassist.FQNPrefixMatcher

class FrancaProposalPrefixMatcher extends FQNPrefixMatcher {
	
	override isCandidateMatchingPrefix(String name, String prefix) {
		if(prefix=="\"platform:"||prefix=="\"classpath:") {return true}
		super.isCandidateMatchingPrefix(name,prefix)	
	}
	
}