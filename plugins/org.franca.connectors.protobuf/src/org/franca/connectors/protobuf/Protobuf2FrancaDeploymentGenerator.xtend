package org.franca.connectors.protobuf

import com.google.eclipse.protobuf.protobuf.BooleanLink
import com.google.eclipse.protobuf.protobuf.CustomFieldOption
import com.google.eclipse.protobuf.protobuf.DefaultValueFieldOption
import com.google.eclipse.protobuf.protobuf.DoubleLink
import com.google.eclipse.protobuf.protobuf.Enum
import com.google.eclipse.protobuf.protobuf.Extensions
import com.google.eclipse.protobuf.protobuf.FieldOption
import com.google.eclipse.protobuf.protobuf.Group
import com.google.eclipse.protobuf.protobuf.HexNumberLink
import com.google.eclipse.protobuf.protobuf.Import
import com.google.eclipse.protobuf.protobuf.IndexedElement
import com.google.eclipse.protobuf.protobuf.Literal
import com.google.eclipse.protobuf.protobuf.LiteralLink
import com.google.eclipse.protobuf.protobuf.LongLink
import com.google.eclipse.protobuf.protobuf.Message
import com.google.eclipse.protobuf.protobuf.MessageElement
import com.google.eclipse.protobuf.protobuf.MessageField
import com.google.eclipse.protobuf.protobuf.Modifier
import com.google.eclipse.protobuf.protobuf.NativeFieldOption
import com.google.eclipse.protobuf.protobuf.OneOf
import com.google.eclipse.protobuf.protobuf.Option
import com.google.eclipse.protobuf.protobuf.Package
import com.google.eclipse.protobuf.protobuf.Protobuf
import com.google.eclipse.protobuf.protobuf.Rpc
import com.google.eclipse.protobuf.protobuf.ScalarTypeLink
import com.google.eclipse.protobuf.protobuf.Service
import com.google.eclipse.protobuf.protobuf.Stream
import com.google.eclipse.protobuf.protobuf.StringLink
import com.google.eclipse.protobuf.protobuf.TypeExtension
import com.google.eclipse.protobuf.protobuf.Value
import java.util.List
import java.util.Map
import org.eclipse.emf.common.util.EList
import org.eclipse.xtend.lib.annotations.Accessors

import static extension org.franca.connectors.protobuf.Protobuf2FrancaUtils.*

@Accessors
class StructField {
	String name
	List<Pair<String, String>> options
}

class Protobuf2FrancaDeploymentGenerator {

	var TransformContext currentContext
	var int index

	val Map<String, List<StructField>> unionFields = newHashMap

	val Map<String, List<StructField>> structFields = newHashMap

	val Map<String, List<Pair<String, String>>> structOptions = newHashMap

	val List<Pair<String, String>> fileOptions = newArrayList

	val Map<String, List<Pair<String, String>>> interfaceOptions = newHashMap

	val Map<String, List<Pair<String, String>>> rpcOptions = newHashMap

	val Map<String, List<Pair<String, String>>> streamOptions = newHashMap

	val Map<String, List<Pair<String, String>>> enumOptions = newHashMap

	val Map<String, List<Pair<String, String>>> enumeratorOptions = newHashMap

	@Accessors
	var String packageName

	def compileStructField(Map<String, List<StructField>> map, String key) '''
		«FOR field : map.get(key)»
			«field.name» {
				«FOR fieldOption : field.options»
					«IF fieldOption !== null»
						«fieldOption.key» = «fieldOption.value»
					«ENDIF»
				«ENDFOR»
			}
		«ENDFOR»
	'''

