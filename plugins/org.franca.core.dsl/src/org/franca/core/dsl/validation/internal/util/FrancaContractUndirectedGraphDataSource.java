/*******************************************************************************
 * Copyright (c) 2012 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.core.dsl.validation.internal.util;

import java.util.Collections;
import java.util.List;

import org.franca.core.franca.FContract;
import org.franca.core.franca.FState;
import org.franca.core.franca.FTransition;

import com.google.common.collect.HashMultimap;
import com.google.common.collect.Lists;
import com.google.common.collect.Multimap;

public class FrancaContractUndirectedGraphDataSource extends FrancaContractDirectedGraphDataSource {

	private static final long serialVersionUID = 6570270879082271139L;
	private Multimap<FState, FState> backwardIndex;
	
	public FrancaContractUndirectedGraphDataSource(FContract contract) {
		super(contract);
		this.backwardIndex = HashMultimap.create();
		
		for (FState state : contract.getStateGraph().getStates()) {
			for (FTransition transition : state.getTransitions()) {
				backwardIndex.put(transition.getTo(), state);
			}
		}
	}

	@Override
	public List<FState> getTargetNodes(FState source) {
		//projects the directed graph into an undirected graph
		List<FState> nodes = Lists.newArrayList(super.getTargetNodes(source));
		if (backwardIndex.get(source) != null) {
			nodes.addAll(backwardIndex.get(source));
		}
		return Collections.unmodifiableList(nodes);
	}

}
