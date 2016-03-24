package org.franca.connectors.protobuf

import com.google.eclipse.protobuf.protobuf.Enum
import com.google.eclipse.protobuf.protobuf.Group
import com.google.eclipse.protobuf.protobuf.Import
import com.google.eclipse.protobuf.protobuf.Message
import com.google.eclipse.protobuf.protobuf.MessageElement
import com.google.eclipse.protobuf.protobuf.MessageField
import com.google.eclipse.protobuf.protobuf.Modifier
import com.google.eclipse.protobuf.protobuf.NativeFieldOption
import com.google.eclipse.protobuf.protobuf.Option
import com.google.eclipse.protobuf.protobuf.Protobuf
import com.google.eclipse.protobuf.protobuf.Service
import com.google.eclipse.protobuf.protobuf.SimpleValueLink
import com.google.eclipse.protobuf.protobuf.TypeExtension
import com.google.eclipse.protobuf.protobuf.Value
import java.util.Map
import org.eclipse.xtend.lib.annotations.Accessors
import org.franca.core.franca.FModel

@Accessors
class StructField {
	String name

	String isOptional
	String defaultValue
	String ctype

	String packed
	String experimental_map_key
}

class Protobuf2FrancaDeploymentGenerator {

	var TransformContext currentContext
	var int index

	val Map<String, StructField> structFields = newHashMap

	def generate(Protobuf protobufModel, FModel fModel) {
		index = 0

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
		message.elements.forEach[transformMessageElement(message.name)]
	}

	def transformMessageElement(MessageElement elem, String name) {
		switch elem {
			MessageField: elem.transformMessageField(name)
		}
	}

	def void transformMessageField(MessageField field, String name) {
		if (!field.fieldOptions.empty || field.modifier != Modifier.REPEATED) {
			val structField = new StructField
			structField.name = field.name
			if (field.modifier == Modifier.OPTIONAL)
				structField.isOptional = "true"
			field.fieldOptions.filter(NativeFieldOption).filter [ elem |
				elem.source.target instanceof MessageField
			].forEach [ msgField |
				switch (msgField.source.target as MessageField).name {
					case "default": structField.defaultValue = msgField.value.compileValue
					case "ctype": structField.ctype = msgField.value.compileValue
					case "experimental_map_key": structField.experimental_map_key = msgField.value.compileValue
					case "packed": structField.packed = msgField.value.compileValue
				}
			]
			
			structFields.put(name,structField)
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
