/*******************************************************************************
 * Copyright (c) 2012 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.connectors.etrice.internal

import org.eclipse.etrice.core.room.RoomFactory
import org.franca.core.franca.FAnnotationBlock
import org.franca.core.franca.FAnnotation
import org.franca.core.franca.FAnnotationType

/**
 * Helper class for generating comments as part of ROOM models.
 */
class CommentGenerator {

	def static transformComment (String comment) {
		var it = RoomFactory::eINSTANCE.createDocumentation 
		for(line : comment.split("\\n")) {
			text.add(line.replace('\r', ''))
		}
		return it
	}

	def static transformComment (FAnnotationBlock block) {
		var it = RoomFactory::eINSTANCE.createDocumentation 
		for(a : block.elements) {
			text.add(getTextual(a)) 
		}
		return it
	}
		
	def static transformCommentFlat (FAnnotationBlock block) {
		var ret = ''
		for(a : block.elements) {
			if (! ret.empty)
				ret = ret + "\\n"
			ret = ret + getTextual(a)
		}
		return ret
	}
	
	def static String getTextual (FAnnotation annotation) {
		var line = annotation.comment
		if (annotation.type != FAnnotationType::DESCRIPTION) {
			line = annotation.type.literal + ": " + line
		}
		return line
	}

	
}