/*******************************************************************************
 * Copyright (c) 2012 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.tools.contracts.tests;

import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;

import java.util.Collection;

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
import org.franca.tools.contracts.validator.TraceValidator;
import org.junit.Test;
import org.junit.runner.RunWith;

import com.google.common.collect.Lists;
import com.google.inject.Inject;

@RunWith(XtextRunner.class)
@InjectWith(FrancaIDLInjectorProvider.class)
@SuppressWarnings("deprecation")
public class ReferenceTraceTests {

	@Inject
	private FrancaPersistenceManager loader;

	@Test
	public void referenceTraceTest() {
		for (String resourcePath : Lists.newArrayList(
				"resources/reference.fidl", "resources/test1.fidl")) {
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
				assertTrue(TraceValidator.isValidTrace(contract,
						trace.toEventList()));
			}
		}
	}

}
