/*******************************************************************************
 * Copyright (c) 2018 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.core.dsl.formatting2

import com.google.inject.Inject
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.formatting2.AbstractFormatter2
import org.eclipse.xtext.formatting2.IFormattableDocument
import org.franca.core.dsl.services.FrancaIDLGrammarAccess
import org.franca.core.franca.FAnnotation
import org.franca.core.franca.FAnnotationBlock
import org.franca.core.franca.FArgument
import org.franca.core.franca.FArrayType
import org.franca.core.franca.FAttribute
import org.franca.core.franca.FBinaryOperation
import org.franca.core.franca.FBracketInitializer
import org.franca.core.franca.FBroadcast
import org.franca.core.franca.FCompoundInitializer
import org.franca.core.franca.FCompoundType
import org.franca.core.franca.FConstantDef
import org.franca.core.franca.FContract
import org.franca.core.franca.FElementInitializer
import org.franca.core.franca.FEnumerationType
import org.franca.core.franca.FEnumerator
import org.franca.core.franca.FEventOnIf
import org.franca.core.franca.FField
import org.franca.core.franca.FFieldInitializer
import org.franca.core.franca.FInterface
import org.franca.core.franca.FMapType
import org.franca.core.franca.FMethod
import org.franca.core.franca.FModel
import org.franca.core.franca.FState
import org.franca.core.franca.FStateGraph
import org.franca.core.franca.FStructType
import org.franca.core.franca.FTransition
import org.franca.core.franca.FTrigger
import org.franca.core.franca.FTypeCollection
import org.franca.core.franca.FTypeDef
import org.franca.core.franca.FUnaryOperation
import org.franca.core.franca.FUnionType
import org.franca.core.franca.FVersion

import static com.google.common.collect.Iterables.*
import static org.franca.core.franca.FrancaPackage.Literals.*

import static extension org.eclipse.xtext.nodemodel.util.NodeModelUtils.*

/** 
 * Custom formatter for Franca IDL.</p>
 */
@SuppressWarnings("all")
class FrancaIDLFormatter extends AbstractFormatter2 {

	@Inject extension FrancaIDLGrammarAccess ga

	// TODO: implement for FQualifiedElementRef, FTypeRef, FDeclaration, FGuard, FIfStatement, FAssignment, FBlock

	def dispatch void format(FModel it, extension IFormattableDocument document) {
		imports.forEach[format]
		
		regionFor.feature(FMODEL__NAME).append[newLines=2]

		// collect all type collection contents and format them
		val content = concat(typeCollections, interfaces)
		var isLast = true
		for(item : content.sortBy[findActualNodeFor?.offset].reverse) {
			item.format
			if (!isLast)
				item.append[highPriority newLines=2]
			isLast = false
		}
	}

	def dispatch void format(FTypeCollection it, extension IFormattableDocument document) {
		comment?.format
		version?.format
		
		regionFor.keyword("typeCollection").append[oneSpace]

		// collect all type collection contents and format them
		val content = concat(constants, types)
		var isFirst = true
		for(item : content.sortBy[findActualNodeFor?.offset]) {
			item.format
			if (!isFirst || version!==null)
				item.prepend[highPriority newLines=2]
			isFirst=false
		}

		for(pair : regionFor.keywordPairs("{", "}")) {
			interior(
				pair.key.append[newLine],
				pair.value.append[lowPriority setNewLines(1,1,2)],
				[indent]
			)
		}
	}

	def dispatch void format(FInterface it, extension IFormattableDocument document) {
		version.format

		regionFor.keyword("interface").append[oneSpace]
		if (base!==null)
			regionFor.keyword("extends").surround[oneSpace]
		
		// collect all interface contents and format them
		val content = concat(attributes, methods, broadcasts, constants, types)
		var isFirst = true
		for(item : content.sortBy[findActualNodeFor?.offset]) {
			item.format
			if (!isFirst || version!==null)
				item.prepend[highPriority newLines=2]
			isFirst=false
		}

		for(pair : regionFor.keywordPairs("{", "}")) {
			interior(
				pair.key.append[newLine],
				pair.value.append[lowPriority setNewLines(1,1,2)],
				[indent]
			)
		}

		contract?.format
	}

	def dispatch void format(FVersion it, extension IFormattableDocument document) {
		stdIndent(document)
		regionFor.keyword("minor").prepend[newLine]
	}

	def dispatch void format(FConstantDef it, extension IFormattableDocument document) {
		comment?.format
		
		regionFor.keyword("const").append[oneSpace]
		regionFor.feature(FMODEL_ELEMENT__NAME).prepend[oneSpace]
		regionFor.keyword("=").surround[oneSpace]
		
		rhs.format
		
		append[lowPriority setNewLines(1,1,2)]
	}

