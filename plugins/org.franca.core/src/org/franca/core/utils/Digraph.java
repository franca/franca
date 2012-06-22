/*******************************************************************************
* Copyright (c) 2012 Harman International (http://www.harman.com).
* All rights reserved. This program and the accompanying materials
* are made available under the terms of the Eclipse Public License v1.0
* which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/epl-v10.html
*******************************************************************************/
package org.franca.core.utils;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.Stack;

/**
 * Class to represent a digraph and to some operations on it.
 * 
 * @author FPicioroaga
 *
 */
public class Digraph<NodeType> {

   /**
    * Class that represents a node in the digraph. Both inEdges and outEdges are maintained for a faster navigation
    * through the digraph.
    * 
    * @author FPicioroaga
    * 
    * @param <NodeType>
    */
   static public class Node<NodeType>
   {
      public NodeType nodeType;
      
      private Set<Node<?>> inEdges = new LinkedHashSet<Node<?>>();
      private Set<Node<?>> outEdges = new LinkedHashSet<Node<?>>();
      
      public Node(NodeType theNodeType)
      {
         nodeType = theNodeType;
      }
   }

   /**
    * Representation of a directed edge in the graph.
    *  
    * @author FPicioroaga
    *
    */
   static public class Edge<NodeType>
   {
      public Node<?> from;
      public Node<?> to;
      
      public Edge(Node<?> fromNode, Node<?> toNode) {
         from = fromNode;
         to = toNode;
      }
   }

   
   /**
    * Exception to signal that the digraph has cycles.
    * 
    * @author FPicioroaga
    *
    */
   static public class HasCyclesException extends Exception
   {
      private static final long serialVersionUID = -8799856311007297150L;
      
   }
   
   /**
    * Iterate over the digraph nodes.
    * 
    * @author FPicioroaga
    *
    */
   @SuppressWarnings("hiding")
   public class NodesIterator<NodeType> implements Iterator<NodeType>
   {
      Iterator<?> it;
      
      NodesIterator(Digraph<?> theDigraph)
      {
         it = theDigraph.nodes.iterator();
      }

      public boolean hasNext() {
         return it.hasNext();
      }

      @SuppressWarnings("unchecked")
      public NodeType next() {
         return ((Node<NodeType>) it.next()).nodeType;
      }

      public void remove() {
         //operation not allowed YET
      }
   }
   
   
   /**
    * Iterate over the digraph edges.
    * 
    * @author FPicioroaga
    *
    */
   @SuppressWarnings("hiding")
   public class EdgesIterator<NodeType> implements Iterator<Edge<NodeType>>
   {
      Digraph<NodeType> digraph;
      Iterator<Node<NodeType>> nodesIt;
      Iterator<Node<?>> edgesIt;
      Node<?> currentNode;
      int currentEdge = 0;
      
      public EdgesIterator(Digraph<NodeType> theDigraph)
      {
         digraph = theDigraph;
         nodesIt = digraph.nodesIterator();
         currentNode = nodesIt.next();
         edgesIt = currentNode.outEdges.iterator();
      }

      public boolean hasNext() {
         return currentEdge < digraph.countEdges;
      }

      public Edge<NodeType> next() {
         if (!hasNext())
            return null;
         //reach the next edge
         while (!edgesIt.hasNext())
         {
            currentNode = nodesIt.next();
            edgesIt = currentNode.outEdges.iterator();
         }
         currentEdge++;
         return new Edge<NodeType>(currentNode, edgesIt.next());
      }

      public void remove() {
         //operation not allowed YET
      }
   }
   
   private List<Node<?>> nodes = new ArrayList<Node<?>>();
   private Map<Node<?>, Integer> nodesMap = new HashMap<Node<?>, Integer>();
   private int countEdges = 0;
   
   /**
    * Getter method.
    * 
    * @return
    */
   public int getCountEdges() {
      return countEdges;
   }

   /**
    * Add a node in the digraph.
    * 
    * @param node
    * @return
    */
   void addNode(Node<?> node)
   {
      int currentNodesCount = nodes.size(); 
      
      nodes.add(node);
      nodesMap.put(node, new Integer(currentNodesCount));
   }

   /**
    * Add an edge in the digraph. In case the nodes do not exist yet then add them too.
    * 
    * @param fromNode
    * @param toNode
    */
   void addEdge(Node<?> fromNode, Node<?> toNode)
   {
      if (!nodesMap.containsKey(fromNode))
      {
         addNode(fromNode);
      }
      if (!nodesMap.containsKey(toNode))
      {
         addNode(toNode);
      }
      nodes.get(nodesMap.get(fromNode)).outEdges.add(toNode);
      nodes.get(nodesMap.get(toNode)).inEdges.add(fromNode);
      countEdges++;
   }

   /**
    * Remove an edge from the digraph.
    * 
    * @param fromNode
    * @param toNode
    */
   void removeEdge(Node<?> fromNode, Node<?> toNode)
   {
      if (!nodesMap.containsKey(fromNode))
      {
         return;
      }
      if (!nodesMap.containsKey(toNode))
      {
         return;
      }
      nodes.get(nodesMap.get(fromNode)).outEdges.remove(toNode);
      nodes.get(nodesMap.get(toNode)).inEdges.remove(fromNode);
      countEdges--;
   }

   /**
    * Returns the list of nodes sorted in topological order. 
    * Caution: this will destroy the original digraph, therefore be sure to have a copy of it.
   */
   @SuppressWarnings("unchecked")
   List<NodeType> topoSort() throws HasCyclesException
   /**
    * Algorithm(source Wikipedia):
    *   L : Empty list that will contain the sorted elements
    *   S : Set of all nodes with no incoming edges
    *   while S is non-empty do
    *       remove a node n from S
    *       insert n into L
    *       for each node m with an edge e from n to m do
    *           remove edge e from the graph
    *           if m has no other incoming edges then
    *               insert m into S
    *   if graph has edges then
    *       return error (graph has at least one cycle)
    *   else 
    *       return L (a topologically sorted order)
    */
   {
      Set<NodeType> L = new LinkedHashSet<NodeType>();
      Stack<Node<?>> S = new Stack<Node<?>>();
      
      for (Iterator<Node<?>> it = nodes.iterator(); it.hasNext();)
      {
         Node<?> node = it.next();
         if (node.inEdges.size() == 0)
         {
            S.push(node);
         }
      }
      while (!S.empty())
      {
         Node<?> n = S.pop();
         L.add((NodeType) n.nodeType);
         for (Iterator<Node<?>> it = n.outEdges.iterator(); it.hasNext();)
         {
            Node<?> m = it.next();
            removeEdge(n, m);
            if (m.inEdges.size() == 0)
            {
               S.push(m);
            }
         }
      }
      if (countEdges > 0)
      {
         throw new HasCyclesException();
      }
      List<NodeType> sortedList = new ArrayList<NodeType>();
      for (Iterator<NodeType> it = L.iterator(); it.hasNext();)
         sortedList.add(it.next());
      return sortedList;
   }
   
   public Iterator<Node<NodeType>> nodesIterator()
   {
      return new NodesIterator<Node<NodeType>>(this);
   }

   public Iterator<Edge<NodeType>> edgesIterator()
   {
      return new EdgesIterator<NodeType>(this);
   }

}
