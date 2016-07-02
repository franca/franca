package org.franca.connectors.protobuf

import com.google.eclipse.protobuf.protobuf.BooleanLink
import com.google.eclipse.protobuf.protobuf.CustomFieldOption
import com.google.eclipse.protobuf.protobuf.CustomOption
import com.google.eclipse.protobuf.protobuf.DefaultValueFieldOption
import com.google.eclipse.protobuf.protobuf.DoubleLink
import com.google.eclipse.protobuf.protobuf.Enum
import com.google.eclipse.protobuf.protobuf.Extensions
import com.google.eclipse.protobuf.protobuf.FieldOption
import com.google.eclipse.protobuf.protobuf.Group
import com.google.eclipse.protobuf.protobuf.HexNumberLink
import com.google.eclipse.protobuf.protobuf.IndexedElement
import com.google.eclipse.protobuf.protobuf.Literal
import com.google.eclipse.protobuf.protobuf.LiteralLink
import com.google.eclipse.protobuf.protobuf.LongLink
import com.google.eclipse.protobuf.protobuf.Message
import com.google.eclipse.protobuf.protobuf.MessageElement
import com.google.eclipse.protobuf.protobuf.MessageField
import com.google.eclipse.protobuf.protobuf.Modifier
import com.google.eclipse.protobuf.protobuf.NativeFieldOption
import com.google.eclipse.protobuf.protobuf.NativeOption
import com.google.eclipse.protobuf.protobuf.OneOf
import com.google.eclipse.protobuf.protobuf.Option
import com.google.eclipse.protobuf.protobuf.OptionField
import com.google.eclipse.protobuf.protobuf.OptionSource
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
import org.eclipse.xtext.nodemodel.util.NodeModelUtils

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

	val Map<String, List<StructField>> rpcOptions = newHashMap

	val Map<String, List<StructField>> streamOptions = newHashMap

	val Map<String, List<Pair<String, String>>> enumOptions = newHashMap

	val Map<String, List<StructField>> enumeratorOptions = newHashMap

	val List<String> predefinedFileOptions = #["Java_package", "Java_outer_classname", "Java_multiple_files",
		"Java_generate_equals_and_hash", "Optimize_for", "Cc_generic_services", "Java_generic_services",
		"Py_generic_services"]

	val List<String> predefinedStructOptions = #["Message_set_wire_format", "No_standard_descriptor_accessor",
		"Extensions"]

	val List<String> predefinedStructFieldOptions = #["Tag", "FieldRule", "DefaultValue", "Ctype", "Packed",
		"Experimental_map_key", "Deprecated"]

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

	def compileSpecification(Iterable<Pair<String, String>> options, String item)'''
		for «item» {
			«FOR option : options»
			«IF option !== null»
			«option.key.toFirstUpper» : String (optional);
			«ENDIF»
			«ENDFOR»
		}
	'''
	//TODO interface part.
	def compile(String specification, String fidlPath, String fileName) '''
		import "«specification»"
		import "«fidlPath»«fileName».fidl"
		
		specification «packageName».«fileName.path»Spec extends org.franca.connectors.protobuf.ProtobufSpec {
			«IF fileOptions.size > 8 || fileOptions.exists[!predefinedFileOptions.contains(it)]»
				for interfaces {
					«FOR fileOption : fileOptions»
						«IF fileOption !==null && !predefinedFileOptions.contains(fileOption.key)»
							«fileOption.key» : String (optional);
						«ENDIF»
					«ENDFOR»
				}
			«ENDIF»
			«IF structOptions.size > 3 || structOptions.values.flatten.exists[!predefinedStructOptions.contains(it?.key)]»
				for structs {
					«FOR option : structOptions.values.flatten»
						«IF option !==null && !predefinedStructOptions.contains(option?.key)»
							«option.key» : String (optional);
						«ENDIF»
					«ENDFOR»
				}
			«ENDIF»
			«IF structFields.size > 7 || structFields.values.flatten.map[options].flatten.exists[!predefinedStructFieldOptions.contains(it?.key)]»
				for struct_fields {
					«FOR option : structFields.values.flatten.map[options].flatten»
						«IF option !==null && !predefinedStructFieldOptions.contains(option?.key)»
							«option.key» : String (optional);
						«ENDIF»
					«ENDFOR»
				}
			«ENDIF»
			«IF interfaceOptions.size > 0»
				for interfaces {
					«FOR interfaceOption : interfaceOptions.keySet»
						«FOR pair : interfaceOptions.get(interfaceOption)»
							«pair.key.toFirstUpper» : String (optional);
						«ENDFOR»
					«ENDFOR»
				}
			«ENDIF»
			«IF rpcOptions.size > 0»
			«rpcOptions.values.flatten.map[it.options].flatten.compileSpecification("methods")»
			«ENDIF»
			«IF enumOptions.size > 0»
			«enumOptions.values.flatten.compileSpecification("enumerations")»
			«ENDIF»
			«IF enumeratorOptions.size > 0»
			«enumeratorOptions.values.flatten.map[it.options].flatten.compileSpecification("enumerators")»
			«ENDIF»
		}
		
		«IF !structFields.empty || !enumOptions.empty || unionFields.empty»
			define «packageName».«fileName.path»Spec for typeCollection «packageName»{
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
				«FOR elem : enumOptions.keySet»
					enumeration «elem» {
						«FOR option: enumOptions.get(elem)»
						«option.key» = «option.value»
						«ENDFOR»
						«enumeratorOptions.compileStructField(elem)»
					}
				«ENDFOR»
			}
		«ENDIF»
		«FOR interfaceName : interfaceOptions.keySet»
			define «packageName».«fileName.path»Spec for interface «packageName».«interfaceName.path»{
				«FOR option : interfaceOptions.get(interfaceName)»
					«option.key» = «option.value»
				«ENDFOR»
				«FOR field : rpcOptions.get(interfaceName)»
					method «field.name» {
						«FOR fieldOption : field.options»
							«fieldOption.key» = «fieldOption.value»
						«ENDFOR»
					}
				«ENDFOR»
			}
		«ENDFOR»
		«IF !fileOptions.empty»
			define «packageName».«fileName.path»Spec for interface «packageName».FileOption{
				«FOR elem : fileOptions»
					«elem.key» = «elem.value»
				«ENDFOR»
			}
		«ENDIF»
	'''
	
	def String getPath(String fullname) {
		fullname.replace('/','.')
	}

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
				Option: {

					//TODO don't get what this means in CustomOption: ('.' fields+=OptionField ('.' fields+=OptionField)*)?
					fileOptions.add(elem.compileOption(elem.value))
				}
				default: {
				}
			}
		}

		return compile(specification, fidlPath, fileName)
	}
	
	private def dispatch Pair<String,String> compileOption(NativeFieldOption element, Value value) {
		compileOption(element.source, value)
	}
	
	private def dispatch Pair<String,String> compileOption(OptionSource element, Value value) {
		val key = element.target.getOptionName(NodeModelUtils.getNode(element).text.trim).toFirstUpper
		val _value = '''
			«IF element.target.hasStringType || !(predefinedFileOptions.contains(key) ||
				predefinedStructFieldOptions.contains(key) || predefinedStructOptions.contains(key))»
				"«value.compileValue»"
			«ELSE»
				«value.compileValue»
			«ENDIF»
		'''
		return new Pair(key, _value)
	}
	
	private def dispatch Pair<String,String> compileOption(CustomOption element, Value value) {
		compileCustomOption(element.source, element.fields, value)
	}
	
	def compileCustomOption(OptionSource source, EList<OptionField> fields, Value value) {
		val pair = compileOption(source, value)
		val key = pair.key + fields.join("_","_","")[target.getOptionName(NodeModelUtils.getNode(it).text.trim).toFirstUpper]
		new Pair(key,pair.value)
	}
	
	private def dispatch Pair<String,String> compileOption(CustomFieldOption element, Value value) {
		compileCustomOption(element.source, element.fields, value)
	}

	private def dispatch Pair<String,String> compileOption(NativeOption element, Value value) {
		compileOption(element.source, value)
	}

	def trimFileExtension(String target) {
		target.split("\\.").get(0)
	}

	def compileEnum(Enum enumeration) {
		enumeration.elements.forEach [
			switch it {
				Option:
					enumOptions.pushOption(compileOption(value), enumeration.name)
				Literal: {
					val structField = new StructField => [ field |
						field.name = name
						field.options = newArrayList
					]
					it.fieldOptions.forEach [ option |
						structField.options += option.compileFieldOption
					]
					enumeratorOptions.safeAddStructField(structField, enumeration.name)
				}
			}
		]

	}

	def compileFieldOption(FieldOption option) {
		switch option {
			NativeFieldOption:
				option.compileOption(option.value)
			CustomFieldOption:
				option.compileOption(option.value)
		}
	}

	private def getTypeExtensionName(TypeExtension typeExtension) {
		if (typeExtension.type.target.eIsProxy)
			return "unsolved_" + NodeModelUtils.getNode(typeExtension.type).text.replace('.', '_').trim
		else
			return typeExtension.type.target.name.toFirstUpper + "_" + index
	}

	def void compileTypeExtension(TypeExtension typeExtension) {
		typeExtension.elements.forEach [ element |
			element.compileMessageElement(typeExtension.typeExtensionName, true)
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
				isStruct.map.safeAddStructField(structField, namespace)
				elem.compileGroup(newnamespace, true)
			}
			Message:
				elem.compileMessage(namespace.nameSpacePrefix + elem.name.toFirstUpper)
			OneOf: {
				val newnamespace = namespace.nameSpacePrefix + elem.name.toFirstUpper
				val structField = createStructField(elem.name, null, elem.isIsRepeated.oneOfModifier)
				isStruct.map.safeAddStructField(structField, namespace)
				elem.elements.forEach[compileMessageElement(newnamespace, false)]
			}
			Extensions: {
				if (isStruct) {
					val value = elem.ranges.join("'", ",", "'") [
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

	private def safeAddStructField(Map<String, List<StructField>> map, StructField field, String structName) {
		if (map.get(structName) == null) {
			val array = newArrayList
			array.add(field)
			map.put(structName, array)
		} else
			map.get(structName) += field
	}

	private def createStructField(String name, String index, Modifier modifier, EList<FieldOption> fieldOptions,
		String structName) {

		//TODO name as ID converter
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
		val structOption = option.compileOption(option.value)
		structOptions.pushOption(structOption, structName)
	}

	private def void compileMessageField(MessageField field, String structName, boolean isStruct) {
		val structField = createStructField(field.name, field.index.toString, field.modifier, field.fieldOptions,
			structName)
		isStruct.map.safeAddStructField(structField, structName)
	}

	def String compileValue(Value value) {
		switch value {
			LiteralLink: {
				if (value.target.eIsProxy) {
					NodeModelUtils.getNode(value).text.trim
				} else
					value.target.index.toString
			}
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
			StringLink: {
				val string = value.target
				if (string.nullOrEmpty)
					"''"
				else
					string
			}
			default:
				'undefined'
		}
	}

	def void compileService(Service service) {
		service.elements.forEach [
			switch it {
				Option:
					interfaceOptions.pushOption(compileOption(value), service.name)
				Rpc: {
					val structField = new StructField => [ field |
						field.name = name
						field.options = newArrayList
					]
					it.options.forEach [ option |
						structField.options += option.compileOption(option.value)
					]
					rpcOptions.safeAddStructField(structField, service.name)
				}
				Stream: {
					val structField = new StructField => [ field |
						field.name = name
						field.options = newArrayList
					]
					it.options.forEach [ option |
						structField.options += option.compileOption(option.value)
					]
					streamOptions.safeAddStructField(structField, service.name)
				}
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

	private def String getOptionName(IndexedElement element, String defaultValue) {
		return switch element {
			MessageField: element.name ?: defaultValue
			Group: element.name ?: defaultValue
			default: defaultValue
		}
	}

}
