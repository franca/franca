/*******************************************************************************
 * Copyright (c) 2018 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.core.dsl.formatting

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
import org.franca.core.franca.FBroadcast
import org.franca.core.franca.FCompoundType
import org.franca.core.franca.FConstantDef
import org.franca.core.franca.FEnumerationType
import org.franca.core.franca.FEnumerator
import org.franca.core.franca.FField
import org.franca.core.franca.FInterface
import org.franca.core.franca.FMapType
import org.franca.core.franca.FMethod
import org.franca.core.franca.FModel
import org.franca.core.franca.FStructType
import org.franca.core.franca.FTypeCollection
import org.franca.core.franca.FTypeDef
import org.franca.core.franca.FUnaryOperation
import org.franca.core.franca.FUnionType
import org.franca.core.franca.FVersion

import static com.google.common.collect.Iterables.*
import static org.franca.core.franca.FrancaPackage.Literals.*

import static extension org.eclipse.xtext.nodemodel.util.NodeModelUtils.*

/** 
 * This class contains a custom configuration for Franca IDL.
 */
@SuppressWarnings("all")
class FrancaIDLFormatter extends AbstractFormatter2 {

	@Inject extension FrancaIDLGrammarAccess ga

	def dispatch void format(FModel it, extension IFormattableDocument document) {
		// TODO: format HiddenRegions around keywords, attributes, cross references, etc.
		imports.forEach[format]
		typeCollections.forEach[format]
		interfaces.forEach[format]
		
		regionFor.feature(FMODEL__NAME).append[newLines=2]

//		regionFor.keyword("{").prepend[newLines = 3]
//		regionFor.keyword("}").append[newLines = 3]
//		append[newLine]
	}

	def dispatch void format(FTypeCollection it, extension IFormattableDocument document) {
		comment?.format
		version?.format
		
		// collect all type collection contents and format them
		val content = concat(constants, types)
		var isFirst = true
		for(item : content.sortBy[findActualNodeFor.offset]) {
			item.format
			if (!isFirst || version!==null)
				item.prepend[highPriority newLines=2]
			isFirst=false
		}
		
		//prepend[newLines=2]
		
		regionFor.keyword("typeCollection").prepend[highPriority newLines=2]
//		interior(
//			regionFor.keyword("{").append[newLine],
//			regionFor.keyword("}"),//.append[newLine],
//			[indent]
//		)

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
		
		// collect all interface contents and format them
		val content = concat(attributes, methods, broadcasts, constants, types)
		var isFirst = true
		for(item : content.sortBy[findActualNodeFor.offset]) {
			item.format
			if (!isFirst || version!==null)
				item.prepend[highPriority newLines=2]
			isFirst=false
		}
		
		//prepend[newLines=2]
		
		regionFor.keyword("interface").prepend[highPriority newLines=2]
//		interior(
//			regionFor.keyword("{").append[newLine],
//			regionFor.keyword("}"),//.append[newLine],
//			[indent]
//		)

		for(pair : regionFor.keywordPairs("{", "}")) {
			interior(
				pair.key.append[newLine],
				pair.value.append[lowPriority setNewLines(1,1,2)],
				[indent]
			)
		}

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
		
		for(pair : regionFor.keywordPairs("{", "}")) {
			interior(
				pair.key.append[newLine].prepend[oneSpace],
				pair.value.append[lowPriority setNewLines(1,1,2)],
				[indent]
			)
		}
		
		inArgs.forEach[format]
		outArgs.forEach[format]
	}

	def dispatch void format(FBroadcast it, extension IFormattableDocument document) {
		comment?.format

		regionFor.keyword("broadcast").append[oneSpace]
		if (selective)
			regionFor.keyword("selective").surround[oneSpace]
		regionFor.keyword("out").append[oneSpace]
		
		for(pair : regionFor.keywordPairs("{", "}")) {
			interior(
				pair.key.append[newLine].prepend[oneSpace],
				pair.value.append[lowPriority setNewLines(1,1,2)],
				[indent]
			)
		}
		
		outArgs.forEach[format]
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


	def private void stdIndent(EObject it, extension IFormattableDocument document) {
		interior(
			regionFor.keyword("{").append[newLine],
			regionFor.keyword("}").append[newLine].prepend[newLine],
			[indent]
		)
	}

	// TODO: implement for FBroadcast, FTypeRef,
	// FDeclaration, FCompoundInitializer, FFieldInitializer,
	// FBracketInitializer, FElementInitializer, FContract, FStateGraph, FState,
	// FTransition, FTrigger, FGuard, FIfStatement, FAssignment, FBlock,
	// FBinaryOperation, FUnaryOperation, FAnnotationBlock, FQualifiedElementRef

	def dispatch void format(FAnnotationBlock fCAnnotationBlock, extension IFormattableDocument document) {
		val open = fCAnnotationBlock.regionFor.keyword(
			ga.FAnnotationBlockAccess.lessThanSignAsteriskAsteriskKeyword_0)
		val close = fCAnnotationBlock.regionFor.keyword(
			ga.FAnnotationBlockAccess.asteriskAsteriskGreaterThanSignKeyword_2)

		interior(open, close)[highPriority indent]
		open.prepend[lowPriority newLine]
		open.append[newLine]
		fCAnnotationBlock.elements.forEach[format]
		close.append[newLine]
		fCAnnotationBlock.append[newLine]
	}

	def dispatch void format(FAnnotation fCAnnotation, extension IFormattableDocument document) {
		// prevent adding new line by suppress adding extra newline formatter call after terminal symbol	
		val region = fCAnnotation.regionFor.ruleCall(
			ga.FAnnotationAccess.rawTextANNOTATION_STRINGTerminalRuleCall_0)

		if (region !== null) {
			if (region.text.contains("\n"))
				region.append[lowPriority newLines=0]
			else
				region.append[lowPriority newLine]

			// pretty print the value "@tag: value"
			fCAnnotation.regionFor.ruleCall(
				ga.FAnnotationAccess.rawTextANNOTATION_STRINGTerminalRuleCall_0)?.append[noSpace]
		} else
			fCAnnotation.append[lowPriority newLine]
	}
}
