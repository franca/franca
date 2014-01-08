package org.franca.core.dsl.tests

import org.eclipse.xtext.junit4.InjectWith
import org.eclipselabs.xtext.utils.unittesting.XtextRunner2
import org.franca.core.dsl.FrancaIDLTestsInjectorProvider
import org.junit.Test
import org.junit.runner.RunWith

import static org.junit.Assert.*

@RunWith(typeof(XtextRunner2))
@InjectWith(typeof(FrancaIDLTestsInjectorProvider))
class TypeValidationTests extends ValidationTestBase {

	@Test
	def validateArrayNameUnique() {
		val text = '''
			package a.b.c
			typeCollection MyTypes {
				array MyArray of Int8
				array MyArray of String
			}
		'''
		
		assertEquals('''
			3:Name conflict for type name 'MyArray'
			4:Name conflict for type name 'MyArray'
		'''.toString, text.getIssues)
	}
	
	@Test
	def validateStructNameUnique() {
		val text = '''
			package a.b.c
			typeCollection MyTypes {
				struct MyStruct { Int16 i }
				struct MyStruct { Int32 k }
			}
		'''
		
		assertEquals('''
			3:Name conflict for type name 'MyStruct'
			4:Name conflict for type name 'MyStruct'
		'''.toString, text.getIssues)
	}
	
	@Test
	def validateTypeNameUnique() {
		val text = '''
			package a.b.c
			typeCollection MyTypes {
				array MyType of Int8
				struct MyType { Int32 k }
				union MyType { Int32 i }
				map MyType { Int16 to String }
				enumeration MyType { A B C }
				typedef MyType is Float
			}
		'''
		
		val expected = '''
			3:Name conflict for type name 'MyType'
			4:Name conflict for type name 'MyType'
			5:Name conflict for type name 'MyType'
			6:Name conflict for type name 'MyType'
			7:Name conflict for type name 'MyType'
			8:Name conflict for type name 'MyType'
		'''

		assertEquals(expected.toString, text.getIssues)
	}

	@Test
	def validateUnionElementNamesUnique() {
		val text = '''
			package a.b.c
			typeCollection MyTypes {
				union MyUnion1 {
					String e1
					UInt16 e2
				}
				union MyUnion2 extends MyUnion1 {
					UInt32 e1
					
				}
				union MyUnion3 extends MyUnion2 {
					Int32 e2
				}
			}
		'''
		
		assertEquals('''
			8:Element name collision with base element 'MyUnion1.e1'
			12:Element name collision with base element 'MyUnion1.e2'
		'''.toString, text.getIssues)
	}
	
	@Test
	def validateUnionElementTypesUnique() {
		val text = '''
			package a.b.c
			typeCollection MyTypes {
				union MyUnion1 {
					String e1
					UInt16 e2
				}
				union MyUnion2 extends MyUnion1 {
					UInt16 e4
				}
				union MyUnion3 extends MyUnion2 {
					String e9
					Int16 u1
					Int16 u2
				}
			}
		'''
		
		assertEquals('''
			8:Element type collision with base element 'MyUnion1.e2'
			11:Element type collision with base element 'MyUnion1.e1'
			12:Duplicate element type 'Int16'
			13:Duplicate element type 'Int16'
		'''.toString, text.getIssues)
	}

	@Test
	def validateUnionHasElements() {
		val text = '''
			package a.b.c
			typeCollection MyTypes {
				union MyUnion { }
			}
		'''
		
		assertEquals('''
			3:Union must have own or inherited elements
		'''.toString, text.getIssues)
	}
	
	@Test
	def validateEnumerationElementNamesUnique() {
		val text = '''
			package a.b.c
			typeCollection MyTypes {
				enumeration MyEnum1 {
					E1
					E2
					E3
					E3
				}
				enumeration MyEnum2 extends MyEnum1 {
					E1
					E4
				}
				enumeration MyEnum3 extends MyEnum2 {
					E1
					E4
					E2
				}
			}
		'''
		
		assertEquals('''
			6:Name conflict for enumerator name 'E3'
			7:Name conflict for enumerator name 'E3'
			10:Enumerator name collision with base element 'MyEnum1.E1'
			14:Enumerator name collision with base element 'MyEnum2.E1'
			15:Enumerator name collision with base element 'MyEnum2.E4'
			16:Enumerator name collision with base element 'MyEnum1.E2'
		'''.toString, text.getIssues)
	}
	
}
