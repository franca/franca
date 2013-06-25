/*******************************************************************************
 * Copyright (c) 2012 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.core.dsl.validation.internal.util;

import java.io.Serializable;
import java.util.List;
import java.util.Set;

/**
 * Common interface for directed graph data source functionalities.
 * 
 * @author Tamas Szabo (itemis AG)
 * 
 * @param <V> the type of the nodes in the graph
 */
public interface IGraphDataSource<V> extends Serializable {

    /**
     * Get all nodes of the graph.
     * 
     * @return the set of all nodes
     */
    public Set<V> getAllNodes();

    /**
     * Get those nodes that are the target of an edge starting with source. 
     * A {@link List} instance is returned as there may be multiple edges between the same nodes.
     * 
     * @param source the source node
     * @return the list of target nodes or null if no targets can be found
     */
    public List<V> getTargetNodes(V source);
}
