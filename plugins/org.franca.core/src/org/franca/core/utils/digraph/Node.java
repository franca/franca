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

