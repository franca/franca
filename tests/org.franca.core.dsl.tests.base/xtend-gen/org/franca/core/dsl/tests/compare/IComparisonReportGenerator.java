package org.franca.core.dsl.tests.compare;

import org.eclipse.emf.compare.Match;

@SuppressWarnings("all")
public interface IComparisonReportGenerator {
  public abstract String generateReport(final Match m);
}
