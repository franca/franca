/*******************************************************************************
* Copyright (c) 2012 Harman International (http://www.harman.com).
* All rights reserved. This program and the accompanying materials
* are made available under the terms of the Eclipse Public License v1.0
* which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/epl-v10.html
*******************************************************************************/
package org.franca.core.dsl;

import org.franca.core.FrancaModelVersion;

/**
 * Version number of the Franca IDL.
 * Major/minor numbers are handled according to the Apache schema.
 * 
 * @author KBirken
 */
public class FrancaIDLVersion {
	// currently the IDL version is derived from the Ecore model version.
	// this might change someday (but will most likely not).
	private static final int major = FrancaModelVersion.getMajor();
	private static final int minor = FrancaModelVersion.getMinor();

	public static int getMajor() {
		return major;
	}

	public static int getMinor() {
		return minor;
	}
}
