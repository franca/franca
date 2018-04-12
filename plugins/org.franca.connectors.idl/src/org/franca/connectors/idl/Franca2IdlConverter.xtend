package org.franca.connectors.idl

import com.google.common.collect.Iterables
import org.eclipse.xtext.nodemodel.util.NodeModelUtils
import org.franca.core.franca.FAnnotation
import org.franca.core.franca.FAnnotationType
import org.franca.core.franca.FArgument
import org.franca.core.franca.FArrayType
import org.franca.core.franca.FAttribute
import org.franca.core.franca.FBasicTypeId
import org.franca.core.franca.FBroadcast
import org.franca.core.franca.FConstantDef
import org.franca.core.franca.FEnumerationType
import org.franca.core.franca.FEnumerator
import org.franca.core.franca.FField
import org.franca.core.franca.FInterface
import org.franca.core.franca.FMapType
import org.franca.core.franca.FMethod
import org.franca.core.franca.FModel
import org.franca.core.franca.FModelElement
import org.franca.core.franca.FStructType
import org.franca.core.franca.FType
import org.franca.core.franca.FTypeCollection
import org.franca.core.franca.FTypeDef
import org.franca.core.franca.FTypeRef
import org.franca.core.franca.FUnionType
import org.franca.core.franca.FVersion

class Franca2IdlConverter {
	
	def generateAll(FModel fmodel) {
		val function = [FInterface it | transformInterface]
		val interfaces = fmodel.interfaces?.map(function)
		val function1 = [FTypeCollection it | transformTypeCollection]
		val typeCollections = fmodel.typeCollections?.map(function1)
		
		'''
		module «fmodel.name» {
			«interfaces.join()»
			«typeCollections.join()»
		};
		'''
	}
	
	def private transformTypeCollection(FTypeCollection typeCollection) {
		val types = typeCollection.types?.map[transformType].join('\n')
		var typename = typeCollection.name
		
		var constants = typeCollection.constants?.map[transformConstant].join('\n')
		'''
		«typeCollection.generateComment»
		/// @remark This has been generated from Franca type collection '«typename»'.
		«IF typeCollection.version!==null»
		«typeCollection.version.transformVersion»
		«ENDIF»
		interface «typename» {
			«types»
			«constants»
		};
		'''
	}
	
	def private transformConstant(FConstantDef constant){
		'''
		«constant.generateComment»
		const «constant.type.transformType2TypeString» «constant.name» = «NodeModelUtils.getTokenText(NodeModelUtils.getNode(constant.rhs))»;'''
	}
	
	/***
	* Mapping from Franca to IDL 
	* Interface --> Interface
	*/ 
	def private transformInterface(FInterface fInterface) {
		val types = fInterface.types?.map[transformType].join('\n')
		var baseInterface = fInterface.base?.name
		var constants = fInterface.constants?.map[transformConstant].join('\n')
		var broadcasts = fInterface.broadcasts?.map[transformBroadcast].join('\n')
	'''
		«fInterface.generateComment»
		/// @remark This has been generated from Franca interface '«fInterface.name»'.
		«IF fInterface.version!==null»
		«fInterface.version.transformVersion»
		«ENDIF»
		interface «fInterface.name»«IF baseInterface!==null»:«baseInterface»«ENDIF» {
			«fInterface.attributes?.map[transformAttribute].join('\n')»
			«fInterface.methods?.map[transformMethod].join('\n')»
			«types»
			«constants»
		};
		«IF broadcasts!==null && broadcasts!=''»
		/// @remark This client interface has been generated from Franca interface '«fInterface.name»'.
		«IF fInterface.version!==null»
		«fInterface.version.transformVersion»
		«ENDIF»
		interface «fInterface.name»_client {
			«broadcasts»
		};
		«ENDIF»
		'''
	}

	def private transformVersion(FVersion version) '''
		/// @version «version.major».«version.minor»
	'''
		
