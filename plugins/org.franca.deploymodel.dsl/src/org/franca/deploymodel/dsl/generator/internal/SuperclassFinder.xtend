/** 
 * Copyright (c) 2018 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package org.franca.deploymodel.dsl.generator.internal

import java.util.List
import java.util.Map
import java.util.Queue
import java.util.Set
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EClassifier
import org.eclipse.emf.ecore.EcorePackage

/**
 * Analyse EClassifier super type hierarchy and find a common superclass for
 * a given input set of classifiers.</p>
 * 
 * @author Klaus Birken (itemis AG) 
 */
class SuperclassFinder {
	
	val Map<EClassifier, List<Integer>> stepsUntilReached = newHashMap
	
	/**
	 * Find a common superclass for a given input set of EClassifiers.</p>
	 * 
	 * This method finds the common superclass of the given set of input EClassifiers.
	 * Among all common superclasses, it chooses the one where the overall number
	 * of inheritance relations (over all input classes) is minimal.</p>
	 * 
	 * Note that due to multiple inheritance this is not necessarily unique.
	 * If there are more than one results, we pick the one with the lexicographically
	 * minimal name.</p>
	 * 
	 * The fallback result is EObject, in case no more specific common superclass
	 * can be found.</p>
	 */
	def EClassifier findCommonSuperclass(Iterable<EClassifier> classes) {
		if (classes.empty)
			return null
			
		if (classes.size==1)
			return classes.get(0)
			
		// compute set of common superclasses with minimal overall distance
		val result = classes.findSuperclassSet
		if (result.empty) {
			EcorePackage.eINSTANCE.EObject
		} else {
			// pick first one according to lexicographic ordering of class names
			result.sortWith[a, b | a.name.compareTo(b. name)].head
		}
	}
	
	/**
	 * Find the set of all superclasses of the classifiers in the given set
	 * which have a minimal overall number of inheritance steps.</p>
	 */
	def private findSuperclassSet(Iterable<EClassifier> classes) {
		// reset data structure
		stepsUntilReached.clear
		
		// traverse inheritance graph for each input class		
		classes.forEach[traverse]
		
		// find all classes which are reachable from all input classes
		val n = classes.size
		val candidates = stepsUntilReached.filter[clazz, reach | reach.size==n].keySet
		
		// compute overall number of steps for each candidate
		val sums = candidates.toMap([it], [stepsUntilReached.get(it).reduce[p1, p2| p1+p2]])
		if (sums.empty)
			return newHashSet
		
		// sort according to overall number of steps
		val minSteps = sums.values.min
		sums.keySet.filter[sums.get(it)==minSteps]
	}
	
	/**
	 * Traverse inheritance graph and find number of inheritance steps from the starting classifier.</p>
	 */
	def private traverse(EClassifier start) {
		val Queue<Pair<EClassifier, Integer>> work = newLinkedList
		val Set<EClassifier> visited = newHashSet
		
		// add start set to work queue
		work.addAll(start -> 0)
		
		while (! work.empty) {
			// get element from work queue
			val w = work.poll
			val clazz = w.key
			val nSteps = w.value
			
			// check if visited already
			if (! visited.contains(clazz)) {
				visited.add(clazz)
				
				// record number of steps up to this point
				if (! stepsUntilReached.containsKey(clazz)) {
					stepsUntilReached.put(clazz, newArrayList)
				}
				stepsUntilReached.get(clazz).add(nSteps)
				
				// add base classes to work queue (with increased step)
				if (clazz instanceof EClass) {
					for(base : clazz.ESuperTypes) {
						work.add(base -> nSteps+1)
					}
				}
			}
		}
	}
}
