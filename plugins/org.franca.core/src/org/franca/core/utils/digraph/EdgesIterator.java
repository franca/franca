/*******************************************************************************
 * Copyright (c) 2012 Harman International (http://www.harman.com).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.core.utils.digraph;

import java.util.Iterator;

/**
 * Iterate over the digraph edges.
 * 
 * @author FPicioroaga
 * 
 */
public class EdgesIterator<T> implements Iterator<Edge<T>> {
	Digraph<T> digraph;
	Iterator<Node<T>> nodesIt;
	Iterator<Node<T>> edgesIt;
	Node<T> currentNode;
	int currentEdge = 0;

	public EdgesIterator(Digraph<T> theDigraph) {
		digraph = theDigraph;
		nodesIt = digraph.nodes.iterator();
		if(nodesIt.hasNext()){
			currentNode = nodesIt.next();
			edgesIt = currentNode.outEdges.iterator();
		}
	}

	public boolean hasNext() {
		return currentEdge < digraph.countEdges;
	}

	public Edge<T> next() {
		if (!hasNext())
			return null;
		// reach the next edge
		while (!edgesIt.hasNext()) {
		   currentNode = nodesIt.next();
		   edgesIt = currentNode.outEdges.iterator();
		}
		currentEdge++;
		return new Edge<T>(currentNode, edgesIt.next());
	}

	public void remove() {
		// not implemented YET
	}
}