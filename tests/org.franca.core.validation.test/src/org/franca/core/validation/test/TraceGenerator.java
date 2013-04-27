package org.franca.core.validation.test;

import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;

import java.io.FileOutputStream;
import java.io.IOException;
import java.io.ObjectOutputStream;
import java.util.ArrayList;
import java.util.List;
import java.util.Random;

import org.eclipse.xtext.junit4.XtextRunner;
import org.franca.core.dsl.FrancaIDLStandaloneSetup;
import org.franca.core.dsl.FrancaPersistenceManager;
import org.franca.core.franca.FContract;
import org.franca.core.franca.FModel;
import org.franca.core.franca.FState;
import org.franca.core.franca.FTransition;
import org.junit.Test;
import org.junit.runner.RunWith;

import com.google.inject.Injector;

@RunWith(XtextRunner.class)
public class TraceGenerator {

	private static String modelFolderPath = "model/";
	private static String modelName = "model1";

	@Test
	public void generateTrace() {
		FrancaPersistenceManager persistenceManager = new FrancaPersistenceManager();
		Injector injector = new FrancaIDLStandaloneSetup()
				.createInjectorAndDoEMFRegistration();
		injector.injectMembers(persistenceManager);
		@SuppressWarnings("deprecation")
		FModel model = persistenceManager.loadModel(modelFolderPath + modelName
				+ ".fidl");

		assertNotNull(model);
		assertTrue(model.getInterfaces().size() > 0);
		FContract contract = model.getInterfaces().get(0).getContract();
		assertNotNull(contract);

		List<String> trace = new ArrayList<String>();
		final int maxLength = 20;
		int traceLength = 0;

		FState actual = contract.getStateGraph().getInitial();
		Random rand = new Random();
		while (actual != null && traceLength < maxLength) {
			int size = actual.getTransitions().size();
			if (size > 0) {
				FTransition nextTransition = actual.getTransitions().get(
						rand.nextInt(size));
				actual = nextTransition.getTo();
				trace.add(nextTransition.getTrigger().getEvent().getCall()
						.getName());
				traceLength++;
			} else {
				actual = null;
			}
		}

		try {
			FileOutputStream fileOut = new FileOutputStream(modelFolderPath
					+ modelName + ".trace");
			ObjectOutputStream out = new ObjectOutputStream(fileOut);
			out.writeObject(trace);
			out.close();
			fileOut.close();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
}
