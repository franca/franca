package org.franca.core.validation.runtime;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EStructuralFeature;
import org.eclipse.jdt.annotation.NonNull;
import org.eclipse.xtext.diagnostics.Severity;

public class Issue {

	private EObject source;
	private EStructuralFeature feature;
	private String message;
	private Severity severity;

	public Issue(String message, Severity severity) {
		this(message, null, null, severity);
	}
	
	public Issue(String message, EObject source, Severity severity) {
		this(message, source, null, severity);
	}
	
	public Issue(@NonNull String message, @NonNull EObject source, @NonNull EStructuralFeature feature,
			@NonNull Severity severity) {
		super();
		this.message = message;
		this.source = source;
		this.feature = feature;
		this.severity = severity;
	}
	
	public String getMessage() {
		return message;
	}
	
	public Severity getSeverity() {
		return severity;
	}
	
	public EObject getSource() {
		return source;
	}
	
	public EStructuralFeature getFeature() {
		return feature;
	}
}
