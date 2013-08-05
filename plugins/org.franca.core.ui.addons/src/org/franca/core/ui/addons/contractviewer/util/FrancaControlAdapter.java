/*******************************************************************************
 * Copyright (c) 2012 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.core.ui.addons.contractviewer.util;

import org.eclipse.swt.events.ControlAdapter;
import org.eclipse.swt.events.ControlEvent;
import org.franca.core.ui.addons.contractviewer.FrancaContractVisualizerView;

public class FrancaControlAdapter extends ControlAdapter {

	@Override
	public void controlResized(ControlEvent e) {
		FrancaContractVisualizerView view = FrancaContractVisualizerView.getInstance();
		if (view != null) {
			view.applyLayout();
		}
		super.controlResized(e);
	}	
}
