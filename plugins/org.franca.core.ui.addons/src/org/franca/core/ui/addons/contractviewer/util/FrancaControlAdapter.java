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
