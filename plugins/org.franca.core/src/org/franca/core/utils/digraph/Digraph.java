/*******************************************************************************
 * Copyright (c) 2012 Harman International (http://www.harman.com).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.core.utils.digraph;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.Stack;

/**
 * Class to represent a digraph and do some operations on it.
 * 
 * @author FPicioroaga
 * 
 */
public class Digraph<T> {

	/**
	 * Exception to signal that the digraph has cycles.
	 * 
	 * @author FPicioroaga
	 * 
	 */
	static public class HasCyclesException extends Exception {
		private static final long serialVersionUID = -8799856311007297150L;

	}

	/**
	 * Exception to signal that an operation is tried on an edge not existing in the digraph.
	 */
	static public class NotExistingEdge extends Exception {
		private static final long serialVersionUID = -2629709105411250583L;	
	}

	/**
	 * Holds all the digraph nodes.
	 */
	Set<Node<T>> nodes = new HashSet<Node<T>>();
	Map<T, Node<T>> nodesMap = new HashMap<T, Node<T>>();
	int countEdges = 0;

	/**
	 * Getter method.
	 * 
	 * @return
	 */
	public int getCountEdges() {
		return countEdges;
	}

	/**
	 * Getter method.
	 * 
	 * @return
	 */
	public int getCountNodes() {
		return nodes.size();
	}

	/**
	 * Add a node in the digraph.
	 * 
	 * @param node
	 * @return
	 */
	void addNode(T node) {
		Node<T> digraphNode = new Node<T>(node);

		nodes.add(digraphNode);
		nodesMap.put(node, digraphNode);
	}

	/**
	 * Add an edge in the digraph. In case the nodes do not exist yet then add
	 * them too.
	 * 
	 * @param fromNode
	 * @param toNode
	 */
	public void addEdge(T fromNode, T toNode) {
		if (!nodesMap.containsKey(fromNode)) {
			addNode(fromNode);
		}
		if (!nodesMap.containsKey(toNode)) {
			addNode(toNode);
		}
		if (nodesMap.get(fromNode).outEdges.add(nodesMap.get(toNode))
				&& nodesMap.get(toNode).inEdges.add(nodesMap.get(fromNode)))
			countEdges++;
	}

	/**
	 * Remove an edge from the digraph.
	 * 
	 * @param fromNode
	 * @param toNode
	 * @throws NotExistingEdge 
	 */
	public void removeEdge(T fromNode, T toNode) throws NotExistingEdge {

		if (!nodesMap.containsKey(fromNode)) {
			throw new NotExistingEdge();
		}
		if (!nodesMap.containsKey(toNode)) {
			throw new NotExistingEdge();
		}
		if (nodesMap.get(fromNode).outEdges.remove(nodesMap.get(toNode))
				&& nodesMap.get(toNode).inEdges.remove(nodesMap.get(fromNode)))
			countEdges--;
		else
			throw new NotExistingEdge();
	}

	/**
	 * Returns the list of nodes sorted in topological order. Caution: this will
	 * destroy the original digraph, therefore be sure to have a copy of it. In
	 * case cycles are detected the digraph will contain them.
	 */
	public List<T> topoSort() throws HasCyclesException
	/**
	 * Algorithm(source Wikipedia):
	 * 
	 * L : Empty list that will contain the sorted elements
     * S : Set of all nodes with no incoming edges
     * while S is non-empty do
     *     remove a node n from S
     *     insert n into L
     *     for each node m with an edge e from n to m do
     *         remove edge e from the graph
     *         if m has no other incoming edges then
     *             insert m into S
     * if graph has edges then
     *     return error (graph has at least one cycle)
     * else 
     *     return L (a topologically sorted order)
	 */
	{
		Set<T> L = new LinkedHashSet<T>();
		Stack<Node<T>> S = new Stack<Node<T>>();

		for (Iterator<Node<T>> it = nodes.iterator(); it.hasNext();) {
			Node<T> node = it.next();
			if (node.inEdges.size() == 0) {
				S.push(node);
			}
		}
		while (!S.empty()) {
			Node<T> n = S.pop();
			L.add((T) n.value);
			List<Node<T>> outEdges = new ArrayList<Node<T>>();
			
			outEdges.addAll(n.outEdges);
			for (Iterator<Node<T>> it = outEdges.iterator(); it.hasNext();) {
				try {
					Node<T> m = it.next();
					removeEdge(n.value, m.value);
					if (m.inEdges.size() == 0)
						S.push(m);
				}
				catch (NotExistingEdge edgeEx)
				{
					edgeEx.printStackTrace();
				}
			}
		}
		if (countEdges > 0) {
			// In case of cycles keep only the nodes of the cycles in the
			// digraph and discard the rest,
			// e.g. for a>b, b>c, c>a, c>d the c>d edge will be removed.
			boolean removedEdges = true;
			while (removedEdges) {
				removedEdges = false;
				for (Iterator<Node<T>> it = nodes.iterator(); it.hasNext();) {
					Node<T> node = it.next();
					// search the nodes with only incoming edges and remove all its edges from the digraph
					if (node.outEdges.size() == 0) {
						for (Iterator<Node<T>> inIt = node.inEdges.iterator(); inIt.hasNext();) {
							try {
								removeEdge(inIt.next().value, node.value);
							} catch (NotExistingEdge e) {
								e.printStackTrace();
							}
							removedEdges = true;
						}
					}
				}
			}
			throw new HasCyclesException();
		}
		List<T> sortedList = new ArrayList<T>();
		for (Iterator<T> it = L.iterator(); it.hasNext();)
			sortedList.add(it.next());
		return sortedList;
	}

	/**
	 * 
	 * @return an iterator over all digraph nodes
	 */
	public Iterator<T> nodesIterator() {
		return new NodesIterator<T>(this);
	}

	/**
	 * 
	 * @return an iterator over all digraph edges
	 */
	public Iterator<Edge<T>> edgesIterator() {
		return new EdgesIterator<T>(this);
	}
	
	public String toString()
	{
		String tmp = "Digraph:";
		for (Iterator<T> it = nodesIterator(); it.hasNext();)
		{
			tmp += it.next() + ",";
		}
		tmp += "\n";
		tmp = "Edges: ";
		tmp = edgesToString();
		tmp += "\n";
		
		return tmp;
	}

	/** Returns a String describing the Edges only. May be helpful while analyzing cycles.*/
	public String edgesToString() {
		String result = "";
		for (Iterator<Edge<T>> it = edgesIterator(); it.hasNext();)
		{
			Edge<T> edge = it.next();
			result+= "(" + edge.from.value + "->" + edge.to.value + ")";  
		}
		return result;
	}
}
