/*******************************************************************************
 * Copyright (c) 2013 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.tools.contracts.tracegen.strategies.collect

import java.util.ArrayList
import java.util.Collection
import org.franca.core.franca.FTransition
import org.franca.tools.contracts.tracegen.traces.Trace

class SimpleCollectTransitionsStrategy implements CollectTransitionsStrategy {
	
	override public Collection<FTransition> execute(Trace currentTrace) {
		new ArrayList<FTransition>(currentTrace.currentState.transitions)
	}
}