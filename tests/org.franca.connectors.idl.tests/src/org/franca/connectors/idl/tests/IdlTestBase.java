package org.franca.connectors.idl.tests;

import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;
import org.franca.core.dsl.FrancaIDLStandaloneSetup;
import org.franca.core.franca.FModel;

public class IdlTestBase extends FileContentComparator {

	protected FModel loadModel(String filename) {
		FrancaIDLStandaloneSetup.doSetup();
		ResourceSet resourceSet = new ResourceSetImpl();
		Resource res = resourceSet.getResource(URI.createFileURI(filename), true);
		FModel root = (FModel)res.getContents().get(0);
		return root;
	}

}