	def dispatch void format(FArrayType it, extension IFormattableDocument document) {
		comment?.format
		
		regionFor.keyword("array").append[oneSpace]
		regionFor.keyword("of").surround[oneSpace]
		
		append[lowPriority setNewLines(1,1,2)]
	}

	def dispatch void format(FEnumerationType it, extension IFormattableDocument document) {
		comment?.format
		
		regionFor.keyword("enumeration").append[oneSpace]
		interior(
			regionFor.keyword("{").prepend[oneSpace].append[newLine],
			regionFor.keyword("}"),
			[indent]
		)
		
		enumerators.forEach[format]
		
		append[lowPriority setNewLines(1,1,2)]
	}

	def dispatch void format(FEnumerator it, extension IFormattableDocument document) {
		comment?.format
		
		if (value!==null) {
			value.format
			regionFor.keyword("=").surround[oneSpace]
		}
		
		append[newLine]
	}
	
	def dispatch void format(FStructType it, extension IFormattableDocument document) {
		comment?.format
		
		regionFor.keyword("struct").append[oneSpace]
		if (base!==null)
			regionFor.keyword("extends").surround[oneSpace]

		if (polymorphic)
			regionFor.keyword("polymorphic").surround[oneSpace]

		formatCompound(document)
	}
		
	def dispatch void format(FUnionType it, extension IFormattableDocument document) {
		comment?.format
		
		regionFor.keyword("union").append[oneSpace]
		formatCompound(document)
	}

	def void formatCompound(FCompoundType it, extension IFormattableDocument document) {
		if (elements.empty)
			regionFor.keyword("{").prepend[oneSpace].append[oneSpace]
		else{
			interior(
				regionFor.keyword("{").prepend[oneSpace].append[newLine],
				regionFor.keyword("}"),
				[indent]
			)
			
			elements.forEach[format]
		}

		append[newLine]
	}
	
	def dispatch void format(FField it, extension IFormattableDocument document) {
		comment?.format
		regionFor.feature(FMODEL_ELEMENT__NAME).prepend[oneSpace]
		append[newLine]
	}
	
	def dispatch void format(FMapType it, extension IFormattableDocument document) {
		comment?.format
		
		regionFor.keyword("map").append[oneSpace]
		regionFor.keyword("{").surround[oneSpace]
		regionFor.keyword("to").surround[oneSpace]
		regionFor.keyword("}").surround[oneSpace]
		
		append[lowPriority setNewLines(1,1,2)]
	}

	def dispatch void format(FTypeDef it, extension IFormattableDocument document) {
		comment?.format
		
		regionFor.keyword("typedef").append[oneSpace]
		regionFor.keyword("is").surround[oneSpace]
		
		append[lowPriority setNewLines(1,1,2)]
	}

	def dispatch void format(FAttribute it, extension IFormattableDocument document) {
		comment?.format
		
		regionFor.keyword("attribute").append[oneSpace]
		regionFor.feature(FMODEL_ELEMENT__NAME).prepend[oneSpace]
		
		if (readonly)
			regionFor.keyword("readonly").prepend[oneSpace]
		if (noRead)
			regionFor.keyword("noRead").prepend[oneSpace]
		if (noSubscriptions)
			regionFor.keyword("noSubscriptions").prepend[oneSpace]
			
	}

	def dispatch void format(FMethod it, extension IFormattableDocument document) {
		comment?.format

		regionFor.keyword("method").append[oneSpace]
		if (fireAndForget)
			regionFor.keyword("fireAndForget").surround[oneSpace]

		regionFor.keyword("in").append[oneSpace]
		regionFor.keyword("out").append[oneSpace]
		if (inArgs.empty && outArgs.empty && errors===null && errorEnum===null) {
			regionFor.keyword("{").prepend[oneSpace].append[oneSpace]
			regionFor.keyword("}").prepend[oneSpace]
			append[lowPriority setNewLines(1,1,2)]
		} else {
			for(pair : regionFor.keywordPairs("{", "}")) {
				interior(
					pair.key.append[newLine].prepend[oneSpace],
					pair.value.append[lowPriority setNewLines(1,1,2)],
					[indent]
				)
			}
	
			inArgs.forEach[format]
			outArgs.forEach[format]

			if (errors!==null || errorEnum!==null)
				regionFor.keyword("error").append[oneSpace]
			if (errors !== null)
				errors.format
			if (errorEnum !== null && errors===null) {
				regionFor.feature(FMETHOD__ERROR_ENUM).append[newLine]
			}
		}
	}

