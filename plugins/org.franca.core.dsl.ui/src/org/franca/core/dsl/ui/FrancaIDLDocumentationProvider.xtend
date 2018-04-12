/*******************************************************************************
 * Copyright (c) 2018 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.core.dsl.ui

import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.documentation.impl.MultiLineCommentDocumentationProvider
import org.franca.core.franca.FAnnotation
import org.franca.core.franca.FAnnotationBlock
import org.franca.core.franca.FAnnotationType
import org.franca.core.franca.FModelElement

/**
 * Documentation provider which adds Franca's structured comments to the hover
 * for all referenced Franca model elements.</p>
 * 
 * @author Klaus Birken (itemis AG)
 */
class FrancaIDLDocumentationProvider extends MultiLineCommentDocumentationProvider {

	/**
	 * Deliver a documentation for the hover including
	 * normal comments and structured comments
	 */
	override String getDocumentation(EObject obj) {
		val comment = super.getDocumentation(obj)
		if (obj instanceof FModelElement) {
			val structuredComment = '''<p>«obj.comment.format»</p>'''
			if (comment!==null) {
				if (structuredComment.length > 0)
					"<p>" + comment + "</p>" + structuredComment
				else
					comment
			} else {
				structuredComment
			}
		} else {
			comment
		}
	}

	def private String format(FAnnotationBlock ab) {
		val StringBuilder anno = new StringBuilder
		if (ab !== null) {
			for (a : ab.elements) {
				if (a.comment!==null) {
					// skip tag for descriptions
					if (a.type!==FAnnotationType.DESCRIPTION)
						anno.append(a.format)

					// chomp every line for multi-line texts and replace \n by html linebreak						
					val reformatted = a.comment?.split("\n").map[chomp].join("<br/>")
					anno.append(reformatted)
					
					anno.append("<br/><br/>")
				}
			}
		}
		anno.toString
	}

	def private format(FAnnotation anno) {
		'''<i>«anno.type.getName.toFirstUpper»</i>: '''
	}

	/**
	 * Eat leading whitespace for strings.</p>
	 */	
	def private chomp(String str) {
		for(var i=0; i<str.length; i++) {
			val c = str.charAt(i)
			if (c!=' ' && c!="\t")
				return str.substring(i)
			
		}
		str
	}
}
