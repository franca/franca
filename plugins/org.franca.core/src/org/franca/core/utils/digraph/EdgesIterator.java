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
		currentNode = nodesIt.next();
		edgesIt = currentNode.outEdges.iterator();
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