package org.franca.tools.contracts.tracegen.tests;

import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;

import org.eclipse.xtext.junit4.InjectWith;
import org.eclipse.xtext.junit4.XtextRunner;
import org.franca.core.dsl.FrancaIDLInjectorProvider;
import org.franca.core.dsl.FrancaPersistenceManager;
import org.franca.core.franca.FContract;
import org.franca.core.franca.FInterface;
import org.franca.core.franca.FModel;
import org.franca.core.franca.FState;
import org.franca.core.franca.FStateGraph;
import org.franca.tools.contracts.tracegen.TraceGenerator;
import org.franca.tools.contracts.tracegen.strategies.BahaviourAwareStrategyCollection;
import org.franca.tools.contracts.tracegen.traces.BehaviourAwareTrace;
import org.franca.tools.contracts.tracegen.traces.Trace;
import org.junit.Test;
import org.junit.runner.RunWith;

import com.google.inject.Inject;

/**
 * Test cases for tools related to Franca contracts  
 */
@RunWith(XtextRunner.class)
@InjectWith(FrancaIDLInjectorProvider.class)
public class FrancaContractsTest {

	@Inject
	FrancaPersistenceManager loader;
	
	@Test
	public void test() throws IOException {
		System.out.println("*** FrancaContractsTest");
		
		// load example Franca IDL interface
		String inputfile = "examples/" + TestConfiguration.francaFile; 
		FModel fmodel = loader.loadModel(inputfile);
		assertNotNull(fmodel);
		System.out.println("Franca IDL: package '" + fmodel.getName() + "'");
		
		// select first interface in Franca model
		assertTrue(! fmodel.getInterfaces().isEmpty());
		FInterface first = fmodel.getInterfaces().get(0);

		// generate sequences from this interfaces contract
		FContract contract = first.getContract();
		FStateGraph fsm = contract.getStateGraph();
		
		FState initial = fsm.getInitial();
		
//		TraceGenerator traceGenerator = new TraceGenerator(new DefaultStrategyCollection());
//		TraceGenerator traceGenerator = new TraceGenerator(new Cycle10StrategyCollection());
		TraceGenerator traceGenerator = new TraceGenerator(new BahaviourAwareStrategyCollection());
		Iterable<BehaviourAwareTrace> traces = traceGenerator.simulate(initial);
		
		File outputFolder = new File("./traces");
		if (outputFolder.isDirectory()) {
			for (File f : outputFolder.listFiles()) {
				f.delete();
			}
		} else {
			outputFolder.mkdirs();
		}
			
		int ii = 0;
		for (Trace trace : traces) {
			ii++;
			File output = new File("./traces/out"+ii+".traces");
			if (output.exists()) {
				output.delete();
			} else {
				output.createNewFile();
			}
			FileWriter fw = new FileWriter(output);
			fw.append(trace.toString());
			fw.flush();
			fw.close();
		}
	}

}
