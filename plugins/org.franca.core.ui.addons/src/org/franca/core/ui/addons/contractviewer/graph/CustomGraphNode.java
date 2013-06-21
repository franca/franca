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

import org.eclipse.draw2d.IFigure;
import org.eclipse.gef4.zest.core.widgets.GraphNode;
import org.eclipse.gef4.zest.core.widgets.IContainer;
import org.eclipse.gef4.zest.core.widgets.ZestStyles;

public class CustomGraphNode extends GraphNode {
	
	public CustomGraphNode(IContainer graphModel, int style, String text) {
		super(graphModel, style, text);
	}

	@Override
	protected IFigure createFigureForModel() {
		GraphNode node = this;
		boolean cacheLabel = (this).cacheLabel();
		final CustomGraphLabel label = new CustomGraphLabel(node.getText(),	node.getImage(), cacheLabel);
		label.setFont(this.getFont());
		if (checkStyle(ZestStyles.NODES_HIDE_TEXT)) {
			label.setText("");
		}
		updateFigureForModel(label);
		label.addFigureListener(new CustomFigureListener(this, label));
		return label;
	}
	
	public IContainer getParentCustom() {
		return this.parent;
	}
	
	public IFigure getNodeFigureCustom() {
		return this.nodeFigure;
	}
}
