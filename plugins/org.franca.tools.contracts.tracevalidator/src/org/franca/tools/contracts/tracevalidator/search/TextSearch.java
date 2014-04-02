/*******************************************************************************
 * Copyright (c) 2012 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.tools.contracts.tracevalidator.search;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * This class implements the Boyer-Moore algorithm which is an efficient text
 * pattern matching algorithm.
 * 
 * @author Tamas Szabo
 * 
 */
public class TextSearch {

	/**
	 * Performs a search with the given pattern in the given trace. 
	 * Both the trace and the pattern are an array of {@link TraceElement}.
	 * 
	 * @param trace the trace that the search is performed on
	 * @param pattern the pattern that is looked up in the trace
	 * @return -1 if the pattern cannot be found in the trace, or the starting index of the match in the trace
	 */
	public static int search(TraceElement[] trace, TraceElement[] pattern) {

		Map<TraceElement, Integer> badCharacterMap = new HashMap<TraceElement, Integer>();
		int[] goodSuffixBorder = new int[pattern.length + 1];
		int[] goodSuffixShift = new int[pattern.length + 1];
		int i = 0, j = 0;
		// Construct BAD CHARACTER MAP
		// For any x in the dictionary, let R(x) = max(0, i) where P[i] = x
		// Those elements that are not present in the pattern from the
		// dictionary will be assigned o indirectly
		// (they are not present in the map)
		for (i = 0; i < pattern.length - 1; i++) {
			badCharacterMap.put(pattern[i], i);
		}

		// CONSTRUCT GOOD SUFFIX TABLE CASE 1
		i = pattern.length;
		j = pattern.length + 1;
		goodSuffixBorder[i] = j;
		while (i > 0) {
			while (j <= pattern.length
					&& !pattern[i - 1].equals(pattern[j - 1])) {
				// Setting the shift distance if the preceding character is
				// different
				if (goodSuffixShift[j] == 0) {
					goodSuffixShift[j] = j - i;
				}
				j = goodSuffixBorder[j];
			}
			i--;
			j--;
			goodSuffixBorder[i] = j;
		}

		// CONSTRUCT GOOD SUFFIX TABLE CASE 2
		j = goodSuffixBorder[0];
		for (i = 0; i <= pattern.length; i++) {
			if (goodSuffixShift[i] == 0) {
				goodSuffixShift[i] = j;
			}
			if (i == j) {
				j = goodSuffixBorder[j];
			}
		}

		//Actual Boyer-Moore algorithm
		i = 0;
		while (i <= trace.length - pattern.length) {
			j = pattern.length - 1;
			while (j >= 0 && pattern[j].equals(trace[i + j])) {
				j--;
			}
			if (j < 0) {
				return i;
				//i += goodSuffixShift[0];
			} else {
				i += Math.max(goodSuffixShift[j + 1], j - 
						(badCharacterMap.get(trace[i + j]) == null ? -1 : badCharacterMap.get(trace[i + j])));
			}
		}
		
		return -1;
	}

	public static TraceElement[] createFromString(String s) {
		List<TraceElement> trace = new ArrayList<TraceElement>();

		for (char c : s.toCharArray()) {
			trace.add(new CharacterTraceElement(c));
		}

		return trace.toArray(new TraceElement[0]);
	}

	public static void main(String[] args) {

		String text = "kkkkkkabbabakbacbaabbabab";
		String pattern = "abbabab";

		System.out.println(TextSearch.search(TextSearch.createFromString(text), TextSearch.createFromString(pattern)));
	}

}
