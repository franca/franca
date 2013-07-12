package org.franca.core.dsl.tests

import org.eclipselabs.xtext.utils.unittesting.XtextRunner2
import org.franca.core.dsl.FrancaIDLTestsInjectorProvider
import org.junit.runner.RunWith
import org.eclipse.xtext.junit4.InjectWith
import org.junit.Test
import static junit.framework.Assert.*
import java.util.Collectionsimport org.junit.Ignore

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
		assertDependencies('''Cyclic dependency detected: (MyTypes.T->MyTypes.S)(MyTypes.S->MyTypes.T)''', model.issues);
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
		assertDependencies('''Cyclic dependency detected: (MyTypes.TheStruct->MyTypes.TheArray)(MyTypes.TheArray->MyTypes.TheStruct)''', model.issues);
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
		assertDependencies('''(MyTypes.e1->MyTypes.e2)(MyTypes.e2->MyTypes.e3)(MyTypes.e3->MyTypes.e4)(MyTypes.e4->MyTypes.e1)''', model.issues);
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
		assertDependencies("(MyTypes.S->MyTypes.u2)(MyTypes.u2->MyTypes.u1)(MyTypes.u1->MyTypes.S) und dazu (MyTypes.i1->MyTypes.i2)(MyTypes.i2->MyTypes.i1)", model.issues);
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
		assertDependencies("(MyTypes.M1->MyTypes.S1)(MyTypes.S1->MyTypes.M1) und (MyTypes.M2->MyTypes.U2)(MyTypes.U2->MyTypes.M2) 
							und (MyTypes.M3->MyTypes.M4)(MyTypes.M4->MyTypes.M3)", model.issues)
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
		assertDependencies("(MyTypes.S1->MyTypes.TD1)(MyTypes.TD1->MyTypes.S1)", model.issues)
	}
	@Test
	@Ignore("Validation won't kick in due to issue http://code.google.com/a/eclipselabs.org/p/franca/issues/detail?id=45")
	def void validateFInterfaceCycles() {
		val model = '''
			package a.b.c
			interface T1 extends T2{}
			interface T2 extends T1{} 
		'''
		assertDependencies("(MyTypes.S1->MyTypes.TD1)(MyTypes.TD1->MyTypes.S1)", model.issues)
	}
	
	@Test
	def validateArrayNoSelfReference() {
		val model = '''
			package a.b.c
			typeCollection MyTypes {
				array MyArray of MyArray
			}
		'''
		assertDependencies("(MyTypes.MyArray->MyTypes.MyArray)", model.issues)
	}
	
	
	@Test
	def validateArrayNoIndirectSelfReference() {
		val model = '''
			package a.b.c
			typeCollection MyTypes {
				array MyArray of OtherArray
				array OtherArray of MyArray
			}
		'''
		assertDependencies("(MyTypes.MyArray->MyTypes.OtherArray)(MyTypes.OtherArray->MyTypes.MyArray)", model.issues)
	}
	
	
	@Test
	def validateStructNoSelfReference() {
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
		assertDependencies("(MyTypes.MyStruct->MyTypes.MyStruct)", model.issues)
	}

	@Test
	def validateUnionNoSelfReference() {
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
		
		assertDependencies('''(MyTypes.MyUnion->MyTypes.MyUnion)''', model.getIssues)
	}

	@Test
	def validateTypedefNoSelfReference() {
		val model = '''
			package a.b.c
			typeCollection MyTypes {
				typedef MyTypedef is MyTypedef
			}
		'''
		assertDependencies('''(MyTypes.MyTypedef->MyTypes.MyTypedef)''', model.getIssues)
	}
	
	def assertDependencies(String expected, String actual){
		assertEquals("Not the same dependencies:" + expected + " vs " + actual,expected.sortDependencies, actual.sortDependencies)		
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