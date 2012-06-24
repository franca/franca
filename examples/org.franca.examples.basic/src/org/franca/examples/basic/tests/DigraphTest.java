package org.franca.examples.basic.tests;

import static org.junit.Assert.*;
import java.util.Iterator;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.franca.core.utils.digraph.*;
import org.franca.core.utils.digraph.Digraph.HasCyclesException;

/**
 * Testcase for the Franca=>HTML transformation toolchain.
 * 
 * @author kbirken
 * 
 */
public class DigraphTest {

	@Before
	public void setUp() throws Exception {
	}

	@After
	public void tearDown() throws Exception {
	}

	@Test
	public void test() {
		System.out.println("*** DigraphTest");

		Digraph<String> digraph = new Digraph<String>();

		digraph.addEdge("A", "B");
		digraph.addEdge("B", "C");
		digraph.addEdge("C", "A");
		digraph.addEdge("C", "D");
		String digraphAsString = "Digraph:";
		for (Iterator<Edge<String>> it = digraph.edgesIterator(); it.hasNext();) {
			Edge<String> edge = it.next();
			digraphAsString += "(" + edge.from.value + "->" + edge.to.value + ")";
		}
		System.out.println(digraphAsString);
		try {
			digraph.topoSort();
			assertTrue(true);
		} catch (HasCyclesException e) {
			String cycles = new String();
			for (Iterator<Edge<String>> it = digraph.edgesIterator(); it.hasNext();) {
				Edge<String> edge = it.next();
				cycles += "(" + edge.from.value + "->" + edge.to.value + ")";
			}
			System.out.println("Cycles were detected in: " + cycles);
		}
		digraph.removeEdge("A", "B");
		digraphAsString ="Digraph:";
		for (Iterator<Edge<String>> it = digraph.edgesIterator(); it.hasNext();) {
			Edge<String> edge = it.next();
			digraphAsString += "(" + edge.from.value + "->" + edge.to.value + ")";
		}
		System.out.println(digraphAsString);

		try {
			System.out.print("Topological sort result:");
			for (Iterator<String> it = digraph.topoSort().iterator(); it.hasNext();) {
				System.out.print(it.next() + ",");
			}
		} catch (HasCyclesException e) {
			assertTrue(true);
		}		
	}

}
