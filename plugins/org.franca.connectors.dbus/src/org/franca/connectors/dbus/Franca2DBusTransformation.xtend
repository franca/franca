package org.franca.connectors.dbus

import com.google.inject.Inject
import java.util.List
import model.emf.dbusxml.AccessType
import model.emf.dbusxml.DbusxmlFactory
import model.emf.dbusxml.DirectionType
import org.franca.core.framework.TransformationLogger
import org.franca.core.franca.FAnnotation
import org.franca.core.franca.FAnnotationType
import org.franca.core.franca.FArgument
import org.franca.core.franca.FArrayType
import org.franca.core.franca.FAttribute
import org.franca.core.franca.FBasicTypeId
import org.franca.core.franca.FBroadcast
import org.franca.core.franca.FCompoundType
import org.franca.core.franca.FEnumerationType
import org.franca.core.franca.FEnumerator
import org.franca.core.franca.FInterface
import org.franca.core.franca.FMapType
import org.franca.core.franca.FMethod
import org.franca.core.franca.FModel
import org.franca.core.franca.FModelElement
import org.franca.core.franca.FStructType
import org.franca.core.franca.FType
import org.franca.core.franca.FTypeDef
import org.franca.core.franca.FTypeRef
import org.franca.core.franca.FTypedElement
import org.franca.core.franca.FUnionType
import org.franca.core.franca.FrancaPackage

import static org.franca.core.framework.TransformationIssue.*

class Franca2DBusTransformation {
	
	@Inject extension TransformationLogger
	
	String mInterfaceName
	
	def create DbusxmlFactory::eINSTANCE.createNodeType transform (FModel src) {
		name = src.name
		interface.addAll(src.interfaces.map [transformInterface])
	}

	def getTransformationIssues() {
		return getIssues
	}

	def create DbusxmlFactory::eINSTANCE.createInterfaceType transformInterface (FInterface src) {
		//println("transformInterface: " + src.name)

		// map metadata of interface
		name = mInterfaceName = src.name
		if (src.version!=null)
			version = "" + src.version.major + "." + src.version.minor
		//doc = src.comment
		
		// map attributes
		property.addAll(src.attributes.map [transformAttribute])
		
		// map methods (request/reponse and broadcast)
		method.addAll(src.methods.map [transformMethod])		
		signal.addAll(src.broadcasts.map [transformBroadcast])		
	}
			
	def create DbusxmlFactory::eINSTANCE.createPropertyType transformAttribute (FAttribute src) {
		name = src.name
		type = transformType2TypeString(src.type, src.array!=null)
		if (src.readonly == "readonly")
			access = AccessType::READ
		else
			access = AccessType::READWRITE
	}

	def create DbusxmlFactory::eINSTANCE.createMethodType transformMethod (FMethod src) {
		name = src.name
		doc = src.createDoc
		arg.addAll(src.inArgs.map [transformArgument(DirectionType::IN)])
		arg.addAll(src.outArgs.map [transformArgument(DirectionType::OUT)])
		if(src.errors != null) error.addAll(src.errors.createErrors)
	}

	def create DbusxmlFactory::eINSTANCE.createSignalType transformBroadcast (FBroadcast src) {
		name = src.name
		doc = src.createDoc
		arg.addAll(src.outArgs.map [transformArgument(DirectionType::OUT)])
	}

	def create DbusxmlFactory::eINSTANCE.createArgType transformArgument (FArgument src, DirectionType dir) {
		direction = dir
		name = src.name
		type = transformType2TypeString(src.type, src.array!=null)
		doc = src.createDoc
	}

	def create DbusxmlFactory::eINSTANCE.createDocType createDoc (FArgument src) {
				
		if(src.type.derived != null && src.type.derived.comment != null) {
			line.addLines(src.name+" (of type "+src.type.derived.name+")", src.description)
			line.addAll(src.type.derived.lineComment)			
		}
		else {
			line.addLines(src.name, src.description)			
		}
	}
	
	def create DbusxmlFactory::eINSTANCE.createDocType createDoc (FModelElement src) {
		if(src.comment != null) {
			line.addLines(src.name, src.description)
		}
	}
	
	def private addLines (List<String> target, String prefix, String multiline) {
		val lines = multiline.split("(\r)?\n")
		var i = 0
		for(s : lines) {
			if (i==0 && prefix!="")
				target.add(prefix + " = " + s.trim)
			else
				target.add(s.trim)
			i = i + 1
		}
	}

	def dispatch lineComment(FType src) {
		newArrayList("lineComment to be defined")
	}

	def dispatch lineComment(FArrayType src) {		
		val s = newArrayList(src.name+" = array["+src.elementType.derived.name+"]")
		s.addAll(src.elementType.derived.lineComment)
		s		
	}				
				
	def dispatch lineComment(FMapType src) {
		
		val s = newArrayList(src.name + " = dictionary(key="+src.keyType.derived.name+",value="+src.valueType.derived.name+")")
	    s.addAll( lineCommentForDictionary(src.keyType.derived, src.valueType.derived))		
		s		
	}				
				
    def dispatch lineCommentForDictionary(FType key, FType value) {
    	
    	val s = newArrayList("key = "+key.lineComment.head);
	    s.addAll("value = " +value.lineComment.head)		
    	s
    	    	    	
    }
				
				
    def dispatch lineCommentForDictionary(FEnumerationType key, FUnionType value) {
    	    	
		val s = newArrayList("key = "+key.allEnumerators.map([name]).toString)    	    	
    	    	
    	for(enumerator: key.allEnumerators) {
    		for(field: value.elements) {
    			if(field.details.contains(enumerator.name)) {
    				s.add("key = "+enumerator.name+" ("+enumerator.value+"), value = of type '"+field.type.transformBasicType+"', "+enumerator.description)
    			}    		
    		}
    	}    	
    	s
    }												
				
