/*******************************************************************************
* Copyright (c) 2012 Harman International (http://www.harman.com).
* All rights reserved. This program and the accompanying materials
* are made available under the terms of the Eclipse Public License v1.0
* which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/epl-v10.html
*******************************************************************************/
package org.franca.core.dsl.valueconverter;

import org.eclipse.xtext.common.services.Ecore2XtextTerminalConverters;
import org.eclipse.xtext.conversion.IValueConverter;
import org.eclipse.xtext.conversion.ValueConverter;
import org.eclipse.xtext.conversion.impl.AbstractNullSafeConverter;
import org.eclipse.xtext.nodemodel.INode;

public class FrancaValueConverters extends Ecore2XtextTerminalConverters {
	@ValueConverter(rule = "E_FLOAT_OBJECT")
	public AbstractNullSafeConverter<Float> E_FLOAT_OBJECT() {
		return new AbstractNullSafeConverter<Float>() {
			@Override
			protected Float internalToValue(String string, INode node) {
				Float value = Float.parseFloat(string);
				
				
				
				return value;
			}

			@Override
			protected String internalToString(Float value) {
				return value.toString();
			}
		};
	}
	@ValueConverter(rule = "E_DOUBLE_OBJECT")
	public AbstractNullSafeConverter<Double> E_DOUBLE_OBJECT() {
		return new AbstractNullSafeConverter<Double>() {
			@Override
			protected Double internalToValue(String string, INode node) {
				Double value = Double.parseDouble(string);
				
				
				
				return value;
			}

			@Override
			protected String internalToString(Double value) {
				return value.toString();
			}
		};
	}
	@ValueConverter(rule = "ANNOTATION_STRING")
	public IValueConverter<String> ANNOTATION_STRING() {
		return new AbstractNullSafeConverter<String>() {
			@Override
			protected String internalToValue(String string, INode node) {
				String value = string;
				
				// cut trailing whitespace or newlines
				int j = string.length()-1;
				while (j>=0 && Character.isWhitespace(string.charAt(j))) {
					j--;
				}
				
				if (j>=0) {
					value = string.substring(0, j+1);
				}
				return value;
			}

			@Override
			protected String internalToString(String value) {
				return value;
			}
		};
	}
	
	
}
