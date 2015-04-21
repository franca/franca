package org.franca.connectors.idl

import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.xtext.nodemodel.util.NodeModelUtils
import org.franca.core.dsl.FrancaIDLStandaloneSetup
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
		val types = typeCollection.types?.map[transformTypes].join('\n')
		var typename = typeCollection.name
		
		var constants = typeCollection.constants?.map[transformConstants].join('\n')
		val generateComment = typeCollection.generateComment
		'''
		«IF generateComment!=null && generateComment!=''»
		/** «generateComment» 
		*/«ENDIF»
			interface «typename» {
				«types»
				«constants»
			};
		'''
	}
	
	def private transformConstants(FConstantDef constant){
		val generateComment = constant.generateComment
		
		'''
		«IF generateComment!=null && generateComment!=''»
		/** «generateComment» 
		*/«ENDIF»
		 const «constant.type.transformType2TypeString» «constant.name» = «NodeModelUtils.getTokenText(NodeModelUtils.getNode(constant.rhs))»;'''
	}
	
	def private generateComment(FModelElement element){
		val StringBuffer bufferText =new StringBuffer;
 		element.comment?.elements?.forEach[bufferText.append(rawText)]
 		var str = bufferText.toString.replaceAll("@description","#comment");
		str
	}
	/***
	* Mapping from Franca to IDL 
	* Interface -- > Interface
	*/ 
	def private transformInterface(FInterface fInterface) {
		val types = fInterface.types?.map[transformTypes].join('\n')
		var baseInterface = fInterface.base?.name
		val generateComment = fInterface.generateComment
		var constants = fInterface.constants?.map[transformConstants].join('\n')
		var broadcasts = fInterface.broadcasts?.map[transformBroadcasts].join('\n')
	'''
	«IF generateComment!=null && generateComment!=''»
	/** «generateComment» 
		*/«ENDIF»
		interface «fInterface.name»«IF baseInterface!=null»:«baseInterface»«ENDIF» {
			«fInterface.attributes?.map[transformAttributes].join('\n')»
	 		«fInterface.methods?.map[transformMethods].join('\n')»
	 		«types»
	 		«constants»
		};
		«IF broadcasts!=null && broadcasts!=''»
		interface «fInterface.name»_client {
			«broadcasts»
		};
		«ENDIF»
		'''
	}
	
	def private transformBroadcasts(FBroadcast broadcast) {
		val generateComment = broadcast.generateComment
		var name = broadcast.name
		var arguments = broadcast.outArgs?.map[transformArgument("in")].join(',')
		'''
		«IF generateComment!=null && generateComment!=''»
		/**broadcast 
		*«generateComment» 
		*/«ENDIF»
		void «name» ( «arguments» );
		'''
	}
	
	def private transformTypes(FType type) {
		switch (type) {
			FArrayType: {
					val fArrayType = type as FArrayType
					''' typedef «fArrayType.elementType.transformType2TypeString»[ ] «fArrayType.name»;'''
				}

			FStructType: {
					var struct = type as FStructType
					val fieldContent = struct.elements.map[transformFields].join('\n')
					var baseStruct = struct.base?.name
					'''struct «struct.name» «IF baseStruct!=null»:«baseStruct» «ENDIF»{
						«fieldContent»
						};
					''' 
				}
			FUnionType:{
				
					var union = type as FUnionType
					var baseUnion = union.base?.name
					val fieldContent = union.elements.map[transformFields].join('\n')
					
					'''union «union.name» «IF baseUnion!=null»:«baseUnion» «ENDIF»{
						«fieldContent»
						};
					''' 
				}
			FEnumerationType:{
					var enumtype = type as FEnumerationType
					var baseEnum = enumtype.base?.name
					val Content = enumtype.enumerators.map[transformEnumerators].join(',\n')
					
					'''enum «enumtype.name»  «IF baseEnum!=null»:«baseEnum» «ENDIF»{
						«Content»
						};
					''' 	
				}
			FMapType: {
					var map = type as FMapType
					'''map_«map.name» «map.keyType.transformType2TypeString»=>«map.valueType.transformType2TypeString» ;'''
					}
			FTypeDef: {
					var typedef= type as FTypeDef
					'''typedef 	«typedef.actualType.transformType2TypeString» «type.name»;'''
					
				}
			}
		}
					
					
	def private isArray(FTypeRef ref) {
		if 	(ref.derived == null) {
			''' '''
		}
		else {
			var type = ref.derived
			switch (type) {
				FArrayType: '''[ ]'''
				FTypeDef: type.actualType.transformType2TypeString
				default : ''' '''
			}
		}
	}
	
	def private transformEnumerators(FEnumerator eumerator) {
		var name = eumerator.name
		var value = eumerator.value
		'''«name» «IF value!=null»= «NodeModelUtils.getTokenText(NodeModelUtils.getNode(eumerator.value))»«ENDIF»'''
	}
	
	def private transformFields(FField field) {
		var type = field.type.transformType2TypeString
		var name = field.name
		val isArray1 = field.array
		
		var isArray = field.type.isArray
		'''«type»«IF isArray1»[ ]«ENDIF» «name»;'''
	}
		
		
	def private transformAttributes(FAttribute attribute) {
		var name = attribute.name
		var type = attribute.type?.transformType2TypeString
		val generateComment = attribute.generateComment
		'''
		«IF generateComment!=null && generateComment!=''»
		/** «generateComment» 
		*/«ENDIF»
		«IF attribute.isReadonly»readonly«ENDIF»«name» «type» ;'''
		
	}

	def private transformMethods(FMethod method) {
		val transformParameters1 = method.transformParameters
		val generateComment = method.generateComment
		
		'''
		«IF generateComment!=null && generateComment!=''»
		/** «generateComment» 
		*/«ENDIF»
		void «method.name» ( «transformParameters1» );
		'''

	}

	def private transformParameters(FMethod method) {
		val parameters = newArrayList()

      	parameters.addAll(method.inArgs?.map[transformArgument("in")])
		parameters.addAll(method.outArgs?.map[transformArgument("out")])
		parameters.join(',')
	}

	def private transformArgument(FArgument src, String paramType) {

		var name = src.name
		var type = transformType2TypeString(src.type)
		if(paramType == "in") return '''in «type» «name»'''
		return '''out «type» «name»'''

	}

	def private transformType2TypeString(FTypeRef ref) {
		if (ref.derived == null) {
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

}
		
		