	def dispatch lineComment(FCompoundType src) {
		
		val fieldComment = [FTypedElement e| src.name+"."+e.name+ " ('"+e.type.transformBasicType+"') = "+e.description ]
		
		val typename =  switch(src) {
			FStructType:      "struct"
			FUnionType:		  "variant"			
		}
		
		val s = newArrayList(src.name + " "+typename + src.elements.map([name])+" = " + src.description)
		s.addAll(src.elements.map(fieldComment))	
		s
	}								
				
	def dispatch lineComment(FEnumerationType src) {				
		newArrayList("enum"+src.allEnumerators.map[name+" ("+value+")" ])
	}			


	def annotationComments(FModelElement src, FAnnotationType annotationType) {								
		if(src.comment != null) {
			src.comment.elements.filter([FAnnotation a | a.type == annotationType])
		}
	} 			
	
	def description(FModelElement src) {
		val c = src.annotationComments(FAnnotationType::DESCRIPTION)
		if(c != null && c.size > 0) c.head.comment
		else "Description missing"
	}
	
	def details(FModelElement src) {
		val c = src.annotationComments(FAnnotationType::DETAILS)
		if(c != null && c.size > 0) c.head.comment
		else "NO DETAILS AVAILABLE"
	}				

				
    def List<FEnumerator> allEnumerators(FEnumerationType e) {
    	
		val List<FEnumerator> ret = newArrayList()
		
		if(e.base != null) {
			ret.addAll(e.base.allEnumerators)
		}
				
		ret.addAll(e.enumerators.immutableCopy)		
		ret

    }				
				
	def createErrors (FEnumerationType src) {
		src.allEnumerators.map([toError])
	}

	def create DbusxmlFactory::eINSTANCE.createErrorType toError(FEnumerator e) {
		name = mInterfaceName+".Error."+e.name		
		doc = e.createDoc
	}

	
	def String transformType2TypeString (FTypeRef src, boolean isArray) {
		val simple = src.transformSingleType2TypeString
		if (isArray) {
			'a' + simple
		} else {
			simple
		}
	}

	def String transformSingleType2TypeString (FTypeRef src) {
		if (src.derived==null) {
			src.transformBasicType
		} else {
			var type = src.derived
			switch (type) {
				FArrayType:       type.transformArrayType 
				FStructType:      type.transformStructType
				FUnionType:		  type.transformVariantType
				FEnumerationType: type.transformEnumType
				FMapType:         type.transformMapType
				FTypeDef:         type.actualType.transformSingleType2TypeString
			}
		}
	}

	def String transformBasicType (FTypeRef src) {
		switch (src.predefined) {
			case FBasicTypeId::INT8:    'n'  // not_supported in DBus, use INT16 instead
			case FBasicTypeId::UINT8:   'y'
			case FBasicTypeId::INT16:   'n'
			case FBasicTypeId::UINT16:  'q'
			case FBasicTypeId::INT32:   'i'
			case FBasicTypeId::UINT32:  'u'
			case FBasicTypeId::INT64:   'x'
			case FBasicTypeId::UINT64:  't'
			case FBasicTypeId::BOOLEAN: 'b'
			case FBasicTypeId::STRING:  's'
			case FBasicTypeId::FLOAT:   'd'  // TODO: not_supported in DBus?
			case FBasicTypeId::DOUBLE:  'd'
			default: {
				addIssue(FEATURE_NOT_SUPPORTED, src,
					FrancaPackage::FTYPE_REF__PREDEFINED,
					"Basic Franca type " + src.predefined + " not supported by this transformation")
				'?'
			}
		}
	}

	def String transformArrayType (FArrayType src) {
		'a' + src.elementType.transformSingleType2TypeString
	}

	def String transformStructType (FStructType src) {
		var ts = "("
		for(e : src.elements) {
			ts = ts + e.type.transformType2TypeString(e.array!=null)
		}
		ts = ts + ")"

		if (src.base!=null) {
			// TODO: handle src.base
			addIssue(FEATURE_NOT_HANDLED_YET, src,
				FrancaPackage::FSTRUCT_TYPE__BASE,
				"Inheritance for struct " + src.name + " not yet supported")
		}

		return ts
	}
	
	def String transformEnumType (FEnumerationType src) {
		if (src.base!=null) {
			// TODO: handle src.base
			addIssue(FEATURE_NOT_HANDLED_YET, src,
				FrancaPackage::FENUMERATION_TYPE__BASE,
				"Inheritance for enumeration " + src.name + " not yet supported")
		}

		'i'
	}

	def String transformVariantType (FUnionType src) {
		if (src.base!=null) {
			// TODO: handle src.base
			addIssue(FEATURE_NOT_HANDLED_YET, src,
				FrancaPackage::FUNION_TYPE__BASE,
				"Inheritance for union " + src.name + " not yet supported")
		}

		'v'
	}

	def String transformMapType (FMapType src) {
		if (! src.keyType.isProperDictKey) {
			addIssue(FEATURE_NOT_SUPPORTED, src,
				FrancaPackage::FMAP_TYPE__KEY_TYPE,
				"DBus supports only basic types as dict-key (for map " + src.name + ")")
			return '?' 
		}
		'a{' + src.keyType.transformSingleType2TypeString +
				src.valueType.transformSingleType2TypeString + '}' 
	}


	def private isProperDictKey (FTypeRef src) {
		// enumeration types will be mapped to 'i', thus can be used as dict key 
		src.derived==null || (src.derived instanceof FEnumerationType)
	}
}


