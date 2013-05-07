/*******************************************************************************
 * Copyright 2005-2010, CHISEL Group, University of Victoria, Victoria, BC,
 * Canada. All rights reserved. This program and the accompanying materials are
 * made available under the terms of the Eclipse Public License v1.0 which
 * accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors: The Chisel Group, University of Victoria Mateusz Matela
 * 				 Tamas Szabo (itemis AG) - Franca related customization
 ******************************************************************************/
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
