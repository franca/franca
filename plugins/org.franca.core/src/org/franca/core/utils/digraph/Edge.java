package org.franca.core.utils.digraph;

/**
 * Representation of a directed edge in the graph.
 *  
 * @author FPicioroaga
 *
 */
public class Edge<T>
{
   public Node<T> from;
   public Node<T> to;
   
   public Edge(Node<T> fromNode, Node<T> toNode) {
      from = fromNode;
      to = toNode;
   }
}