/*******************************************************************************
* Copyright (c) 2012 Harman International (http://www.harman.com).
* All rights reserved. This program and the accompanying materials
* are made available under the terms of the Eclipse Public License v1.0
* which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/epl-v10.html
*******************************************************************************/
package org.franca.deploymodel.dsl.valueconverter;

import org.eclipse.xtext.common.services.DefaultTerminalConverters;
import org.eclipse.xtext.conversion.IValueConverter;
import org.eclipse.xtext.conversion.ValueConverter;
import org.eclipse.xtext.conversion.impl.AbstractDeclarativeValueConverterService;
import org.eclipse.xtext.conversion.impl.AbstractIDValueConverter;
import org.eclipse.xtext.conversion.impl.IDValueConverter;
import org.eclipse.xtext.conversion.impl.INTValueConverter;
import org.eclipse.xtext.conversion.impl.STRINGValueConverter;
import org.eclipse.xtext.nodemodel.INode;

import com.google.inject.Inject;

public class FDeployValueConverters extends AbstractDeclarativeValueConverterService {

   @Inject
    private AbstractIDValueConverter idValueConverter;
	
	/**
	 * Create a converter for the ID rule.
	 * 
	 * @return a value converter for ID
	 */
	@ValueConverter(rule = "ID")
	public IValueConverter<String> ID() {
		return idValueConverter;
	}

	private FQNValueConverter fqnValueConverter = new FQNValueConverter();

	/**
	 * Create a converter for the FQN rule.
	 * 
	 * @return a value converter for FQN
	 */
	@ValueConverter(rule = "FQN")
	public IValueConverter<String> FQN() {
		return fqnValueConverter;
	}

	/**
	 * Create a converter for the FQN_WITH_SELECTOR rule.
	 * 
	 * @return a value converter for FQN
	 */
	@ValueConverter(rule = "FQN_WITH_SELECTOR")
	public IValueConverter<String> FQN_WITH_SELECTOR() {
		return fqnValueConverter;
	}


	@Inject
	private INTValueConverter intValueConverter;
	
	@ValueConverter(rule = "INT")
	public IValueConverter<Integer> INT() {
		return intValueConverter;
	}


	@Inject
	private STRINGValueConverter stringValueConverter;
	
	@ValueConverter(rule = "STRING")
	public IValueConverter<String> STRING() {
		return stringValueConverter;
	}

	
	/**
     * Value converter for FQN and FQN_WITH_SELECTOR.
     */
    private class FQNValueConverter extends IDValueConverter {
    	final static String SELECTOR = ":";
    	
        @Override
        public String toString(final String s) {
        	// first split string according to selector
            StringBuilder result = new StringBuilder();
            String[] selarray = s.split(":");
            for(int i=0; i<selarray.length; i++) {
                if (i > 0) {
                    result.append(':');
                }

                // split according to FQN separator
                String[] idarray = selarray[i].split("\\.");
                for (int j=0; j < idarray.length; j++) {
	                if (j > 0) {
	                    result.append('.');
	                }
	                result.append(idValueConverter.toString(idarray[j]));
                }
            }
            return result.toString();
        }
        
        @Override
        public String toValue(final String string, final INode node) {
            if (string == null) {
                return null;
            }
            return string.replace("^", "");
        }
    }

}
