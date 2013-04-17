package org.franca.core.ui.addons.contractviewer.part;

import java.util.ArrayList;
import java.util.List;

import org.eclipse.draw2d.Figure;
import org.eclipse.draw2d.FreeformLayer;
import org.eclipse.draw2d.FreeformLayout;
import org.eclipse.draw2d.GridLayout;
import org.eclipse.draw2d.IFigure;
import org.eclipse.draw2d.MarginBorder;
import org.eclipse.gef.editparts.AbstractGraphicalEditPart;
import org.franca.core.franca.FInterface;
import org.franca.core.franca.FModel;
import org.franca.core.franca.FState;

public class TopEditPart extends AbstractGraphicalEditPart {
	
	protected IFigure createFigure() {
		Figure f = new FreeformLayer();
		f.setLayoutManager(new FreeformLayout());
		f.setBorder(new MarginBorder(1));
		GridLayout gridLayout = new GridLayout();
		gridLayout.numColumns = 3;
		gridLayout.horizontalSpacing = 40;
		gridLayout.verticalSpacing = 40;
		gridLayout.marginHeight = 20;
		gridLayout.marginWidth = 20;
		f.setLayoutManager(gridLayout);
		f.setOpaque(true);
		return f;
	}

	@Override
	protected void createEditPolicies() {

	}

	@Override
	protected List<FState> getModelChildren() {
		List<FState> nodes = new ArrayList<FState>();
		FModel model = (FModel) getModel();

		for (FInterface _interface : model.getInterfaces()) {
			nodes.addAll(_interface.getContract().getStateGraph().getStates());
		}

		return nodes;
	}
}