	def private transformType(FType type) {
		switch (type) {
			FArrayType: {
					'''typedef «type.elementType.transformType2TypeString»[ ] «type.name»;'''
				}

			FStructType: {
					val fieldContent = type.elements.map[transformField].join('\n')
					var baseStruct = type.base?.name
					'''
					«type.generateComment»
					struct «type.name» «IF baseStruct!==null»:«baseStruct» «ENDIF»{
						«fieldContent»
					};
					''' 
				}
			FUnionType:{
					var baseUnion = type.base?.name
					val fieldContent = type.elements.map[transformField].join('\n')
					
					'''
					«type.generateComment»
					union «type.name» «IF baseUnion!==null»:«baseUnion» «ENDIF»{
						«fieldContent»
					};
					''' 
				}
			FEnumerationType:{
					var baseEnum = type.base?.name
					val content = type.enumerators.map[transformEnumerator].joinPairs(',', '\n')
					
					'''
					«type.generateComment»
					enum «type.name» «IF baseEnum!==null»:«baseEnum» «ENDIF»{
						«content»
					};
					''' 	
				}
			FMapType: {
					'''
					«type.generateComment»
					map_«type.name» «type.keyType.transformType2TypeString»=>«type.valueType.transformType2TypeString»;
					'''
					}
			FTypeDef: {
					var typedef= type as FTypeDef
					'''
					«type.generateComment»
					typedef «typedef.actualType.transformType2TypeString» «type.name»;
					'''
				}
		}
	}

	/**
	 * Join pairs of strings. Except for the last pair, separator1 will be used between the strings of each pair.
	 * Separator2 will be used as usual for extension method join().
	 */					
	def private static String joinPairs(Iterable<Pair<String, String>> iterable, CharSequence separator1, CharSequence separator2) {
		val last = iterable.last
		val joinedPairs = iterable.map[
			if (it==last) joinPair("") else joinPair(separator1)
		]
		joinedPairs.join(separator2)
	}
	
	/**
	 * Join a pair of strings. Use separator even if there is no second item of pair.
	 */
	def private static String joinPair(Pair<String, String> pair, CharSequence separator) {
		val sep = if (separator===null) "" else separator
		if (pair.value===null || pair.value.empty)
			pair.key + sep
		else
			pair.key + sep + pair.value
	}
					
	def private transformEnumerator(FEnumerator enumerator) {
		var name = enumerator.name
		var value = enumerator.value
		val part1 = '''«name»«IF value!==null» = «NodeModelUtils.getTokenText(NodeModelUtils.getNode(enumerator.value))»«ENDIF»'''
		
		val comment = enumerator.transformCommentCompact
		val part2 = if (comment===null || comment.empty) null else "  ///< " + comment 
		Pair.of(part1, part2)
	}
	
	def private transformField(FField field) {
		var type = field.type.transformType2TypeString
		var name = field.name
		val isArray1 = field.array
		
		val comment = field.transformCommentCompact
		'''«type»«IF isArray1»[ ]«ENDIF» «name»;«IF comment!==null && !comment.empty»  ///< «comment»«ENDIF»'''
	}
		
		
	def private transformAttribute(FAttribute attribute) {
		var name = attribute.name
		var type = attribute.type?.transformType2TypeString
		'''
		«attribute.generateComment»
		«IF attribute.isReadonly»readonly «ENDIF»attribute «type» «name»;'''
	}

	def private transformMethod(FMethod method) {
		val params = method.transformParameters
		
		val paramComments = Iterables.concat(
			method.inArgs.map[transformParamComment("")],
			method.outArgs.map[transformParamComment("out argument: ")]
		).filterNull
		
		'''
		«method.generateComment(paramComments)»
		void «method.name» («params»);
		'''

	}

	def private transformBroadcast(FBroadcast broadcast) {
		var name = broadcast.name
		var arguments = broadcast.outArgs?.map[transformArgument("in")].join(', ')

		val paramComments = broadcast.outArgs?.map[transformParamComment("")].filterNull

		'''
		«broadcast.generateComment("This is a Franca IDL broadcast. ", paramComments)»
		void «name» («arguments»);
		'''
	}
	
	def private transformParamComment(FArgument arg, String tag) {
		val txt = arg.transformCommentCompact
		if (txt===null || txt.empty)
			null
		else
			"@param " + arg.name + " " + tag + txt.toFirstUpper
	}
	
