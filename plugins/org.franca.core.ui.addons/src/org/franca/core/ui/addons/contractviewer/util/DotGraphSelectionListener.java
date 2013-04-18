package org.franca.core.ui.addons.contractviewer.util;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.gef4.zest.core.widgets.GraphConnection;
import org.eclipse.gef4.zest.core.widgets.GraphNode;
import org.eclipse.gef4.zest.dot.DotGraph;
import org.eclipse.jface.text.TextSelection;
import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.events.SelectionListener;
import org.eclipse.xtext.resource.ILocationInFileProvider;
import org.eclipse.xtext.util.ITextRegion;
import org.franca.core.franca.FInterface;
import org.franca.core.franca.FModel;
import org.franca.core.franca.FState;
import org.franca.core.franca.FTransition;
import org.franca.core.ui.addons.contractviewer.FrancaContractVisualizerView;

import com.google.inject.Inject;

public class DotGraphSelectionListener implements SelectionListener {

	@Inject
	ILocationInFileProvider locationFileProvider;

	@Override
	public void widgetSelected(SelectionEvent e) {
		FrancaContractVisualizerView viewer = FrancaContractVisualizerView
				.getInstance();
		if (viewer != null) {
			Object source = e.getSource();
			EObject affectedObject = null;

			if (source instanceof DotGraph) {
				if (((DotGraph) source).getSelection().size() > 0) {
					Object selected = ((DotGraph) source).getSelection().get(0);
					if (selected instanceof GraphNode) {
						affectedObject = getCorrespondingElement(
								(GraphNode) selected, viewer.getActiveModel());
					} else if (selected instanceof GraphConnection) {
						affectedObject = getCorrespondingElement(
								(GraphConnection) selected,
								viewer.getActiveModel());
					}
				}
			}

			if (affectedObject != null) {
				ITextRegion location = locationFileProvider
						.getSignificantTextRegion(affectedObject);
				if (location != null && viewer != null) {
					viewer.getActiveEditor().reveal(location.getOffset(),
							location.getLength());
					viewer.getActiveEditor()
							.getSelectionProvider()
							.setSelection(
									new TextSelection(location.getOffset(),
											location.getLength()));
				}
			}
		}
	}

	private EObject getCorrespondingElement(GraphNode node, FModel activeModel) {
		if (activeModel != null) {
			if (node.getData() instanceof String) {
				String nodeName = (String) node.getData();
				for (FInterface _interface : activeModel.getInterfaces()) {
					for (FState state : _interface.getContract()
							.getStateGraph().getStates()) {
						if (state.getName().equals(nodeName)) {
							return state;
						}
					}
				}
			}
		}
		return null;
	}

	private EObject getCorrespondingElement(GraphConnection connection,
			FModel activeModel) {
		if (activeModel != null) {
			String sourceNodeName = connection.getSource().getData().toString();
			String targetNodeName = connection.getDestination().getData().toString();
			for (FInterface _interface : activeModel.getInterfaces()) {
				for (FState state : _interface.getContract().getStateGraph()
						.getStates()) {
					if (state.getName().equals(sourceNodeName)) {
						for (FTransition transition : state.getTransitions()) {
							if (transition.getTo().getName()
									.equals(targetNodeName)) {
								return transition;
							}
						}
					}
				}
			}
		}
		return null;
	}

	@Override
	public void widgetDefaultSelected(SelectionEvent e) {

	}

}
