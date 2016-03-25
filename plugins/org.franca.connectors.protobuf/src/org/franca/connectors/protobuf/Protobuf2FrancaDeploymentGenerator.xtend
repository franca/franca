package org.franca.connectors.protobuf

import com.google.eclipse.protobuf.protobuf.CustomFieldOption
import com.google.eclipse.protobuf.protobuf.CustomOption
import com.google.eclipse.protobuf.protobuf.DefaultValueFieldOption
import com.google.eclipse.protobuf.protobuf.Enum
import com.google.eclipse.protobuf.protobuf.Group
import com.google.eclipse.protobuf.protobuf.Import
import com.google.eclipse.protobuf.protobuf.IndexedElement
import com.google.eclipse.protobuf.protobuf.Message
import com.google.eclipse.protobuf.protobuf.MessageElement
import com.google.eclipse.protobuf.protobuf.MessageField
import com.google.eclipse.protobuf.protobuf.Modifier
import com.google.eclipse.protobuf.protobuf.NativeFieldOption
import com.google.eclipse.protobuf.protobuf.NativeOption
import com.google.eclipse.protobuf.protobuf.Option
import com.google.eclipse.protobuf.protobuf.Protobuf
import com.google.eclipse.protobuf.protobuf.Service
import com.google.eclipse.protobuf.protobuf.SimpleValueLink
import com.google.eclipse.protobuf.protobuf.TypeExtension
import com.google.eclipse.protobuf.protobuf.Value
import java.util.List
import java.util.Map
import org.eclipse.emf.common.util.URI
import org.eclipse.xtend.lib.annotations.Accessors

@Accessors
class StructField{
	String name
	List<Pair<String,String>> options
}

class Protobuf2FrancaDeploymentGenerator {

	var TransformContext currentContext
	var int index

	val Map<String, List<StructField>> structFields = newHashMap
	
	val Map<String, List<Pair<String,String>>> structOptions = newHashMap
	
	@Accessors
	var String packageName
	
	def compile (URI fmodelUri)'''
		import "../specification/ProtobufSpec.fdepl"
		import "../«fmodelUri.trimSegments(0).toFileString»"

		specification «packageName».«fmodelUri.lastSegment.trimFileExtension.toFirstLower»Spec extends org.franca.connectors.protobuf.ProtobufSpec {
			//TODO Add custom options
		}
		
		define «packageName».«fmodelUri.lastSegment.trimFileExtension.toFirstLower»Spec for typeCollection «packageName»{
			«FOR elem : structFields.keySet»
			struct «elem» {
				«FOR option: structOptions.get(elem)»
				«option.key» = «option.value»
				«ENDFOR»
				«FOR field: structFields.get(elem)»
				«field.name» {
					«FOR fieldOption : field.options»
					«fieldOption.key» = «fieldOption.value»
					«ENDFOR»
				}
				«ENDFOR»
			}
			«ENDFOR»
		}
	'''

	def CharSequence generate(Protobuf protobufModel, URI fmodelUri) {
		index = 0
		packageName = (protobufModel.elements.filter(Package).head?.name ?: "dummy_package")

		for (elem : protobufModel.elements) {
			switch (elem) {
				Service:
					elem.transformService
				Message: {
					currentContext = new TransformContext(elem.name.toFirstUpper)
					elem.transformMessage
				}
				Enum:
					elem.transformEnum
				Group: {
					currentContext = new TransformContext("")
					elem.transformGroup
				}
				TypeExtension: {
					index ++;
					elem.transformTypeExtension
				}
				Import: {
					elem.transformImport
				}
				case elem instanceof Package || elem instanceof Option: {
				}
				default: {
				}
			}
		}
		
		return compile(fmodelUri)
	}
	

	def trimFileExtension(String target) {
		target.split("\\.").get(0)
	}

	def void transformImport(Import import1) {
	}

	def transformEnum(Enum enumeration) {
	}

	def void transformTypeExtension(TypeExtension tyExtension) {
	}

	def void transformGroup(Group group) {
	}

	def void transformMessage(Message message) {
		message.elements.forEach[compileMessageElement(message.name)]
	}

	def compileMessageElement(MessageElement elem, String structName) {
		switch elem {
			MessageField: elem.compileMessageField(structName)
			Option: elem.compileOption(structName)
		}
	}
	
	private def dispatch void compileOption(NativeOption option, String structName){
		val structOption = new Pair(option.source.target.optionName,option.value.compileValue)
		if (structOptions.get(structName) == null){
			val list = newArrayList
			list.add(structOption)
			structOptions.put(structName, list)
		} else
			structOptions.get(structName) += structOption
	}
	
	private def String getOptionName(IndexedElement element){
		return switch element{
			MessageField : element.name
			Group : element.name
		}
	}
	
	private def dispatch void compileOption(CustomOption option, String structName){
		//TODO
	}

	private def void compileMessageField(MessageField field, String structName) {
		if (!field.fieldOptions.empty || field.modifier != Modifier.REPEATED) {
			val structField = new StructField
			structField.name = field.name
			structField.options = newArrayList
			structField.options.add(new Pair("Tag", field.index))
			if (field.modifier == Modifier.OPTIONAL){
				structField.options.add(new Pair("IsOptional", "true"))
			} else {
				structField.options.add(new Pair("IsOptional", "false"))
			}
			
			val defaultValue = field.fieldOptions.filter(DefaultValueFieldOption).head
			if (defaultValue !== null)
				structField.options.add(new Pair("DefaultValue", defaultValue.value.compileValue)) 
				
			field.fieldOptions.filter(NativeFieldOption).forEach [ msgField |
				switch msgField.source.target.optionName {
					case "ctype": structField.options.add(new Pair("Ctype", msgField.value.compileValue)) 
					case "experimental_map_key": structField.options.add(new Pair("Experimental_map_key", msgField.value.compileValue)) 
					case "packed": structField.options.add(new Pair("Packed", msgField.value.compileValue))
				}
			]
			
			field.fieldOptions.filter(CustomFieldOption).forEach[
				//TODO
			]
			
			if (structFields.get(structName) == null){
				val array = newArrayList
				array.add(structField)
				structFields.put(structName, array)
			} else
				structFields.get(structName) += structField
		}
	}

	def String compileValue(Value value) {
		switch value {
			SimpleValueLink: value.toString
			default: 'undefined'
		}
	}

	def void transformService(Service service) {
	}

}