	def private transformParameters(FMethod method) {
		val parameters = <String>newArrayList()
      	parameters.addAll(method.inArgs?.map[transformArgument("in")])
		parameters.addAll(method.outArgs?.map[transformArgument("out")])
		parameters.join(', ')
	}

	def private transformArgument(FArgument src, String paramType) {
		var type = transformType2TypeString(src.type)
		paramType + " " + type + " " + src.name
	}

	def private transformType2TypeString(FTypeRef ref) {
		if (ref.derived === null) {
			ref.transformBasicType
			}
		else {
			var type = ref.derived
			type.name
		}
	}
	

	def private transformBasicType(FTypeRef src) {
		switch (src.predefined) {
			case FBasicTypeId::INT8:
				'Int8' 
			case FBasicTypeId::UINT8:
				'UInt8'
			case FBasicTypeId::INT16:
				'Int16'
			case FBasicTypeId::UINT16:
				'UInt16'
			case FBasicTypeId::INT32:
				'Int32'
			case FBasicTypeId::UINT32:
				'UInt32'
			case FBasicTypeId::INT64:
				'Int64'
			case FBasicTypeId::UINT64:
				'UInt64'
			case FBasicTypeId::BOOLEAN:
				'Boolean'
			case FBasicTypeId::STRING:
				'String'
			case FBasicTypeId::FLOAT:
				'Float'
			case FBasicTypeId::DOUBLE:
				'Double'
			case FBasicTypeId::BYTE_BUFFER:
				'ByteBuffer'
			default: {
				'?'
			}
		}
	}

	def private generateComment(FModelElement element) {
		element.generateComment("", newArrayList)
	}
	
	def private generateComment(FModelElement element, Iterable<String> additionalLines) {
		element.generateComment("", additionalLines)
	}
	
	def private generateComment(FModelElement element, String tag, Iterable<String> additionalLines) {
		val lines = element?.transformComment
		val all =
			if (lines.empty || additionalLines.empty)
				Iterables.concat(lines, additionalLines)
			else {
				val empty = <String>newArrayList
				empty.add("")				
				Iterables.concat(lines, empty, additionalLines)
			}

		'''
			«IF ! all.empty»
			/** «tag»
			«FOR a : all»
			«" * "»«a»
			«ENDFOR»
			 */«ELSEIF tag!=""»
			/** «tag» */«ENDIF»
		'''
	}

	/**
	 * Create compact form of a structured comment (i.e., single line).
	 */
	def private transformCommentCompact(FModelElement element){
		val description = element.comment?.elements?.findFirst[type==FAnnotationType.DESCRIPTION]
		val desc = description?.toSingleLine

		val others = element.comment?.elements?.filter[type!=FAnnotationType.DESCRIPTION]
		val remainder = others?.map[
			val t = type?.name()
			if (t!==null)
				t.toLowerCase + "='" + toSingleLine + "'"
			else
				rawText.toSingleLine.replace("@", "").toFirstUpper
		]?.filterNull?.join(", ")
		
		#[desc, remainder].filterNull.join(" ")
	}

	def private toSingleLine(FAnnotation anno) {
		anno?.comment?.toSingleLine
	}

	def private toSingleLine(String multiline) {
		multiline?.split("\n")?.map[trim]?.join(' ')
	}

	/**
	 * Transform Franca structured comment completely.
	 * 
	 * This will contain all elements of the comment, not only the first description.
	 */
	def private Iterable<String> transformComment(FModelElement element){
 		val result = element.comment?.elements?.map[plainText]?.flatten
 		if (result!==null)
 			result
 		else
 			newArrayList
	}
	
	def private Iterable<String> plainText(FAnnotation annotation) {
		val lines = annotation.comment.split("\n").map[trim]
		val type = annotation.type
		val tag = 
			switch (type) {
				case FAnnotationType.DESCRIPTION: ""
				default: "@" + type.name().toLowerCase + " "
			}
		val tagged = newArrayList(tag + lines.head.toFirstUpper)
		Iterables.concat(tagged, lines.tail)
	}

}
