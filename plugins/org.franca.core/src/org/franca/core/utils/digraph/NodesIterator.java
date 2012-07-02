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
