package org.franca.core.util.validator.test;

import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;

import java.util.ArrayList;
import java.util.List;

import org.franca.core.dsl.FrancaIDLStandaloneSetup;
import org.franca.core.dsl.FrancaPersistenceManager;
import org.franca.core.franca.FContract;
import org.franca.core.franca.FModel;
import org.franca.core.util.validator.TraceValidator;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.JUnit4;

import com.google.inject.Injector;

@RunWith(JUnit4.class)
public class TraceTest {

	private static String modelFolderPath = "model/";
	private static String modelName = "model2";
	
	@Test
	public void test() {
		List<String> trace = new ArrayList<String>();
		trace.add("b");
		trace.add("b");
		trace.add("a");
		trace.add("c");
		trace.add("c");
		trace.add("c");
		trace.add("c");
		
		FrancaPersistenceManager persistenceManager = new FrancaPersistenceManager();
		Injector injector = new FrancaIDLStandaloneSetup().createInjectorAndDoEMFRegistration();
		injector.injectMembers(persistenceManager);
		@SuppressWarnings("deprecation")
		FModel model = persistenceManager.loadModel(modelFolderPath + modelName	+ ".fidl");

		assertNotNull(model);
		assertTrue(model.getInterfaces().size() > 0);
		FContract contract = model.getInterfaces().get(0).getContract();
		assertNotNull(contract);
		
		assertTrue(TraceValidator.isValidTrace(contract, trace));
		
	}

}
