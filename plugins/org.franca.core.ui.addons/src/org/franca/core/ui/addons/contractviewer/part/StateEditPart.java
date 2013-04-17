package org.franca.core.ui.addons.contractviewer.part;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import org.eclipse.draw2d.ChopboxAnchor;
import org.eclipse.draw2d.Ellipse;
import org.eclipse.draw2d.IFigure;
import org.eclipse.draw2d.Label;
import org.eclipse.draw2d.PositionConstants;
import org.eclipse.draw2d.geometry.Rectangle;
import org.eclipse.gef.editparts.AbstractGraphicalEditPart;
import org.eclipse.jface.util.PropertyChangeEvent;
import org.franca.core.franca.FState;
import org.franca.core.franca.FTransition;
import org.franca.core.ui.addons.contractviewer.FrancaContractVisualizerView;

public class StateEditPart extends AbstractGraphicalEditPart {

	private ChopboxAnchor m_anchor;

	@Override
	protected IFigure createFigure() {
		IFigure ellipse = new Ellipse();
		m_anchor = new ChopboxAnchor(ellipse);
		return ellipse;
	}

	@Override
	protected void createEditPolicies() {
		
	}

	@SuppressWarnings("deprecation")
	@Override
	protected void refreshVisuals() {
		FState state = (FState) getModel();
		Rectangle bounds = new Rectangle(50, 50, 100, 50);
		getFigure().setBounds(bounds);
		Label label = new Label(state.getName());
		label.setTextAlignment(PositionConstants.CENTER);
		label.setBounds(bounds.crop(IFigure.NO_INSETS));
		getFigure().add(label);
	}

	public void propertyChange(PropertyChangeEvent evt) {
		
	}

	@Override
	protected List<FTransition> getModelSourceConnections() {
		FState state = (FState) getModel();
		return state.getTransitions();
	}

	@Override
	protected List<FTransition> getModelTargetConnections() {
		FrancaContractVisualizerView view = FrancaContractVisualizerView.getInstance();
		if (view != null) {
			FState state = (FState) getModel();
			return new ArrayList<FTransition>(view.getBackwardIndex().get(state));
		}
		return Collections.emptyList();
	}
}
