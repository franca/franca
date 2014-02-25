/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.core.ui.addons.wizard.packageselection;

import org.eclipse.core.resources.IResource;
import org.eclipse.core.runtime.IStatus;

public interface IPackageSelector {

	public IStatus getStatus();
	
	public String getPackageName();
	
	public void setContainer(IResource resource);
	
	public void registerPackageSelectorChangedListener(IPackageSelectorChangeListener listener);
	
	public void unregisterPackageSelectorChangedListener(IPackageSelectorChangeListener listener);
	
}
