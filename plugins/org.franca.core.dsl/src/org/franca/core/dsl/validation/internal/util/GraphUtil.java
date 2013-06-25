/*******************************************************************************
 * Copyright (c) 2012 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.core.dsl.validation.internal.util;

import java.util.List;
import java.util.Set;

import com.google.common.collect.Lists;
import com.google.common.collect.Sets;

public class GraphUtil {

	/**
	 * Determines whether the given {@link IGraphDataSource} corresponds to a connected graph.
	 * In case of directed graphs the method only checks for weak connectivity not for the strongly connected property.
	 * 
	 * @param graphDataSource the graph data source instance
	 * @return true if the graph is connected, false otherwise
	 */
	public static <V> boolean isConnected(IGraphDataSource<V> graphDataSource) {
		if (graphDataSource.getAllNodes().size() > 0) {
			Set<V> visited = Sets.newHashSet();
			List<V> queue = Lists.newArrayList();
			queue.add(graphDataSource.getAllNodes().iterator().next());
			while (!queue.isEmpty()) {
				V node = queue.remove(0);
				visited.add(node);
				for (V target : graphDataSource.getTargetNodes(node)) {
					if (!visited.contains(target)) {
						queue.add(target);
					}
				}
			}
			return (visited.size() == graphDataSource.getAllNodes().size());
		}
		return true;
	}
	
	public static <V> Set<V> getSinks(IGraphDataSource<V> graphDataSource) {
		Set<V> sinks = Sets.newHashSet();
		
		for (V s : graphDataSource.getAllNodes()) {
			if (graphDataSource.getTargetNodes(s).size() == 0) {
				sinks.add(s);
			}
		}
		
		return sinks;
	}
	
}
