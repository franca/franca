package org.franca.core.ui.addons.contractviewer.graph;

import org.eclipse.draw2d.Animation;
import org.eclipse.draw2d.FigureListener;
import org.eclipse.draw2d.IFigure;
import org.eclipse.draw2d.geometry.Dimension;
import org.eclipse.draw2d.geometry.PrecisionPoint;
import org.eclipse.draw2d.geometry.Rectangle;
import org.eclipse.gef4.zest.layouts.interfaces.NodeLayout;

public class CustomFigureListener implements FigureListener {

	private CustomGraphNode node;
	private Dimension previousSize;
	
	public CustomFigureListener(CustomGraphNode node, CustomGraphLabel label) {
		this.node = node;
		this.previousSize = label.getBounds().getSize();
	}
	
	@Override
	public void figureMoved(IFigure source) {
		if (Animation.isAnimating() || ((NodeLayout) node.getLayout()).isMinimized()) {
			return;
		}
		Rectangle newBounds = node.getNodeFigureCustom().getBounds();
		if (!newBounds.getSize().equals(previousSize)) {
			previousSize = newBounds.getSize();
			if (node.getSize().width >= 0 && node.getSize().height >= 0) {
				node.setSize(newBounds.getSize().preciseWidth(), newBounds.getSize().preciseHeight());
			}
			PrecisionPoint currentLocation = new PrecisionPoint(node.getNodeFigureCustom().getBounds().getTopLeft());
			node.setLocation(currentLocation.preciseX(), currentLocation.preciseY());
			//node.getParentCustom().getLayoutContext().fireNodeResizedEvent(node.getLayout());
		} else if (node.getLocation().x != newBounds.x
				|| node.getLocation().y != newBounds.y) {
			PrecisionPoint currentLocation = new PrecisionPoint(node.getNodeFigureCustom().getBounds().getTopLeft());
			node.setLocation(currentLocation.preciseX(), currentLocation.preciseY());
			//((LayoutContext) node.getParentCustom().getLayoutContext()).fireNodeMovedEvent(node.getLayout());
		}
	}

}
