/*******************************************************************************
 * Copyright (c) 2015 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.core.dsl.validation.internal

import com.google.common.collect.Lists
import com.google.common.collect.Maps
import com.google.common.collect.Sets
import java.util.List
import java.util.Map
import java.util.Set
import org.eclipse.emf.ecore.EStructuralFeature
import org.franca.core.franca.FBroadcast
import org.franca.core.franca.FInterface
import org.franca.core.franca.FMethod
import org.franca.core.franca.FModelElement

import static org.franca.core.dsl.validation.internal.ValidationHelpers.*
import static org.franca.core.franca.FrancaPackage.Literals.*

class OverloadingValidator {
	
	/**
	 * Check various properties of overloaded methods, especially regarding selectors.
	 */
	def static checkOverloadedMethods(ValidationMessageReporter reporter, FInterface api) {
		checkOverloaded(reporter, "method",
			FMETHOD__SELECTOR, api,
			[methods],
			[m | (m as FMethod).selector]
		)
	}
	
	/**
	 * Check various properties of overloaded broadcasts, especially regarding selectors.
	 */
	def static checkOverloadedBroadcasts(ValidationMessageReporter reporter, FInterface api) {
		checkOverloaded(reporter, "broadcast",
			FBROADCAST__SELECTOR, api,
			[broadcasts],
			[b | (b as FBroadcast).selector]
		)
	}


	/**
	 * Generic function for checking properties of overloaded items of some
	 * specific type, e.g. methods or broadcasts.</p>
	 * 
	 * This includes:</p>
	 * <ol>
	 * <li>non-overloaded items must not have selectors</li>
	 * <li>overloaded items should have selectors</li>
	 * <li>items with same name and signature will not be allowed</li>
	 * </ol>
	 */
	def static private <T extends FModelElement> void checkOverloaded(
		ValidationMessageReporter reporter,
		String type,
		EStructuralFeature selectorFeature,
		FInterface api,
		(FInterface) => List<T> getItems,
		(FModelElement) => String getSelector
	) {
		// preparation 
		val groups = api.getGroups(getItems)
		val local = getItems.apply(api).toSet
		
		// ensure that non-overloaded items do not have selectors
		val overloaded = groups.values.flatten.toSet
		for(i : local) {
			if (getSelector.apply(i)!=null && ! overloaded.contains(i)) {
				reporter.reportWarning(
					"The " + type + " '" + i.name + "' " +
					"is not overloading another " + type + ", " +
					"using a selector is invalid here",
					i, selectorFeature)
			}
		}
		
		// check each group of overloaded items in turn
		for(g : groups.keySet()) {
			checkGroup(reporter, type, selectorFeature, groups.get(g), local, getSelector)
		}
	}
	
	
	/**
	 * Check one group of overloaded items.
	 */
	def static private <T extends FModelElement> void checkGroup(
		ValidationMessageReporter reporter,
		String type,
		EStructuralFeature selectorFeature,
		List<T> items,
		Set<T> local,
		(FModelElement) => String getSelector
	) {
		// check first if group contains identical items (same name and signature)
		// this will lead to an error message and no more other checks for this group
		if (checkDuplicates(reporter, items, FMODEL_ELEMENT__NAME, type) > 0)
			return
		
		// issue warnings for all overloaded items without a selector 
		val withoutSelector = items.filter[getSelector.apply(it) == null].toSet
		val localItems = items.filter[local.contains(it)].toSet
		val localWithoutSelector = localItems.filter[withoutSelector.contains(it)]
		for(i : localWithoutSelector) {
			reporter.reportWarning(
				"The overloaded " + type + " '" + i.name + "' " +
				"should have a selector in order to distinguish overloaded " + type + "s",
				i, FMODEL_ELEMENT__NAME)
		}
		
		// check duplicate selectors
		val names = createNameList
		for(i : items) {
			val sel = getSelector.apply(i)
			if (sel!=null)
			names.add(i, sel)
		}
		checkDuplicates(reporter, names, selectorFeature, "selector in overloaded " + type)
	}
	

	/**
	 * Collect groups of duplicate items (including those from base interfaces),
	 * where each group contains at least one item from interface 'api'.
	 */
	def static private <T extends FModelElement> Map<String, List<T>> getGroups(
		FInterface api,
		(FInterface) => List<T> getItems
	) {
		// first collect all items into clusters
		val Map<String, List<T>> clusters = Maps::newHashMap
		val Set<FInterface> visited = Sets::newHashSet
		var fi = api
		while (fi!=null && !visited.contains(fi)) {
			visited.add(fi)
			for(T m : getItems.apply(fi)) {
				val name = m.name
				if (! clusters.containsKey(name)) {
					clusters.put(name, Lists.newArrayList)
				}
				clusters.get(name).add(m)
			}
			fi = fi.base
		}
		
		// now select clusters which contain at least two items
		val Map<String, List<T>> groups = Maps.newHashMap
		val leafItems = getItems.apply(api).map[name].toSet
		for(String n : clusters.keySet) {
			val items = clusters.get(n)
			if (items.size > 1) {
				// it's a real group of duplicate items,
				// check that at least one item is from leaf interface
				val hit = items.findFirst[leafItems.contains(n)]
				if (hit!=null) {
					groups.put(n, items)
				} 
			}
		}
		
		groups
	}
	
}