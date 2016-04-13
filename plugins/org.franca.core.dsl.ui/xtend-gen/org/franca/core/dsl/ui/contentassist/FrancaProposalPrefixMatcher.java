package org.franca.core.dsl.ui.contentassist;

import com.google.common.base.Objects;
import org.eclipse.xtext.ui.editor.contentassist.FQNPrefixMatcher;

@SuppressWarnings("all")
public class FrancaProposalPrefixMatcher extends FQNPrefixMatcher {
  public boolean isCandidateMatchingPrefix(final String name, final String prefix) {
    boolean _xblockexpression = false;
    {
      boolean _or = false;
      boolean _equals = Objects.equal(prefix, "\"platform:");
      if (_equals) {
        _or = true;
      } else {
        boolean _equals_1 = Objects.equal(prefix, "\"classpath:");
        _or = _equals_1;
      }
      if (_or) {
        return true;
      }
      _xblockexpression = super.isCandidateMatchingPrefix(name, prefix);
    }
    return _xblockexpression;
  }
}
