/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.core.ui.addons.wizard.packageselection;

import java.util.ArrayList;
import java.util.List;

import org.eclipse.core.resources.IContainer;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.swt.SWT;
import org.eclipse.swt.widgets.Composite;

public abstract class PackageSelector extends Composite {

	protected List<IPackageSelectorChangeListener> listeners;
	protected IContainer container;
	
	public PackageSelector(Composite parent) {
		super(parent, SWT.NONE);
		this.listeners = new ArrayList<IPackageSelectorChangeListener>();
	}
	
	public IContainer getContainer() {
		return container;
	}
	
	public void setContainer(IContainer container) {
		this.container = container;
	}
	
	public void registerPackageSelectorChangedListener(IPackageSelectorChangeListener listener) {
		this.listeners.add(listener);
	}
	
	public void unregisterPackageSelectorChangedListener(IPackageSelectorChangeListener listener) {
		this.listeners.remove(listener);
	}
	
	public abstract IStatus validate();
	
	public abstract String getPackageName();

}
