package org.franca.core.ui.addons.contractviewer.part;

import org.eclipse.gef.EditPart;
import org.eclipse.gef.EditPartFactory;
import org.franca.core.franca.FModel;
import org.franca.core.franca.FState;
import org.franca.core.franca.FTransition;

public class GraphicalEditPartFactory implements EditPartFactory {

	public EditPart createEditPart(EditPart context, Object model) {
		EditPart editPart = null;
		if (model instanceof FModel) {
			editPart = new TopEditPart();
		} else if (model instanceof FState) {
			editPart = new StateEditPart();
		} else if (model instanceof FTransition) {
			editPart = new TransitionEditPart();
		}

		if (editPart != null) {
			editPart.setModel(model);
		}
		
		return editPart;
	}
}
