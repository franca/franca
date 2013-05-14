package org.franca.core.dsl.tests

import org.eclipselabs.xtext.utils.unittesting.XtextRunner2
import org.franca.core.dsl.FrancaIDLTestsInjectorProvider
import org.junit.runner.RunWith
import org.eclipse.xtext.junit4.InjectWith
import org.junit.Test
import static junit.framework.Assert.*
import java.util.Collections

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
		assertCyclicDependency('''Cyclic dependency detected: (T->S)(S->T)''', model.issues);
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
		assertCyclicDependency('''Cyclic dependency detected: (TheStruct->TheArray)(TheArray->TheStruct)''', model.issues);
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
		assertCyclicDependency('''(e1->e2)(e2->e3)(e3->e4)(e4->e1)''', model.issues);
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
		assertCyclicDependency('''(S->u2)(u2->u1)(u1->S) und dazu (i1->i2)(i2->i1)''', model.issues);
	}
	
	
	
	
	def assertCyclicDependency(String expected, String actual){
		assertEquals("Not the same cycle: " + expected + " vs " + actual,expected.sortCyclicDependencies, actual.sortCyclicDependencies)		
	}
	
	def sortCyclicDependencies(String msg){
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
		Collections::sort(result);
		result
	}
	
}