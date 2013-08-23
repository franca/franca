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
	
	@ValueConverter(rule = "COMMENT_STRING")
	public IValueConverter<String> COMMENT_STRING() {
		return new AbstractNullSafeConverter<String>() {
			@Override
			protected String internalToValue(String string, INode node) {
				int i = 0;
				String value = string;
				
				// cut leading ':' and following whitespace
				if (string.charAt(0)==':') {
					i++;
					while (i<string.length() && string.charAt(i)==' ') {
						i++;
					}
				}
				
				// cut trailing whitespace or newlines
				int j = string.length()-1;
				while (j>=0 && Character.isWhitespace(string.charAt(j))) {
					j--;
				}
				
				if (j>=0) {
					value = string.substring(i, j+1);
				}
				return value;
			}

			@Override
			protected String internalToString(String value) {
				return ": " + value;
			}
		};
	}
}