	def dispatch void format(FBroadcast it, extension IFormattableDocument document) {
		comment?.format

		regionFor.keyword("broadcast").append[oneSpace]
		if (selective)
			regionFor.keyword("selective").surround[oneSpace]

		regionFor.keyword("out").append[oneSpace]
		if (outArgs.empty) {
			regionFor.keyword("{").prepend[oneSpace].append[oneSpace]
			regionFor.keyword("}").prepend[oneSpace]
			append[lowPriority setNewLines(1,1,2)]
		} else {
			for(pair : regionFor.keywordPairs("{", "}")) {
				interior(
					pair.key.append[newLine].prepend[oneSpace],
					pair.value.append[lowPriority setNewLines(1,1,2)],
					[indent]
				)
			}
			
			outArgs.forEach[format]
		}
	}

	def dispatch void format(FArgument it, extension IFormattableDocument document) {
		comment?.format
		regionFor.feature(FMODEL_ELEMENT__NAME).prepend[oneSpace]
		append[newLine]
	}

	def dispatch void format(FUnaryOperation it, extension IFormattableDocument document) {
		operand.format
		regionFor.feature(FOPERATION__OP).append[noSpace]
	}

	def dispatch void format(FBinaryOperation it, extension IFormattableDocument document) {
		regionFor.feature(FOPERATION__OP).surround[oneSpace]
		left.format
		right.format
	}

	def dispatch void format(FBracketInitializer it, extension IFormattableDocument document) {
		regionFor.keyword("[").append[oneSpace]
		regionFor.keyword("]").prepend[oneSpace]

		for(comma : regionFor.keywords(",")) {
			comma.prepend[noSpace].append[oneSpace]
		}
		
		elements.forEach[format]
	}

	def dispatch void format(FElementInitializer it, extension IFormattableDocument document) {
		first.format
		second?.format
	}

	def dispatch void format(FCompoundInitializer it, extension IFormattableDocument document) {
		interior(
			regionFor.keyword("{").prepend[oneSpace].append[newLine],
			regionFor.keyword("}").prepend[newLine].append[newLine],
			[indent]
		)

		for(comma : regionFor.keywords(",")) {
			comma.prepend[noSpace].append[newLine]
		}

		elements.forEach[format]
	}

	def dispatch void format(FFieldInitializer it, extension IFormattableDocument document) {
		regionFor.keyword(":").prepend[oneSpace].append[oneSpace]
		value.format
	}

	def dispatch void format(FContract it, extension IFormattableDocument document) {
		regionFor.keyword("contract").prepend[newLines=2].append[oneSpace]

		regionFor.keyword("PSM").prepend[newLine].append[oneSpace]
		stdIndent(document)
		
		stateGraph.format
	}
	
	def dispatch void format(FStateGraph it, extension IFormattableDocument document) {
		regionFor.keyword("initial").append[oneSpace]
		regionFor.feature(FSTATE_GRAPH__INITIAL).append[newLine]
		
		stdIndent(document)
		states.forEach[format]
	}

	def dispatch void format(FState it, extension IFormattableDocument document) {
		regionFor.keyword("state").append[oneSpace]

		stdIndent(document)
		transitions.forEach[format]
	}

	def dispatch void format(FTransition it, extension IFormattableDocument document) {
		regionFor.keyword("on").append[oneSpace]
		//stdIndent(document)
		regionFor.keyword("->").surround[oneSpace]
		trigger.format
		guard?.format
		append[newLine]
	}
	
	def dispatch void format(FTrigger it, extension IFormattableDocument document) {
		event.format
	}
	
	def dispatch void format(FEventOnIf it, extension IFormattableDocument document) {
		regionFor.keyword("call").append[oneSpace]
		regionFor.keyword("respond").append[oneSpace]
		regionFor.keyword("error").append[oneSpace]
		regionFor.keyword("signal").append[oneSpace]
		regionFor.keyword("set").append[oneSpace]
		regionFor.keyword("update").append[oneSpace]
	}
	
	def private void stdIndent(EObject it, extension IFormattableDocument document) {
		interior(
			regionFor.keyword("{").append[newLine],
			regionFor.keyword("}").append[newLine].prepend[newLine],
			[indent]
		)
	}

	def dispatch void format(FAnnotationBlock it, extension IFormattableDocument document) {
		val open = regionFor.keyword("<**")
		val close = regionFor.keyword("**>")

		interior(open, close)[highPriority indent]
		//open.prepend[lowPriority newLine]
		open.append[newLine]
		elements.forEach[format]
		close.append[newLine]
		append[newLine]
	}

	def dispatch void format(FAnnotation it, extension IFormattableDocument document) {
		// prevent adding new line by suppress adding extra newline formatter call after terminal symbol	
		val rc = ga.FAnnotationAccess.rawTextANNOTATION_STRINGTerminalRuleCall_0
		val region = regionFor.ruleCall(rc)

		if (region !== null) {
			region.append[lowPriority newLine]

			// pretty print the value "@tag: value"
			regionFor.ruleCall(rc)?.append[noSpace]
		} else
			append[lowPriority newLine]
	}
}
