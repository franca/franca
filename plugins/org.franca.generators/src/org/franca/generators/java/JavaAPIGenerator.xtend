/*******************************************************************************
* Copyright (c) 2012 Harman International (http://www.harman.com).
* All rights reserved. This program and the accompanying materials
* are made available under the terms of the Eclipse Public License v1.0
* which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/epl-v10.html
*******************************************************************************/
package org.franca.generators.java

import org.franca.core.franca.FArgument
import org.franca.core.franca.FBroadcast
import org.franca.core.franca.FInterface
import org.franca.core.franca.FMethod
import org.franca.core.franca.FBasicTypeId
import org.franca.core.franca.FTypeRef
import org.franca.core.franca.FAnnotationBlock
import org.franca.core.franca.FAnnotation

class JavaAPIGenerator {

	def generateInterface (FInterface api, String pkg) '''
		package «pkg»;
		/**
		 * Server API for interface «api.name»
		 */
		interface I«api.name» {
			«FOR m : api.methods»
				«m.generate»
			«ENDFOR»
		}
	'''
	
	def getInterfaceFilename (FInterface api) {
		"I" + api.name + ".java"
	}


	def generate (FMethod it) '''
		«comment.genCommentBlockActual»
		public void «name» («FOR a : inArgs SEPARATOR ', '»«a.generate»«ENDFOR»);
		
	'''

	
	// ********************************************************************************

	def generateServerBase (FInterface api, String pkg) '''
		package «pkg»;
		/**
		 * Base class for «api.name» server classes
		 */
		class C«api.name»ServerBase {
			«FOR m : api.methods»
				«m.generateResponse»
			«ENDFOR»
			«FOR m : api.broadcasts»
				«m.generateBroadcast»
			«ENDFOR»
		}
	'''
		
	def getServerBaseFilename (FInterface api) {
		"C" + api.name + "ServerBase.java"
	}


	def generateResponse (FMethod it) '''
		«comment.genCommentBlockActual»
		public void respond«name.toFirstUpper» («FOR a : outArgs SEPARATOR ', '»«a.generate»«ENDFOR») {
			// TODO
		}
		
	'''

	def generateBroadcast (FBroadcast it) '''
		«comment.genCommentBlockActual»
		public void «name» («FOR a : outArgs SEPARATOR ', '»«a.generate»«ENDFOR») {
			// TODO
		}
		
	'''


	// ********************************************************************************
	
	def generate (FArgument it) '''«type.map2JavaType» «name»'''
	
	def genCommentBlock (FAnnotationBlock src) {
		if (src.elements.empty)
			''
		else
			src.genCommentBlockActual
	}

	def genCommentBlockActual (FAnnotationBlock it) '''
		«IF it!==null»
		/**
		«FOR e : elements»
			«genAnnotationElement(e)»
		«ENDFOR»
		 */
		«ENDIF»
	'''

	def genAnnotationElement (FAnnotation it) '''
		«" "»* «type.literal» : «comment»
	'''

	def genMultiline (String multiline) '''
		/**
		«FOR line : multiline.split("\\n")»
		 «" "»* «line.replace('\r', '')»
		«ENDFOR»
		 */
	'''

	
	def map2JavaType (FTypeRef it) {
		if (derived!==null) {
			"String /*" + derived.name + "*/"  // TODO			
		} else {
			switch (predefined) {
				case FBasicTypeId::INT8   : "int"
				case FBasicTypeId::INT16  : "int"
				case FBasicTypeId::INT32  : "long"
				case FBasicTypeId::UINT8  : "int"
				case FBasicTypeId::UINT16 : "int"
				case FBasicTypeId::UINT32 : "long"
				case FBasicTypeId::STRING : "String"
				default                   : "String /*" + predefined.toString + "*/"  // TODO
			}
		}
	}
}
