/*******************************************************************************
* Copyright (c) 2012 Harman International (http://www.harman.com).
* All rights reserved. This program and the accompanying materials
* are made available under the terms of the Eclipse Public License v1.0
* which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/epl-v10.html
*******************************************************************************/
package org.franca.core.dsl.validation.internal;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EStructuralFeature;

public interface ValidationMessageReporter {
	void reportError(String message, EObject object, EStructuralFeature feature);
	void reportError(String message, EObject object, EStructuralFeature feature, int index);

	void reportWarning(String message, EObject object, EStructuralFeature feature);
}
