package org.franca.connectors.protobuf

class Protobuf2FrancaUtils {
	def static getContextNameSpacePrefix(TransformContext context) {
		context.namespace.nameSpacePrefix
	}
	
	def static getNameSpacePrefix(String namespace) {
		if (namespace.nullOrEmpty)
			return ""
		else
			namespace.toFirstUpper + "_"
	}
}