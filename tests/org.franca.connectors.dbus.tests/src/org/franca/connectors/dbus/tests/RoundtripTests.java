package org.franca.connectors.dbus.tests;

import static org.junit.Assert.assertEquals;

import java.util.List;

import org.eclipse.emf.compare.Comparison;
import org.eclipse.emf.compare.Diff;
import org.eclipse.emf.compare.EMFCompare;
import org.eclipse.emf.compare.FeatureMapChange;
import org.eclipse.emf.compare.ResourceAttachmentChange;
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

import model.emf.dbusxml.NodeType;
import model.emf.dbusxml.PropertyType;

@RunWith(XtextRunner.class)
@InjectWith(FrancaIDLTestsInjectorProvider.class)
public class RoundtripTests {

	@Inject	FrancaPersistenceManager loader;
	
	@Test
	public void test_32() {
		DBusConnector conn = new DBusConnector();
		String inputfile = "model/testcases/32-StructAttribute.xml";
		DBusModelContainer dbus = (DBusModelContainer)conn.loadModel(inputfile);
		
		FModel fmodel = conn.toFranca(dbus).model();
		loader.saveModel(fmodel, "src-gen/testcases/32-StructAttribute.fidl");

		DBusModelContainer fromFranca = (DBusModelContainer)conn.fromFranca(fmodel);
		NodeType dbus2 = fromFranca.model();
		conn.saveModel(fromFranca, "src-gen/testcases/32-StructAttribute.xml");

		ResourceSet rset1 = dbus.model().eResource().getResourceSet();
		ResourceSet rset2 = dbus2.eResource().getResourceSet();

		IComparisonScope scope = new DefaultComparisonScope(rset1, rset2, null);
		Comparison comparison = EMFCompare.builder().build().compare(scope);
		 
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

