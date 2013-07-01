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

}

