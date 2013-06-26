/*******************************************************************************
 * Copyright 2009-2010, CHISEL Group, University of Victoria, Victoria, BC, Canada.
 * All rights reserved. This program and the accompanying materials are made
 * available under the terms of the Eclipse Public License v1.0 which
 * accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors: The Chisel Group, University of Victoria
 * 				 Tamas Szabo (itemis AG) - Franca related customization
 ******************************************************************************/
package org.franca.core.ui.addons.contractviewer.graph;

import org.eclipse.draw2d.ColorConstants;
import org.eclipse.draw2d.FigureUtilities;
import org.eclipse.draw2d.Graphics;
import org.eclipse.draw2d.MarginBorder;
import org.eclipse.draw2d.ScaledGraphics;
import org.eclipse.draw2d.StackLayout;
import org.eclipse.draw2d.geometry.Dimension;
import org.eclipse.draw2d.geometry.Rectangle;
import org.eclipse.gef4.zest.core.widgets.IStyleableFigure;
import org.eclipse.gef4.zest.core.widgets.internal.CachedLabel;
import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.graphics.Font;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.widgets.Display;

/**
 * Overrides the Draw2D Label Figure class to ensure that the text is never
 * truncated. Also draws a rounded rectangle border.
 * 
 * @author Chris Callendar
 */
@SuppressWarnings("restriction")
public class CustomGraphLabel extends CachedLabel implements IStyleableFigure {

	private Color borderColor;
	private int borderWidth;
	private int arcWidth;
	private boolean painting = false;

	public CustomGraphLabel(boolean cacheLabel) {
		this("", cacheLabel);
	}

	public CustomGraphLabel(String text, boolean cacheLabel) {
		this(text, null, cacheLabel);
	}

	public CustomGraphLabel(Image i, boolean cacheLabel) {
		this("", i, cacheLabel);
	}

	public CustomGraphLabel(String text, Image i, boolean cacheLabel) {
		super(cacheLabel);
		initLabel();
		setText(text);
		setIcon(i);
		adjustBoundsToFit();
	}

	protected void initLabel() {
		super.setFont(Display.getDefault().getSystemFont());
		this.borderColor = ColorConstants.black;
		this.borderWidth = 0;
		this.arcWidth = 8;
		this.setLayoutManager(new StackLayout());
		this.setBorder(new MarginBorder(1));
	}

	@Override
	public void setFont(Font f) {
		super.setFont(f);
		adjustBoundsToFit();
	}

	protected void adjustBoundsToFit() {
		String text = getText();
		int safeBorderWidth = borderWidth > 0 ? borderWidth : 1;
		if ((text != null)) {
			Font font = getFont();
			if (font != null) {
				Dimension minSize = FigureUtilities.getTextExtents(text, font);
				if (getIcon() != null) {
					org.eclipse.swt.graphics.Rectangle imageRect = getIcon()
							.getBounds();
					int expandHeight = Math.max(imageRect.height
							- minSize.height, 0);
					minSize.expand(imageRect.width + 4, expandHeight);
				}
				minSize.expand(10 + (2 * safeBorderWidth),
						4 + (2 * safeBorderWidth));
				setBounds(new Rectangle(getLocation(), minSize));
			}
		}
	}

	@Override
	public void paint(Graphics graphics) {
		graphics.setForegroundColor(borderColor);
		graphics.setBackgroundColor(borderColor);

		int safeBorderWidth = borderWidth > 0 ? borderWidth : 1;
		graphics.pushState();
		double scale = 1;

		if (graphics instanceof ScaledGraphics) {
			scale = ((ScaledGraphics) graphics).getAbsoluteScale();
		}
		// Top part inside the border (as fillGradient does not allow to fill a
		// rectangle with round corners).
		Rectangle rect = getBounds().getCopy();
		rect.height /= 2;
		graphics.setForegroundColor(borderColor);
		graphics.setBackgroundColor(borderColor);

		// Bottom part inside the border.
		rect.y = rect.y + rect.height;
		rect.height += 1;
		graphics.setForegroundColor(borderColor);
		graphics.setBackgroundColor(borderColor);

		// Now fill the middle part of top and bottom part with a gradient.
		rect = bounds.getCopy();
		rect.height -= 2;
		rect.y += (safeBorderWidth) / 2;
		rect.y += (arcWidth / 2);
		rect.height -= arcWidth / 2;
		rect.height -= safeBorderWidth;
		graphics.setBackgroundColor(borderColor);
		graphics.setForegroundColor(borderColor);
		
		// Paint the border
		if (borderWidth > 0) {
			rect = getBounds().getCopy();
			rect.x += safeBorderWidth / 2;
			rect.y += safeBorderWidth / 2;
			rect.width -= safeBorderWidth;
			rect.height -= safeBorderWidth;
			
			if (this.getText() == null || this.getText().length() == 0) {
				graphics.setForegroundColor(ColorConstants.black);
				graphics.setBackgroundColor(ColorConstants.black);
				graphics.fillOval(rect);
			}
			else {
				graphics.setForegroundColor(borderColor);
				graphics.setBackgroundColor(borderColor);
				graphics.setLineWidth((int) (safeBorderWidth * scale));
				graphics.drawOval(rect);
			}
		}

		super.paint(graphics);
		graphics.popState();
	}

	@Override
	protected Color getBackgroundTextColor() {
		return borderColor;
	}

	@Override
	public void invalidate() {
		if (!painting) {
			super.invalidate();
		}
	}

	@Override
	public void setText(String s) {
		super.setText(s);
		adjustBoundsToFit();
	}

	@Override
	public void setIcon(Image image) {
		super.setIcon(image);
		adjustBoundsToFit();
	}
	
	@Override
	public void setBackgroundColor(Color bg) {
		super.setBackgroundColor(bg);
	}

	@Override
	public void setBorderColor(Color c) {
		this.borderColor = c;
	}

	@Override
	public void setBorderWidth(int width) {
		this.borderWidth = width;
	}
	
	@Override
	public String toString() {
		return this.getText();
	}
}

