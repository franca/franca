/*******************************************************************************
 * Copyright (c) 2012 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.tools.contracts.tests;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;
import static org.junit.Assert.fail;

import java.io.IOException;
import java.io.InputStream;
import java.net.URL;
import java.util.Collection;
import java.util.HashMap;
import java.util.Map;

import org.eclipse.core.runtime.FileLocator;
import org.eclipse.core.runtime.Path;
import org.eclipse.core.runtime.Platform;
import org.eclipse.xtext.junit4.InjectWith;
import org.eclipse.xtext.junit4.XtextRunner;
import org.franca.core.dsl.FrancaIDLInjectorProvider;
import org.franca.core.dsl.FrancaPersistenceManager;
import org.franca.core.franca.FContract;
import org.franca.core.franca.FModel;
import org.franca.core.franca.FState;
import org.franca.tools.contracts.tracegen.TraceGenerator;
import org.franca.tools.contracts.tracegen.strategies.BahaviourAwareStrategyCollection;
import org.franca.tools.contracts.tracegen.traces.BehaviourAwareTrace;
import org.franca.tools.contracts.validator.TraceValidationResult;
import org.franca.tools.contracts.validator.TraceValidator;
import org.franca.tools.contracts.validator.parser.ITraceParser;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.osgi.framework.Bundle;

import com.google.common.collect.Lists;
import com.google.inject.Inject;

@RunWith(XtextRunner.class)
@InjectWith(FrancaIDLInjectorProvider.class)
@SuppressWarnings("deprecation")
public class TraceValidationTests {

	private static String bundleName = "org.franca.tools.contracts.tests";
	
	@Inject
	private FrancaPersistenceManager loader;

	@Inject
	private ITraceParser traceParser;

	/**
	 * These are on-the-fly trace tests with generated traces.
	 */
	@Test
	public void generatedTraceValidationTest() {
		for (String resourcePath : Lists.newArrayList(
				"resources/contracts/reference.fidl", 
				"resources/contracts/test1.fidl"
				)) {
			FModel model = loader.loadModel(resourcePath);

			assertNotNull(model);
			assertTrue(!model.getInterfaces().isEmpty());
			assertNotNull(model.getInterfaces().get(0).getContract());

			FContract contract = model.getInterfaces().get(0).getContract();
			FState initial = contract.getStateGraph().getInitial();

			TraceGenerator traceGenerator = new TraceGenerator(
					new BahaviourAwareStrategyCollection());
			Collection<BehaviourAwareTrace> traces = traceGenerator
					.simulate(initial);

			for (BehaviourAwareTrace trace : traces) {
				assertTrue(TraceValidator.isValidTracePure(contract, trace.toEventList()).valid);
			}
		}
	}
	
	/**
	 * These are simple trace tests with serialized trace files.
	 */
	@Test
	public void defaultTraceTest() {
		FModel model = loader.loadModel("resources/contracts/test1.fidl");
		Bundle bundle = Platform.getBundle(bundleName);
		Map<String, Boolean> data = getDefaultTestData();
		for (String key : data.keySet()) {
			URL url = FileLocator.find(bundle, new Path(key), null);
			
			assertNotNull(url);
			
			FContract contract = model.getInterfaces().get(0).getContract();
			InputStream inputStream = null;
			try {
				inputStream = url.openStream();
				TraceValidationResult result = TraceValidator.isValidTrace(contract, traceParser.parseAll(model, inputStream));
				System.out.println(result.traceElementIndex);
				assertEquals(result.valid, data.get(key));
			} catch (IOException e) {
				e.printStackTrace();
				fail(e.getMessage());
			} finally {
				try {
					inputStream.close();
				} catch (IOException e) {
					e.printStackTrace();
					fail(e.getMessage());
				}
			}
		}
	}
	
	/**
	 * Test data for default trace tests.
	 * 
	 * @return
	 */
	private Map<String, Boolean> getDefaultTestData() {
		Map<String, Boolean> data = new HashMap<String, Boolean>();
		data.put("/resources/traces/test1_fail.trace", false);
		data.put("/resources/traces/test2_success.trace", true);
		data.put("/resources/traces/test3_fail.trace", false);
		return data;
	}

}
