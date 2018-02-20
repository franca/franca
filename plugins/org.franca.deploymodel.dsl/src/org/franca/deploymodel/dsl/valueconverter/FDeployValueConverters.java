/*******************************************************************************
* Copyright (c) 2015 itemis AG (http://www.itemis.de).
* All rights reserved. This program and the accompanying materials
* are made available under the terms of the Eclipse Public License v1.0
* which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/epl-v10.html
*******************************************************************************/
package org.franca.deploymodel.dsl.valueconverter;

import org.eclipse.xtext.conversion.IValueConverter;
import org.eclipse.xtext.conversion.ValueConverter;
import org.eclipse.xtext.conversion.ValueConverterException;
import org.eclipse.xtext.conversion.impl.AbstractDeclarativeValueConverterService;
import org.eclipse.xtext.conversion.impl.AbstractIDValueConverter;
import org.eclipse.xtext.conversion.impl.AbstractNullSafeConverter;
import org.eclipse.xtext.conversion.impl.AbstractValueConverter;
import org.eclipse.xtext.conversion.impl.INTValueConverter;
import org.eclipse.xtext.conversion.impl.STRINGValueConverter;
import org.eclipse.xtext.nodemodel.INode;
import org.franca.deploymodel.core.FDPropertyHost;
import org.franca.deploymodel.dsl.fDeploy.FDBuiltInPropertyHost;

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
	 * @return a value converter for FQN_WITH_SELECTOR
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


	@ValueConverter(rule = "SignedInt")
	public IValueConverter<Integer> SignedInt() {
		return new AbstractNullSafeConverter<Integer>() {
			@Override
			protected String internalToString(Integer value) {
				return Integer.toString(value);
			}

			@Override
			protected Integer internalToValue(String string, INode node)
					throws ValueConverterException {
				Integer result;
				try {
					// support hexadecimal and binary literals
					if (string.startsWith("0x") || string.startsWith("0X")) {
						// note: negative hex values are not supported
						String data = string.substring(2);
						result = Integer.parseInt(data, 16);
					} else if (string.startsWith("0b") || string.startsWith("0B")) {
						// note: negative binary values are not supported
						String data = string.substring(2);
						result = Integer.parseInt(data, 2);
					} else {
						// this will handle positive and negative integer values
						result = Integer.parseInt(string, 10);
					}
					return result;
				} catch (Exception e) {
					throw new ValueConverterException("Not a proper integer value.", node, e);
				}
			}
		};
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
    private class FQNValueConverter extends AbstractValueConverter<String> {
    	final static String SELECTOR = ":";
    	
        @Override
        public String toString(final String s) {
        	// first split string according to selector
            StringBuilder result = new StringBuilder();
            String[] selarray = s.split(SELECTOR);
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

	@ValueConverter(rule = "PROPERTY_HOST")
	public AbstractNullSafeConverter<FDPropertyHost> PROPERTY_HOST() {
		return new AbstractNullSafeConverter<FDPropertyHost>() {
			@Override
			protected FDPropertyHost internalToValue(String string, INode node) {
				FDBuiltInPropertyHost host = FDBuiltInPropertyHost.get(string);
				if (host!=null)
					return new FDPropertyHost(host);
				else
					return new FDPropertyHost(string);
			}

			@Override
			protected String internalToString(FDPropertyHost value) {
				return value.getName();
			}
		};
	}

}
