package org.franca.core.util.validator.test;

import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;

import org.franca.core.dsl.FrancaIDLStandaloneSetup;
import org.franca.core.dsl.FrancaPersistenceManager;
import org.franca.core.franca.FContract;
import org.franca.core.franca.FModel;
import org.franca.core.util.search.regexp.RegexpBuilder;
import org.junit.Test;

import com.google.inject.Injector;

public class RegexpTest {

	private static String modelFolderPath = "model/";
	private static String modelName = "demo1";
	
	@Test
	public void test() {		
		FrancaPersistenceManager persistenceManager = new FrancaPersistenceManager();
		Injector injector = new FrancaIDLStandaloneSetup().createInjectorAndDoEMFRegistration();
		injector.injectMembers(persistenceManager);
		@SuppressWarnings("deprecation")
		FModel model = persistenceManager.loadModel(modelFolderPath + modelName	+ ".fidl");

		assertNotNull(model);
		assertTrue(model.getInterfaces().size() > 0);
		FContract contract = model.getInterfaces().get(0).getContract();
		assertNotNull(contract);
		
		System.out.println(RegexpBuilder.buildRegexp(contract));
		
	}

}
