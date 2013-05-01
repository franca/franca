package org.franca.core.utils;

import java.util.Collection;
import org.eclipse.xtext.validation.Issue;

import org.eclipse.emf.ecore.resource.Resource;

/**
 * Interface for validators of multi-resource models consisting of fidl- and fdepl-files.
 * 
 * @author Klaus Birken (itemis)
 */
public interface IFrancaValidator {
	Collection<Issue> validate (Resource resource);
	Collection<Issue> validate (Resource resource, boolean recursive);
}
