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
		final CustomGraphLabel label = new CustomGraphLabel(node.getText(),
				node.getImage(), cacheLabel);
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
