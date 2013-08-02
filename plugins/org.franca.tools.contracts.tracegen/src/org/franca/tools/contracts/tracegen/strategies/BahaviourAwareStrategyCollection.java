/*******************************************************************************
 * Copyright (c) 2013 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.tools.contracts.tracegen.strategies;

import org.franca.tools.contracts.tracegen.strategies.collect.BehaviourAwareCollectTransitionsStrategy;
import org.franca.tools.contracts.tracegen.strategies.collect.CollectTransitionsStrategy;
import org.franca.tools.contracts.tracegen.strategies.events.TriggerSimualtionStrategy;
import org.franca.tools.contracts.tracegen.strategies.selectors.LimitedUseTransitionSelector;
import org.franca.tools.contracts.tracegen.strategies.selectors.TransitionSelector;

public class BahaviourAwareStrategyCollection implements StrategyCollection {

	private TriggerSimualtionStrategy triggersim;
	
	public BahaviourAwareStrategyCollection() {
		this.triggersim = new TriggerSimualtionStrategy();
	}
	
	@Override
	public CollectTransitionsStrategy getCollectTransitionsStrategy() {
		return new BehaviourAwareCollectTransitionsStrategy(triggersim);
	}

	@Override
	public TransitionSelector getPathSelector() {
		return new LimitedUseTransitionSelector(10);
	}
	@Override
	public TriggerSimualtionStrategy getTriggerSimulator() {
		return triggersim;
	}
}
