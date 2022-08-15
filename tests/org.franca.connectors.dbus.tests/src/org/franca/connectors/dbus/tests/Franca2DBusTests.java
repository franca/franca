package org.franca.connectors.dbus.tests;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;

import java.util.List;

import org.eclipse.emf.compare.Comparison;
import org.eclipse.emf.compare.Diff;
import org.eclipse.emf.compare.EMFCompare;
import org.eclipse.emf.compare.FeatureMapChange;
import org.eclipse.emf.compare.ResourceAttachmentChange;
import org.eclipse.emf.compare.diff.IDiffEngine;
import org.eclipse.emf.compare.internal.spec.ResourceAttachmentChangeSpec;
import org.eclipse.emf.compare.scope.DefaultComparisonScope;
import org.eclipse.emf.compare.scope.IComparisonScope;
import org.eclipse.emf.compare.utils.EMFComparePrettyPrinter;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.xtext.testing.InjectWith;
import org.eclipse.xtext.testing.XtextRunner;
import org.franca.connectors.dbus.DBusConnector;
import org.franca.connectors.dbus.DBusModelContainer;
import org.franca.core.dsl.FrancaIDLTestsInjectorProvider;
import org.franca.core.dsl.FrancaPersistenceManager;
import org.franca.core.franca.FModel;
import org.junit.Test;
import org.junit.runner.RunWith;

import com.google.inject.Inject;

@RunWith(XtextRunner.class)
@InjectWith(FrancaIDLTestsInjectorProvider.class)
public class Franca2DBusTests {

	private static final String LOCAL_FRANCA_MODELS = "model/testcases/";
	private static final String REF_EXAMPLE_FRANCA_MODELS =
			"../../examples/org.franca.examples.reference/models/org/reference/";

	@Inject	FrancaPersistenceManager loader;
	
	@Test
	public void test_20() {
		doTransformTest(LOCAL_FRANCA_MODELS, "20-MapKeyTypes");
	}
	
	@Test
	public void test_30() {
		doTransformTest(LOCAL_FRANCA_MODELS, "30-SimpleAttribute");
	}
	
	@Test
	public void test_40() {
		doTransformTest(LOCAL_FRANCA_MODELS, "40-PolymorphicStructs");
	}

	@Test
	public void test_ref_61() {
		doTransformTest(REF_EXAMPLE_FRANCA_MODELS, "61-Interface");
	}


	@SuppressWarnings("restriction")
	private void doTransformTest (String path, String fileBasename) {
		// load example Franca IDL interface
		String inputfile = path + fileBasename + ".fidl";
		System.out.println("Loading Franca file " + inputfile + " ...");
		FModel fmodel = loader.loadModel(inputfile);
		assertNotNull(fmodel);
		
		// transform to D-Bus Introspection XML
		DBusConnector conn = new DBusConnector();
		DBusModelContainer fromFranca = (DBusModelContainer)conn.fromFranca(fmodel);
		conn.saveModel(fromFranca, "src-gen/testcases/" + fileBasename + ".xml");
		
		// load reference D-Bus xml file
		String referenceFile = "model/reference/" + fileBasename + ".xml";
		DBusModelContainer ref = (DBusModelContainer)conn.loadModel(referenceFile);

		// compare with reference file
		ResourceSet rset1 = fromFranca.model().eResource().getResourceSet();
		ResourceSet rset2 = ref.model().eResource().getResourceSet();

		IComparisonScope scope = new DefaultComparisonScope(rset1, rset2, null);
		IDiffEngine diffEngine = new DBusDiffEngine();
		Comparison comparison = EMFCompare.builder().setDiffEngine(diffEngine).build().compare(scope);
		 
		List<Diff> differences = comparison.getDifferences();
		int nDiffs = 0;
		for (Diff diff : differences) {
			if (diff instanceof ResourceAttachmentChange) {
				// ignore differences in ResourceURIs (we expect them to be different)
			} else if (diff instanceof FeatureMapChange) {
				// ignore differences regarding FeatureMaps
			} else {
				System.out.println(diff.toString());
				nDiffs++;
			}
		}
		if (nDiffs>0) {
			EMFComparePrettyPrinter.printComparison(comparison, System.out);
		}
		assertEquals(0, nDiffs);
	}
}

