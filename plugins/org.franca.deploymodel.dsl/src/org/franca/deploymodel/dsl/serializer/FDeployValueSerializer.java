/*******************************************************************************
* Copyright (c) 2018 itemis AG (http://www.itemis.de).
* All rights reserved. This program and the accompanying materials
* are made available under the terms of the Eclipse Public License v1.0
* which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/epl-v10.html
*******************************************************************************/
package org.franca.deploymodel.dsl.serializer;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.xtext.RuleCall;
import org.eclipse.xtext.nodemodel.INode;
import org.eclipse.xtext.serializer.diagnostic.ISerializationDiagnostic.Acceptor;
import org.eclipse.xtext.serializer.tokens.ValueSerializer;
import org.franca.deploymodel.dsl.fDeploy.impl.FDIntegerImpl;

/**
 * Custom value serializer for the FDeploy language.</p>
 * 
 * This is needed for using non-default representations/formats while using semantic quickfixes.
 * E.g., an integer value can be represented either decimal, hex, or binary.</p>
 * 
 * @author Klaus Birken, itemis AG
 */
public class FDeployValueSerializer extends ValueSerializer {

	@Override
	public String serializeAssignedValue(EObject context, RuleCall ruleCall, Object value, INode node, Acceptor errors) {
		// customization for FDIntegerImpl, i.e., for integer property values which should be represented in different formats 
		if (context instanceof FDIntegerImpl) {
			FDIntegerImpl intValue = (FDIntegerImpl)context;
			
			// check if a special format was given
			if (intValue.getFormattedValue() != null) {
				// integer property with specified format (e.g., hexadecimal): simply use this formatted value
				// NB: we do not use the parameter "value" here, it is ignored
				return intValue.getFormattedValue();
			}
		}
		
		// default: use default implementation
		return super.serializeAssignedValue(context, ruleCall, value, node, errors);
	}

}
