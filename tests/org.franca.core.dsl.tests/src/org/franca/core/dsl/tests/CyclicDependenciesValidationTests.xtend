package org.franca.core.dsl.tests

import org.eclipselabs.xtext.utils.unittesting.XtextRunner2
import org.franca.core.dsl.FrancaIDLTestsInjectorProvider
import org.junit.runner.RunWith
import org.eclipse.xtext.junit4.InjectWith
import org.junit.Test
import static junit.framework.Assert.*
import java.util.Collectionsimport org.junit.Ignoreimport java.util.ArrayList
import java.util.Arrays

@RunWith(typeof(XtextRunner2))
@InjectWith(typeof(FrancaIDLTestsInjectorProvider))
class CyclicDependenciesValidationTests extends ValidationTestBase {
	@Test 
	def void validateFStructTypeCycles() {
		val model = '''
			package a.b.c
			typeCollection MyTypes {
				struct S {
					 T t
				}
				struct T extends S { }
			}	
		'''
		assertDependencyCycles(model, "MyTypes.T" , "MyTypes.S")
	}
	
	@Test
	def void validateFArrayTypeCycles() {
		val model = '''
			package a.b.c
			typeCollection MyTypes {
				struct TheStruct {
					 TheArray a
				}
				array TheArray of TheStruct 
			}	
		'''
		assertDependencyCycles(model, "MyTypes.TheStruct" , "MyTypes.TheArray")
	}
	 
	@Test
	def void validateFEnumerationTypeCycles() {
		val model = '''
			package a.b.c
			typeCollection MyTypes {
				enumeration e1 extends e2{A}
				enumeration e2 extends e3{B}
				enumeration e3 extends e4{C}
				enumeration e4 extends e1{D}
			}	
		'''
		assertDependencyCycles(model, "MyTypes.e2->MyTypes.e3->MyTypes.e4",
			"MyTypes.e3->MyTypes.e4->MyTypes.e1",
			"MyTypes.e4->MyTypes.e1->MyTypes.e2",
			"MyTypes.e1->MyTypes.e2->MyTypes.e3"
		)
	}
	@Test
	def void validateFUnionTypeCycles() {
		val model = '''
			package a.b.c
			typeCollection MyTypes {
				struct S {
					u2 theUnion
				}
				union u1 { S b }
				union u2 extends u1 {}
				union i1  extends i2 {}
				union i2  extends i1 {}
			}
		'''
		assertDependencyCycles(model, "MyTypes.u2->MyTypes.u1",
			"MyTypes.S->MyTypes.u2",
			"MyTypes.u1->MyTypes.S",
			"MyTypes.i2",
			"MyTypes.i1"
		) 
	}
	
	@Test
	def void validateFMapTypeCycles() {
		val model = '''
			package a.b.c
			typeCollection MyTypes {
				struct S1 { M1 m }
				map M1 {Int16 to S1}
				
				union U2 {M2 m}
				map M2 {U2 to Int16}
				
				map M3 {Int16 to M4}
				map M4 {Int16 to M3}
			}
		'''
		assertDependencyCycles(model, "MyTypes.M1",
				"MyTypes.S1",
				"MyTypes.M2",
				"MyTypes.U2",
				"MyTypes.M4",
				"MyTypes.M3"
		) 
	}
	@Test
	def void validateFTypeDefCycles() {
		val model = '''
			package a.b.c
			typeCollection MyTypes {
				struct S1 { TD1 m }
				typedef TD1 is S1 
				
			}
		'''
		assertDependencyCycles(model, "MyTypes.TD1","MyTypes.S1")
	}
	@Test
	@Ignore("Validation won't kick in due to issue http://code.google.com/a/eclipselabs.org/p/franca/issues/detail?id=45")
	def void validateFInterfaceCycles() {
		val model = '''
			package a.b.c
			interface T1 extends T2{}
			interface T2 extends T1{} 
		'''
		assertDependencyCycles(model, "MyTypes.T1","MyTypes.T2")
	}
	
	@Test
	def void validateArrayNoSelfReference() {
		val model = '''
			package a.b.c
			typeCollection MyTypes {
				array MyArray of MyArray
			}
		'''
		assertDependencyCycles(model, "<this>-><this>")
	}
	
	
	@Test
	def void validateArrayNoIndirectSelfReference() {
		val model = '''
			package a.b.c
			typeCollection MyTypes {
				array MyArray of OtherArray
				array OtherArray of MyArray
			}
		'''
		assertDependencyCycles(model, "MyTypes.MyArray","MyTypes.OtherArray")
	}
	
	
	@Test
	def void validateStructNoSelfReference() {
		val model = '''
			package a.b.c
			typeCollection MyTypes {
				struct MyStruct {
					UInt8 a
					MyStruct b
					String c
				}
			}
		'''
		assertDependencyCycles(model, "<this>-><this>")
	}

	@Test
	def void validateUnionNoSelfReference() {
		val model = '''
			package a.b.c
			typeCollection MyTypes {
				union MyUnion {
					UInt8 a
					MyUnion b
					String c
				}
			}
		'''
		assertDependencyCycles(model, "<this>-><this>")
	}

	@Test
	def void validateTypedefNoSelfReference() {
		val model = '''
			package a.b.c
			typeCollection MyTypes {
				typedef MyTypedef is MyTypedef
			}
		'''
		assertDependencyCycles(model, "<this>-><this>")
	}
	def assertDependencyCycles(String model, String... cycles){
		val issues = model.issues
		val splitIssues = new ArrayList(Arrays::asList(issues.split("\n")))
        for (cycle:cycles){
        	var c = cycle
			if(! cycle.startsWith("<this>->")) c= "<this>->" + c
			if(! cycle.endsWith("-><this>")) c= c+"-><this>"
			val d = c
			val hit = splitIssues.findFirst[contains(d)]
			if(hit==null){
				fail("Wert '"+c+"' nicht in issue enthalten: " + issues)
			}
			splitIssues.remove(hit)
        }			
		assertTrue("unerwartete Validierungsfehler: " + splitIssues, splitIssues.nullOrEmpty)		
	}
	
	def sortDependencies(String msg){
		var tmpMsg = msg;
		val result = <String>newArrayList()
		var f = tmpMsg.indexOf('(');
		var t = if(f==-1) -1 else tmpMsg.indexOf(')', f);
		while(t!=-1 ) {
			result += tmpMsg.substring(f+1,t)
			tmpMsg=tmpMsg.substring(t);
			f = tmpMsg.indexOf('(');
			t = if(f==-1) -1 else tmpMsg.indexOf(')', f);
		}
		result.remove("y|ies") // Cause error message contains 'dependenc(y|ies)'
		Collections::sort(result);
		result
	}
	
}