	//TODO interface part.
	def compile(String specification, String fidlPath, String fileName) '''
		import "«specification»"
		import "«fidlPath»«fileName».fidl"
		
		specification «packageName».«fileName»Spec extends org.franca.connectors.protobuf.ProtobufSpec {
			//TODO Add custom options
		}
		
		«IF !structFields.empty»
			define «packageName».«fileName»Spec for typeCollection «packageName»{
				«FOR elem : structFields.keySet»
					struct «elem» {
						«IF structOptions.get(elem) !== null»
							«FOR option : structOptions.get(elem)»
								«option.key» = «option.value»
							«ENDFOR»
						«ENDIF»
						«structFields.compileStructField(elem)»
					}
				«ENDFOR»
				«FOR elem : unionFields.keySet»
					union «elem» {
						«unionFields.compileStructField(elem)»
					}
				«ENDFOR»
			}
		«ENDIF»
		«FOR inferfaceName : interfaceOptions.keySet»
			define «packageName».«fileName»Spec for interface «packageName».«inferfaceName»{
				«FOR elem : structFields.keySet»
					struct «elem» {
						«FOR option : structOptions.get(elem)»
							«option.key» = «option.value»
						«ENDFOR»
						«FOR field : structFields.get(elem)»
							«field.name» {
								«FOR fieldOption : field.options»
									«fieldOption.key» = «fieldOption.value»
								«ENDFOR»
							}
						«ENDFOR»
					}
				«ENDFOR»
			}
		«ENDFOR»
	'''

	def CharSequence generate(Protobuf protobufModel, String specification, String fidlPath, String fileName) {
		index = 0
		packageName = (protobufModel.elements.filter(Package).head?.name ?: "dummy_package")

		for (elem : protobufModel.elements) {
			switch (elem) {
				Service:
					elem.compileService
				Message: {
					currentContext = new TransformContext(elem.name.toFirstUpper)
					elem.compileMessage(elem.name.toFirstUpper)
				}
				Enum:
					elem.compileEnum
				Group: {
					currentContext = new TransformContext("")
					elem.compileGroup(elem.name.toFirstUpper, true)
				}
				TypeExtension: {
					index ++;
					elem.compileTypeExtension
				}
				Import: {
					elem.transformImport
				}
				Option: {

					//TODO don't get what this means in CustomOption: ('.' fields+=OptionField ('.' fields+=OptionField)*)?
					fileOptions.add(elem.source.target.compileOption(elem.value))
				}
				default: {
				}
			}
		}

		return compile(specification, fidlPath, fileName)
	}

	private def compileOption(IndexedElement element, Value value) {
		val key = element.optionName.toFirstUpper
		val _value = '''
			«IF element.hasStringType»
				"«value.compileValue»"
			«ELSE»
				«value.compileValue»
			«ENDIF»
		'''
		return new Pair(key, _value)
	}

	def trimFileExtension(String target) {
		target.split("\\.").get(0)
	}

	def void transformImport(Import import1) {
	}

	def compileEnum(Enum enumeration) {
		enumeration.elements.forEach [
			switch it {
				Option:
					enumOptions.pushOption(source.target.compileOption(value), enumeration.name)
				Literal: {
					for (fieldOption : it.fieldOptions) {
						enumeratorOptions.pushOption(fieldOption.compileFieldOption, it.name)
					}
				}
			}
		]

	}

	def compileFieldOption(FieldOption option) {
		switch option {
			NativeFieldOption:
				option.source.target.compileOption(option.value)
			CustomFieldOption:
				option.source.target.compileOption(option.value)
		}
	}

	def void compileTypeExtension(TypeExtension typeExtension) {
		val namespace = typeExtension.type.target.name.toFirstUpper + "_" + index
		typeExtension.elements.forEach [ element |
			element.compileMessageElement(namespace, true)
		]
	}

	def void compileGroup(Group group, String namespace, boolean isStruct) {
		group.elements.forEach [ element |
			(element as MessageElement).compileMessageElement(namespace, isStruct)
		]
	}

	def void compileMessage(Message message, String namespace) {
		message.elements.forEach[compileMessageElement(namespace, true)]
	}

	def void compileMessageElement(MessageElement elem, String namespace, boolean isStruct) {
		switch elem {
			MessageField:
				elem.compileMessageField(namespace, isStruct)
			Option:
				elem.compileStructOption(namespace)
			Group: {
				val newnamespace = namespace.nameSpacePrefix + elem.name.toFirstUpper
				val structField = createStructField(elem.name, elem.index.toString, elem.modifier, elem.fieldOptions,
					namespace)
				structField.safeAddStructField(namespace, isStruct.map)
				elem.compileGroup(newnamespace, true)
			}
			Message:
				elem.compileMessage(namespace.nameSpacePrefix + elem.name.toFirstUpper)
			OneOf: {
				val newnamespace = namespace.nameSpacePrefix + elem.name.toFirstUpper
				val structField = createStructField(elem.name, null, elem.isIsRepeated.oneOfModifier)
				structField.safeAddStructField(namespace, isStruct.map)
				elem.elements.forEach[compileMessageElement(newnamespace, false)]
			}
			Extensions: {
				if (isStruct) {
					val value = elem.ranges.join("'",",","'") [
						'''
							«from» «IF to !== null»to «to»«ENDIF»
						'''.toString.trim
					]

					val structOption = new Pair("Extensions", value)
					structOptions.pushOption(structOption, namespace)
				}
			}
		}
	}

