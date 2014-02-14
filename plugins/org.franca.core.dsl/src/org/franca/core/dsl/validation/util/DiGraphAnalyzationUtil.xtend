/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.core.dsl.validation.util

import com.google.common.collect.ArrayListMultimap
import com.google.common.collect.Multimap
import java.util.Collection
import java.util.Iterator
import java.util.List
import org.franca.core.utils.digraph.Edge

class DiGraphAnalyzationUtil {
	
	/** Converts edges into a MultiMap, key = from.value, value = (List of) to.value */
	def <T> Multimap<T, T> toMultiMap(Iterator<Edge<T>> edgeIt){
		val result = ArrayListMultimap::<T, T>create()
		edgeIt.forEach[result.put(from.value, to.value)]
		result
	} 
	
	/** 
	 * Splits the cycles within the DiGraph represented by the give Multimap. <p/>
	 * The Multimap is expected to be the result of {@link #toMultiMap(Iterator)} after the DiGraph has been topoSorted.
	 * {1=[2], 2=[1], 10=[11], 11=[10]} returns [[1,2][10,11]] <br/>
	 * NOTE:
	 * The underlying algorithm relies on the above mentioned expectation.
	 * If the mappedEdges do not represent the above mentioned expectation, 
	 * i.e they are not part-of-a-cycle-edges of a digraph only, results are unpredictable.
	 */	
	def <T> List<List<T>> separateCycles(Multimap<T, T> mappedEdges){
		val keys = newArrayList()
		keys.addAll(mappedEdges.keySet)
		val result = <List<T>>newArrayList()
		var List<T>curList = null
		var Collection<T> curNodes = null
		while(! keys.empty){
			if(curNodes.nullOrEmpty){
				curList = newArrayList()
				result.add(curList)
				curNodes =  <T>newArrayList(keys.head)
			}
			curList.addAll(curNodes)
			keys.removeAll(curNodes)
			curNodes = curNodes.map[mappedEdges.get(it)].flatten.toSet
			curNodes.removeAll(curList)
		}
		result
	}
}
