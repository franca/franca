package org.franca.core.utils

import java.util.Collection
import java.util.List
import java.util.Map
import java.util.Queue
import java.util.Set

class CycleChecker {
	
	/**
	 * Check if an object is referenced by its successors (transitively).
	 *
	 * @param which  the target element we are looking for
	 * @param getSuccessors  function representing the successor relation 
	 * @returns the path along the successor relation to the target element
	 */
	def static <T> isReferenced (T which, (T) => Collection<T> getSuccessors) {
		isReferencedBy(which, getSuccessors.apply(which), getSuccessors)
	}

	/**
	 * Check if an object is referenced by a start set of objects (transitively).
	 * 
	 * @param which  the target element we are looking for
	 * @param startSet  the initial set of elements
	 * @param getSuccessors  function representing the successor relation 
	 * @returns the path along the successor relation to the target element
	 */
	def static <T> isReferencedBy (T which, Collection<T> startSet, (T) => Collection<T> getSuccessors) {
		var Queue<T> work = newLinkedList
		var Set<T> visited = newHashSet
		var Map<T,T> predecessor = newHashMap
		
		// add start set to work queue
		work.addAll(startSet)
		
		while (! work.empty) {
			// get element from work queue and check if visited already
			val w = work.poll
			if (! visited.contains(w)) {
				visited.add(w);
				
				// check if element has been found  
				if (w==which) {
					val List<T> path = newArrayList(w)
					var e = w 
					while (predecessor.containsKey(e)) {
						e = predecessor.get(e)
						path.add(e)
					}
					return path.reverse
				}
					
				// add successors of element to work queue
				for(s : getSuccessors.apply(w)) {
					work.add(s)
					predecessor.put(s, w)
				}
			}
		}
		null
	} 
}
