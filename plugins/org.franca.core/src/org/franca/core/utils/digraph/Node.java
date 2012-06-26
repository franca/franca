/*******************************************************************************
 * Copyright (c) 2012 Harman International (http://www.harman.com).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.core.utils.digraph;

import java.util.LinkedHashSet;
import java.util.Set;


/**
 * Class that represents a node in the digraph. Both inEdges and outEdges are maintained for a faster navigation
 * through the digraph.
 * 
 * @author FPicioroaga
 * 
 * @param <NodeType>
 */
	public class Node<T> {
		public T value;

		Set<Node<T>> inEdges = new LinkedHashSet<Node<T>>();
		Set<Node<T>> outEdges = new LinkedHashSet<Node<T>>();

		public Node(T theNodeType) {
			value = theNodeType;
		}
	}

