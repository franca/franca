package org.franca.core.utils.digraph;

import java.util.Iterator;


/**
 * Iterate over the digraph nodes.
 * 
 * @author FPicioroaga
 *
 */
public class NodesIterator<T> implements Iterator<T>
{
   Iterator<Node<T>> it;
   
   NodesIterator(Digraph<T> theDigraph)
   {
      it = theDigraph.nodes.iterator();
   }

   public boolean hasNext() {
      return it.hasNext();
   }

   public T next() {
      return it.next().value;
   }

   public void remove() {
      //operation not allowed YET
   }
}