	private def getOneOfModifier(boolean b) {
		if(b) return Modifier.REPEATED else return Modifier.OPTIONAL
	}

	private def getMap(boolean isStruct) {
		if(isStruct) return structFields else return unionFields
	}

	private def createStructField(String name, String index, Modifier modifier) {
		new StructField => [
			it.name = name.toFirstLower
			options = newArrayList
			if (!index.nullOrEmpty)
				options.add(new Pair("Tag", index))
			if (modifier == Modifier.REPEATED) {
				options.add(new Pair("FieldRule", "REPEATED"))
			} else if (modifier == Modifier.REQUIRED) {
				options.add(new Pair("FieldRule", "REQUIRED"))
			} else {
				options.add(new Pair("FieldRule", "OPTIONAL"))
			}
		]
	}

	private def safeAddStructField(StructField field, String structName, Map<String, List<StructField>> map) {
		if (map.get(structName) == null) {
			val array = newArrayList
			array.add(field)
			map.put(structName, array)
		} else
			map.get(structName) += field
	}

	private def createStructField(String name, String index, Modifier modifier, EList<FieldOption> fieldOptions,
		String structName) {
		val structField = createStructField(name, index, modifier)
		val defaultValue = fieldOptions.filter(DefaultValueFieldOption).head
		if (defaultValue !== null)
			structField.options.add(new Pair("DefaultValue", '"' + defaultValue.value.compileValue + '"'))
		fieldOptions.forEach [ elem |
			val value = elem.compileFieldOption
			structField.options.add(value)
		]
		return structField
	}

	private def void pushOption(Map<String, List<Pair<String, String>>> map, Pair<String, String> element, String key) {
		if (map.get(key) == null) {
			val list = newArrayList
			list.add(element)
			map.put(key, list)
		} else
			map.get(key) += element
	}

	private def void compileStructOption(Option option, String structName) {
		val structOption = option.source.target.compileOption(option.value)
		structOptions.pushOption(structOption, structName)
	}

	private def void compileMessageField(MessageField field, String structName, boolean isStruct) {
		val structField = createStructField(field.name, field.index.toString, field.modifier, field.fieldOptions,
			structName)
		structField.safeAddStructField(structName, isStruct.map)
	}

	def String compileValue(Value value) {
		switch value {
			LiteralLink:
				value.target.index.toString
			BooleanLink: {
				switch value.target {
					case TRUE: 'true'
					case FALSE: 'false'
				}
			}
			HexNumberLink:
				value.target.toString
			LongLink:
				value.target.toString
			DoubleLink:
				value.target.toString
			StringLink:
				value.target
			default:
				'undefined'
		}
	}

	def void compileService(Service service) {
		service.elements.forEach [
			switch it {
				Option:
					interfaceOptions.pushOption(source.target.compileOption(value), service.name)
				Rpc:
					it.options.forEach [ option |
						rpcOptions.pushOption(option.source.target.compileOption(option.value), service.name)
					]
				Stream:
					it.options.forEach [ option |
						streamOptions.pushOption(option.source.target.compileOption(option.value), service.name)
					]
			}
		]
	}

	private def hasStringType(IndexedElement element) {
		return switch element {
			MessageField: {
				if (element.type instanceof ScalarTypeLink) {
					switch (element.type as ScalarTypeLink).target {
						case STRING: true
						default: false
					}
				}
			}
			default:
				false
		}
	}

	private def String getOptionName(IndexedElement element) {
		return switch element {
			MessageField: element.name ?: "UnNamed"
			Group: element.name ?: "UnNamed"
			default: "unsolved"
		}
	}

}
