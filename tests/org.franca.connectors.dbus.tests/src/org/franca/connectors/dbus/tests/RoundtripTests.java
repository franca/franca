package org.franca.connectors.dbus.tests;

import static org.junit.Assert.assertEquals;

import java.util.List;

import org.eclipse.emf.compare.Comparison;
import org.eclipse.emf.compare.Diff;
import org.eclipse.emf.compare.EMFCompare;
import org.eclipse.emf.compare.internal.spec.ResourceAttachmentChangeSpec;
import org.eclipse.emf.compare.scope.IComparisonScope;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.xtext.testing.InjectWith;
import org.franca.connectors.dbus.DBusConnector;
import org.franca.connectors.dbus.DBusModelContainer;
import org.franca.core.dsl.FrancaIDLTestsInjectorProvider;
import org.franca.core.dsl.FrancaPersistenceManager;
import org.franca.core.dsl.tests.util.XtextRunner2_Franca;
import org.franca.core.franca.FModel;
import org.junit.Test;
import org.junit.runner.RunWith;

import com.google.inject.Inject;

import model.emf.dbusxml.NodeType;

@RunWith(XtextRunner2_Franca.class)
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

		IComparisonScope scope = EMFCompare.createDefaultScope(rset1, rset2);
		Comparison comparison = EMFCompare.builder().build().compare(scope);
		 
		List<Diff> differences = comparison.getDifferences();
		int nDiffs = 0;
		for (Diff diff : differences) {
			if (! (diff instanceof ResourceAttachmentChangeSpec)) {
				System.out.println(diff.toString());
				nDiffs++;
			}
		}
		assertEquals(0, nDiffs);
	}

}

