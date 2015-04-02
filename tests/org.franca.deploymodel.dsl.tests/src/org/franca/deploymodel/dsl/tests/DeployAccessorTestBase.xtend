package org.franca.deploymodel.dsl.tests

import java.util.ArrayList
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EObject
import org.eclipselabs.xtext.utils.unittesting.XtextTest
import org.example.spec.ISpecCompoundHostsDataPropertyAccessor
import org.example.spec.ISpecCompoundHostsDataPropertyAccessor.StringProp
import org.example.spec.SpecCompoundHostsInterfacePropertyAccessorRef
import org.franca.core.franca.FField

import static org.junit.Assert.*

class DeployAccessorTestBase extends XtextTest {

	protected SpecCompoundHostsInterfacePropertyAccessorRef accessor
	
	/**
	 * Helper method for loading a deployment model from file and some 
	 * other model files needed for the loaded model. 
	 */
	def protected loadModel(String fileToTest, String... referencedResources) {
		val resList = new ArrayList(referencedResources);
		resList += fileToTest
		var EObject result = null
		for (res : resList) {
			val uri = URI::createURI(resourceRoot + "/" + res);
			result = loadModel(resourceSet, uri, getRootObjectType(uri));
		}
		result
	}
	
	
	/**
	 * Helper for checking the retrieved property values of a StructA
	 * with and without overwrite.
	 * 
	 * @param acc the accessor for the context where this StructA instance has been defined 
	 */
	def protected checkStructA(
		FField f1, FField f2, FField f3,
		ISpecCompoundHostsDataPropertyAccessor acc,
		Integer pSField1,
		Integer pSField2, StringProp pString2,
		Integer pSField3, StringProp pString3, Integer pArray3
	) {
		// access ignoring overwrites
		assertEquals(1, accessor.getSFieldProp(f1))
		assertEquals(2, accessor.getSFieldProp(f2))
		assertEquals(StringProp.u, accessor.getStringProp(f2))
		assertEquals(3, accessor.getSFieldProp(f3))
		assertEquals(StringProp.u, accessor.getStringProp(f3))
		assertEquals(0, accessor.getArrayProp(f3))
		
		// access including overwrites (if any)
		assertEquals(pSField1, acc.getSFieldProp(f1))
		assertEquals(pSField2, acc.getSFieldProp(f2))
		assertEquals(pString2, acc.getStringProp(f2))
		assertEquals(pSField3, acc.getSFieldProp(f3))
		assertEquals(pString3, acc.getStringProp(f3))
		assertEquals(pArray3, acc.getArrayProp(f3))
	}


}