package org.franca.connectors.c_header

import org.franca.core.franca.FArgument
import org.franca.core.franca.FAttribute
import org.franca.core.franca.FBasicTypeId
import org.franca.core.franca.FEnumerationType
import org.franca.core.franca.FEnumerator
import org.franca.core.franca.FField
import org.franca.core.franca.FMethod
import org.franca.core.franca.FModel
import org.franca.core.franca.FStructType
import org.franca.core.franca.FTypeDef
import org.franca.core.franca.FTypeRef
import org.franca.core.franca.FUnionType

class Franca2CHeaderTransformation {
	
	private static String LINE_BREAK = "\n";
	
	def StringBuffer transform(FModel model) {
		val StringBuilder sb = new StringBuilder();
		
		for (type : model.typeCollections.get(0).types) {
			sb.append(genFType(type));
			sb.append(LINE_BREAK);
		}
		sb.append(LINE_BREAK);
		
		for (method : model.interfaces.get(0).methods) {
			sb.append(genFMethod(method));
			sb.append(LINE_BREAK);
		}
		sb.append(LINE_BREAK);
		
		for (attribute : model.interfaces.get(0).attributes) {
			sb.append(genFAttribute(attribute));
			sb.append(LINE_BREAK);
		}
		
		return new StringBuffer(sb.toString);
	} 
	
	def String genFMethod(FMethod method) {
		val StringBuilder sb = new StringBuilder();
		sb.append(genFTypeRef(method.outArgs.get(0).type)); 
	    sb.append(" "); 
	    sb.append(method.name); 
	    sb.append("(");
	    
	    var i = 0;
	    for (argument : method.inArgs) {
	    	sb.append(genFArgument(argument));
	    	if (i < method.inArgs.size - 1) {
	    		sb.append(", ");
	    	}
	    	i = i + 1;
	    }
	    
	    sb.append(");")
	    return sb.toString;
	}
	
	def String genFAttribute(FAttribute attribute) {
		"extern " + genFTypeRef(attribute.type) + " " + attribute.name + ";"
	}
	
	def String genFArgument(FArgument argument) {
		genFTypeRef(argument.type) + " " + argument.name
	}
	
	dispatch def String genFType(FStructType structType) {
		val StringBuilder sb = new StringBuilder();
		sb.append("typedef struct {");
		sb.append(LINE_BREAK);
		for (element : structType.elements) {
			sb.append("\t"+genFField(element));
			sb.append(";\n");
		} 
		sb.append("} " + structType.name + ";");
		return sb.toString;
	} 
	
	dispatch def String genFType(FUnionType unionType) {
		val StringBuilder sb = new StringBuilder();
		sb.append("typedef union {");
		sb.append(LINE_BREAK);
		for (element : unionType.elements) {
			sb.append("\t"+genFField(element));
			sb.append(";\n");
		} 
		sb.append("} " + unionType.name + ";");
		return sb.toString;
	} 
	
	dispatch def String genFType(FEnumerationType enumerationType) {
		val StringBuilder sb = new StringBuilder();
		sb.append("typedef enum {");
		sb.append(LINE_BREAK);
		var int i = 0
		for (element : enumerationType.enumerators) {
			sb.append("\t"+genFEnumerator(element));
			if (i<enumerationType.enumerators.size - 1) {
				sb.append(",");
			}
			sb.append(LINE_BREAK);
			i = i + 1;
		} 
		sb.append("} " + enumerationType.name + ";");
		return sb.toString;
	} 
	
	dispatch def String genFType(FTypeDef typeDef) {
		"typedef "+ 
		(if (typeDef.actualType.derived == null) genFBasicTypeId(typeDef.actualType.predefined) else typeDef.actualType.derived.name) +
		" " +
		typeDef.name + 
		";"
	}
	
	def String genFEnumerator(FEnumerator enumerator) {
		enumerator.name + if (enumerator.value != null && !enumerator.value.empty) " = " + enumerator.value else ""
	}
	
	def String genFField(FField field) {
		genFTypeRef(field.type) + " " + field.name;
	}
	
	def String genFTypeRef(FTypeRef typeRef) {
		if (typeRef.derived == null) genFBasicTypeId(typeRef.predefined) else typeRef.derived.name;
	}
	
	def String genFBasicTypeId(FBasicTypeId id) {
		switch(id) {
			case FBasicTypeId.BOOLEAN: {
				"bool"
			}
			case FBasicTypeId.INT16: {
				"short"
			}
			case FBasicTypeId.INT32: {
				"int"
			}
			case FBasicTypeId.INT64: {
				"long"
			}
			case FBasicTypeId.UINT16: {
				"unsigned short"
			}
			case FBasicTypeId.UINT32: {
				"unsigned int"
			}
			case FBasicTypeId.UINT64: {
				"unsigned long"
			}
			case FBasicTypeId.DOUBLE: {
				"double"
			}
			case FBasicTypeId.FLOAT: {
				"float"
			}
			default: {
				"int"
			}
		}
	}
}