/*******************************************************************************
 * Copyright (c) 2012 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.connectors.etrice.internal

import org.eclipse.etrice.core.room.RoomFactory
import org.franca.core.franca.FInterface

import org.franca.core.franca.FAttribute
import org.franca.core.franca.FMethod
import org.franca.core.franca.FBroadcast
import org.franca.core.franca.FArgument

import static extension org.franca.connectors.etrice.internal.CommentGenerator.*
import static extension org.franca.connectors.etrice.internal.RoomModelBuilder.*
import com.google.inject.Inject
import org.eclipse.etrice.core.room.ProtocolClass

class ProtocolClassGenerator {

	@Inject extension TypeGenerator

	def create RoomFactory::eINSTANCE.createProtocolClass transformInterface (FInterface src) {
		// map metadata of interface
		name = src.name
		// TODO not_supported: interface version 
//		if (src.version!=null)
//			version = "" + src.version.major + "." + src.version.minor
		if (src.comment!=null)
			docu = src.comment.transformComment
		
		// map attributes
		incomingMessages.addAll(src.attributes.map [transformAttributeSet])
		outgoingMessages.addAll(src.attributes.map [transformAttributeUpdate])
		
		// map methods (request/reponse and broadcast)
		val reqresp = src.methods.filter(m | !m.outArgs.empty)
		incomingMessages.addAll(src.methods.map [transformMethod])		
		outgoingMessages.addAll(reqresp.map [transformMethodReply])		
		outgoingMessages.addAll(src.broadcasts.map [transformBroadcast])	
		
		// add protocol semantics for request/reply methods
		// TODO
//		semantics = reqresp.transformSemantics
	}


	// properties/attributes not_supported directly by eTrice - server class must implement extra functionality
	def private create RoomFactory::eINSTANCE.createMessage transformAttributeSet (FAttribute src) {
		name = "setAttribute" + src.name.toFirstUpper

		var doc = "Set-method for attribute " + src.name
		if (src.comment!=null)
			doc = doc + ": " + src.comment.transformCommentFlat
		docu = doc.transformComment

		data = RoomFactory::eINSTANCE.createVarDecl
		data.name = src.name;
		data.refType = src.type.transformType.toRefableType
	}

	// properties/attributes not_supported directly by eTrice - client class must implement proxy functionality
	def private create RoomFactory::eINSTANCE.createMessage transformAttributeUpdate (FAttribute src) {
		name = "updateAttribute" + src.name.toFirstUpper
		
		var doc = "Update-method for attribute " + src.name
		if (src.comment!=null)
			doc = doc + ": " + src.comment.transformCommentFlat
		docu = doc.transformComment
		
		data = RoomFactory::eINSTANCE.createVarDecl
		data.name = src.name;
		data.refType = src.type.transformType.toRefableType
	}


	def private create RoomFactory::eINSTANCE.createMessage transformMethod (FMethod src) {
		name = src.name
		if (src.comment!=null)
			docu = src.comment.transformComment
		if (src.inArgs.size==1) {
			data = src.inArgs.get(0).transformArg
		}
		if (src.inArgs.size>1) {
			data = src.inArgs.transformMultiArg(name)
		}
	}

	def private create RoomFactory::eINSTANCE.createMessage transformMethodReply (FMethod src) {
		name = src.methodReplyName
		docu = transformComment("reply for " + src.name)
		if (src.outArgs.size==1) {
			data = src.outArgs.get(0).transformArg
		}
		if (src.outArgs.size>1) {
			data = src.outArgs.transformMultiArg(name)
		}
	}

	def private getMethodReplyName (FMethod it) {
		"reply" + name.toFirstUpper
	}

	def private create RoomFactory::eINSTANCE.createMessage transformBroadcast (FBroadcast src) {
		name = src.name
		if (src.comment!=null)
			docu = src.comment.transformComment
		if (src.outArgs.size==1) {
			data = src.outArgs.get(0).transformArg
		}
		if (src.outArgs.size>1) {
			data = src.outArgs.transformMultiArg(name)
		}
	}



//	def create RoomFactory::eINSTANCE.createProtocolSemantics transformSemantics (Iterable<FMethod> src) {
//		rules.addAll(src.map [createSemanticsInRule])
//	}
//	
//	def createSemanticsInRule (FMethod src) {
//		var it = RoomFactory::eINSTANCE.createSemanticsInRule 
//		msg = src.transformMethod
//		followUps.add(src.createSemanticsOutRule)
//		return it
//	}
//
//	def create RoomFactory::eINSTANCE.createSemanticsOutRule createSemanticsOutRule (FMethod src) {
//		msg = src.transformMethodReply
//	}
	
	

	def private transformArg (FArgument src) {
		var it = RoomFactory::eINSTANCE.createVarDecl 
		name = src.name;
		refType = src.type.transformType.toRefableType
		return it
	}
	
	def private transformMultiArg (Iterable<FArgument> args, String method) {
		var it = RoomFactory::eINSTANCE.createVarDecl
		name = method;
		refType = args.transformMultiArgType(method).toRefableType
		return it
	}

	
	def private transformMultiArgType (Iterable<FArgument> args, String method) {
		args.createMultiArgDC(method)
	}
	
	def private create RoomFactory::eINSTANCE.createDataClass createMultiArgDC (Iterable<FArgument> args, String method) {
		name = method.getDataClassName("Args")
		docu = transformComment("argument struct for " + method)
		attributes.addAll(args.map [transformArg2Attr])

		newDataClasses.add(it)
	}
	
	
	def private transformArg2Attr (FArgument src) {
		var it = RoomFactory::eINSTANCE.createAttribute
		name = src.name
		//size = 1
		refType = src.type.transformType.toRefableType
		return it
	}


	def getOutgoingMessage (ProtocolClass pc, FMethod m) {
		pc.outgoingMessages.findFirst[name.equals(m.methodReplyName)]
	}
	
}

