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
import java.util.LinkedList
import java.util.Map
import org.eclipse.emf.common.util.URI
import org.eclipse.xtend.lib.annotations.Accessors
import org.franca.deploymodel.dsl.fDeploy.FDModel
import org.franca.deploymodel.dsl.fDeploy.FDRootElement
import org.franca.deploymodel.dsl.fDeploy.FDSpecification
import org.franca.deploymodel.dsl.fDeploy.FDeployFactory

@Accessors
class StructField {
	String name

	String isOptional
	String defaultValue
	String ctype

	String packed
	String experimental_map_key
}

class Protobuf2FrancaDeployment {

	var TransformContext currentContext
	var int index

	val Map<String, StructField> structFields = newHashMap

	var FDSpecification specification

	val LinkedList<FDRootElement> deployments = new LinkedList

	private def factory() {
		FDeployFactory.eINSTANCE
	}

	def FDModel create factory.createFDModel transform(Protobuf protobufModel, URI fmodelUri) {
		index = 0

		imports += factory.createImport => [
			//TODO make it flexible
			importedSpec = "../specification/ProtobufSpec.fdepl"
			importURI = fmodelUri.trimSegments(0).toFileString
		]

		specification = factory.createFDSpecification
		specification.name = (protobufModel.elements.filter(Package).head?.name ?: "dummy_package") + "." +
			fmodelUri.lastSegment.trimFileExtension.toFirstLower + "Spec"
		specification.base = getBasicSpecification

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

		specifications += specification
	}
	
	private def create factory.createFDSpecification getBasicSpecification() {
		name = "org.franca.connectors.protobuf.ProtobufSpec"
		//TODO
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

			structFields.put(name, structField)
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
