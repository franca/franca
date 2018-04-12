package org.franca.core.dsl.tests.ui

import java.util.Arrays
import org.junit.Test
import org.eclipse.xtext.junit4.ui.util.IResourcesSetupUtil

import static org.junit.Assert.*

class CyclicDependenyValidationUITests extends AbstractMarkerTest {
	/** Check that on manipulation of one file all files that are in cyclic relation with modified file are validated. */
	@Test
	def void testBuilderValidatesEvenUntouchedFiles() {
		val c1 = IResourcesSetupUtil::createFile(
						"sample/model/org/example/C1.fidl", '''
							package org.example
							import model "C2.fidl"
							typeCollection C1 {
								enumeration 
									e1 extends org.example.C2.e2 {
									C1
								}    
							}''');
		val c2 = IResourcesSetupUtil::createFile(
						"sample/model/org/example/C2.fidl", '''
							package org.example
							import model "C3.fidl"
							typeCollection C2 {
								enumeration e2 extends org.example.C3.e3 {
									C2 
								}    
							}''');
		var c3 = IResourcesSetupUtil::createFile(
						"sample/model/org/example/C3.fidl", '''
							package org.example
							import model "C1.fidl"
							typeCollection C3 {
								enumeration e3 extends org.example.C1.e1 {
									C3 
								}    
							}''');
		assertEquals("unexpected no of markers:" +  Arrays::toString(c1.markers.map[message]), 1,c1.markers.size)
		assertEquals("unexpected no of markers:" +  Arrays::toString(c2.markers.map[message]), 1,c2.markers.size)	
		assertEquals("unexpected no of markers:" +  Arrays::toString(c3.markers.map[message]), 1,c3.markers.size)						
        assertMarkerExists(c1,5,"this->org.example.C2.e2->org.example.C3.e3->this");								
		assertMarkerExists(c2,4,"this->org.example.C3.e3->org.example.C1.e1->this");						
		assertMarkerExists(c3,4,"this->org.example.C1.e1->org.example.C2.e2->this");
		c3 = IResourcesSetupUtil::createFile(
						"sample/model/org/example/C3.fidl", '''
							package org.example
							import model "C1.fidl"
							typeCollection C3 {
								enumeration e3  {
									C4 
								}    
							}''');
		assertEquals("unexpected no of markers:" +  Arrays::toString(c1.markers.map[message]),0,c1.markers.size)
		assertEquals("unexpected no of markers:" +  Arrays::toString(c2.markers.map[message]),0,c2.markers.size)	
		assertEquals("unexpected no of markers:" +  Arrays::toString(c3.markers.map[message]),0,c3.markers.size)
		c3 = IResourcesSetupUtil::createFile(
						"sample/model/org/example/C3.fidl", '''
							package org.example
							import model "C1.fidl"
							typeCollection C3 {
								enumeration e3 extends org.example.C1.e1 {
									C3 
								}    
							}''');
		assertEquals("unexpected no of markers:" +  Arrays::toString(c1.markers.map[message]),1,c1.markers.size)
		assertEquals("unexpected no of markers:" +  Arrays::toString(c2.markers.map[message]),1,c2.markers.size)	
		assertEquals("unexpected no of markers:" +  Arrays::toString(c3.markers.map[message]),1,c3.markers.size)						
        assertMarkerExists(c1,5,"this->org.example.C2.e2->org.example.C3.e3->this");								
		assertMarkerExists(c2,4,"this->org.example.C3.e3->org.example.C1.e1->this");						
		assertMarkerExists(c3,4,"this->org.example.C1.e1->org.example.C2.e2->this");											
							
	}

	/** Creates a Cycle c1->c2->c1 and a ref c3->c1. Checks that c3 isn't marked as part of cycle */
	@Test
	def void testNoErrorsForRefToCycle() {
		val c1 = IResourcesSetupUtil::createFile(
						"sample/model/org/example/C1.fidl", '''
							package org.example
							import model "C2.fidl"
							typeCollection C1 {
								enumeration e1 extends org.example.C2.e2 { C1 }
							}''');
		var c2 = IResourcesSetupUtil::createFile(
						"sample/model/org/example/C2.fidl", '''
							package org.example
							import model "C1.fidl"
							typeCollection C2 {
								enumeration e2 extends org.example.C1.e1 { C2 }
							}''');
        assertEquals("unexpected no of markers:" +  Arrays::toString(c1.markers.map[message]),1,c1.markers.size)
		assertEquals("unexpected no of markers:" +  Arrays::toString(c2.markers.map[message]),1,c2.markers.size)	
        assertMarkerExists(c1,4,"this->org.example.C2.e2->this");								
		assertMarkerExists(c2,4,"this->org.example.C1.e1->this");						
		var c3 = IResourcesSetupUtil::createFile(
						"sample/model/org/example/C3.fidl", '''
							package org.example
							import model "C1.fidl"
							typeCollection C3 {
								enumeration e3 extends org.example.C1.e1 {
									C3 
								}    
							}''');
		assertEquals("unexpected no of markers:" +  Arrays::toString(c3.markers.map[message]),0,c3.markers.size)
	}
		
	@Test
	def void testErrorLocations() {
		val c1 = IResourcesSetupUtil::createFile(
						"sample/model/org/example/C1.fidl", '''
							package org.example
							import model "C3.fidl"
							typeCollection C1 {
								// Line breaks are important in order to validate marker locations
								enumeration 
									e1 
										extends 
											e2 
												{ C1 }
								enumeration 
									e2 
										extends 
											org.example.C3.e3 { C2 }
							}''');
		var c3 = IResourcesSetupUtil::createFile(
						"sample/model/org/example/C3.fidl", '''
							package org.example
							import model "C1.fidl"
							typeCollection C3 {
								enumeration e3 extends org.example.C1.e1 {
									C3 
								}    
							}''');
        assertEquals("unexpected no of markers:" +  Arrays::toString(c1.markers.map[message]),2,c1.markers.size)
		assertMarkerExists(c1,6,"this->C1.e2->org.example.C3.e3->this");					
        assertMarkerExists(c1,11,"this->org.example.C3.e3->C1.e1->this");								
		assertEquals("unexpected no of markers:" +  Arrays::toString(c3.markers.map[message]),1,c3.markers.size)
	}
	
}