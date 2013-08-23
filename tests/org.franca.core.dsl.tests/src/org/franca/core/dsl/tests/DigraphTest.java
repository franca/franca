package org.franca.core.dsl.tests;

import static org.junit.Assert.assertTrue;

import java.util.Iterator;

import org.franca.core.utils.digraph.Digraph;
import org.franca.core.utils.digraph.Digraph.HasCyclesException;
import org.franca.core.utils.digraph.Digraph.NotExistingEdge;
import org.franca.core.utils.digraph.Edge;
import org.junit.Test;

/**
 * Testcase for the Franca=>HTML transformation toolchain.
 * 
 * @author kbirken
 * 
 */
public class DigraphTest {

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
			System.out.println("Cycles were detected in: " + digraph.edgesToString());
		}
		try {
			digraph.removeEdge("A", "B");
		} catch (NotExistingEdge e1) {
			e1.printStackTrace();
		}
		digraphAsString ="Digraph:";
		System.out.println("Digraph:" + digraph.edgesToString());

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
