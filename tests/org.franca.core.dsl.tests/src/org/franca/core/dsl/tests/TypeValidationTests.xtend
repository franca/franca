package org.franca.core.dsl.tests

import com.google.inject.Inject
import org.eclipse.xtext.junit4.InjectWith
import org.eclipse.xtext.junit4.util.ParseHelper
import org.eclipselabs.xtext.utils.unittesting.XtextRunner2
import org.franca.core.dsl.FrancaIDLTestsInjectorProvider
import org.franca.core.franca.FModel
import org.junit.runner.RunWith
import org.junit.Test
import static org.junit.Assert.*
import org.franca.core.dsl.FrancaValidationTestHelper

@RunWith(typeof(XtextRunner2))
@InjectWith(typeof(FrancaIDLTestsInjectorProvider))
class TypeValidationTests {

	@Inject ParseHelper<FModel> parser
	@Inject FrancaValidationTestHelper validationHelper

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
			3:Duplicate type name 'MyArray'
			4:Duplicate type name 'MyArray'
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
			3:Duplicate type name 'MyStruct'
			4:Duplicate type name 'MyStruct'
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
			3:Duplicate type name 'MyType'
			4:Duplicate type name 'MyType'
			5:Duplicate type name 'MyType'
			6:Duplicate type name 'MyType'
			7:Duplicate type name 'MyType'
			8:Duplicate type name 'MyType'
		'''

		assertEquals(expected.toString, text.getIssues)
	}


	def private getIssues (CharSequence text) {
		val model = parser.parse(text)
		return validationHelper.getValidationIssues(model)
	}
}

