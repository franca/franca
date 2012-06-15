/*******************************************************************************
* Copyright (c) 2012 Harman International (http://www.harman.com).
* All rights reserved. This program and the accompanying materials
* are made available under the terms of the Eclipse Public License v1.0
* which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/epl-v10.html
*******************************************************************************/
package org.franca.deploymodel.dsl;

/**
 * Version number of the Franca Deployment IDL.
 * Major/minor numbers are handled according to the Apache schema.
 * 
 * @author KBirken
 */
public class FDeployIDLVersion {
	private static final int major = 1;
	private static final int minor = 0;

	public static int getMajor() {
		return major;
	}

	public static int getMinor() {
		return minor;
	}
}
