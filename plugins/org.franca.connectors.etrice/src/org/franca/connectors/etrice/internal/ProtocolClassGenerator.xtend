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
import com.google.inject.Inject
import org.eclipse.etrice.core.room.ProtocolClass
import org.eclipse.etrice.core.room.ActorClass
import org.eclipse.etrice.core.room.RoomModel
import org.eclipse.etrice.core.room.TransitionPoint

import static extension org.franca.connectors.etrice.internal.CommentGenerator.*
import static extension org.franca.connectors.etrice.internal.RoomModelBuilder.*
import org.franca.core.franca.FContract
import org.franca.core.franca.FState
import java.util.Set
import java.util.Queue
import org.franca.core.franca.FEventOnIf
import org.eclipse.etrice.core.room.SemanticsRule
import java.util.Map

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
		
		// map methods (request/reponse and broadcast)
		val reqresp = src.methods.filter(m | !m.outArgs.empty)
		incomingMessages.addAll(src.methods.map [transformMethod])		
		outgoingMessages.addAll(reqresp.map [transformMethodReply])		
		outgoingMessages.addAll(src.broadcasts.map [transformBroadcast])	
		
		// add protocol semantics for request/reply methods
		if (src.contract == null) {
			semantics = reqresp.createDefaultSemantics
		} else {
			semantics = src.contract.createSemantics
		}
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


	def private createDefaultSemantics (Iterable<FMethod> src) {
		val it = RoomFactory::eINSTANCE.createProtocolSemantics

		// add protocol semantics for request/reply methods
		rules.addAll(src.map[makeSemanticsInOutRule])

		// TODO: add some more semantic rules for attribute behavior

		it
	}

	def private makeSemanticsInOutRule (FMethod src) {
		val it = src.makeSemanticsInRule
		followUps.add(src.makeSemanticsOutRule)
		it
	}

	/*
	 * Create ROOM Protocol semantics from Franca contract.
	 * This is basically a transformation from protocol state machines (PSM)
	 * to legal execution trees (LET).
	 */
	def private createSemantics (FContract contract) {
		val it = RoomFactory::eINSTANCE.createProtocolSemantics
		
		val psm = contract.stateGraph
		var Set<FState> visited = newHashSet
		var Map<FState, SemanticsRule> mapping = newHashMap
		var Queue<FState> queue = newLinkedList(psm.initial)
		while (! queue.empty) {
			val s = queue.poll
			if (visited.contains(s)) {
				if (s != psm.initial) {
					// a cycle which doesn't contain the initial state cannot be transformed to LETs
					val parent = contract.eContainer as FInterface
					println("ERROR: Contract of Franca interface " + parent.name +
						" cannot be transformed to ROOM protocol class semantics spec!")
				}
			} else {
				for(t : s.transitions) {
					val ev = t.trigger.event
					val rule = ev.makeSemanticsRule
					if (mapping.containsKey(s)) {
						mapping.get(s).followUps.add(rule)
					} else {
						rules.add(rule)
					}
					mapping.put(t.to, rule)
					queue.add(t.to)
				}
			}
			visited.add(s)
		}
		it
	}	

	def private SemanticsRule makeSemanticsRule (FEventOnIf ev) {
		if (ev.call!=null) {
			ev.call.makeSemanticsInRule
		} else if (ev.respond!=null) {
			ev.respond.makeSemanticsOutRule
		} else if (ev.signal!=null) {
			ev.signal.makeSemanticsOutRule
		} else {
			// this type of event is not supported yet
			throw new RuntimeException("Franca event type not supported: " + ev.toString)
		}
	}

	def private makeSemanticsInRule (FMethod src) {
		var it = RoomFactory::eINSTANCE.createInSemanticsRule 
		msg = src.transformMethod
		it
	}

	def private makeSemanticsOutRule (FMethod src) {
		val it = RoomFactory::eINSTANCE.createOutSemanticsRule
		msg = src.transformMethodReply
		it
	}
	
	def private makeSemanticsOutRule (FBroadcast src) {
		val it = RoomFactory::eINSTANCE.createOutSemanticsRule
		msg = src.transformBroadcast
		it
	}
	


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
		type = src.type.transformType.toRefableType
		return it
	}


	def getOutgoingMessage (ProtocolClass pc, FMethod m) {
		pc.outgoingMessages.findFirst[name.equals(m.methodReplyName)]
	}
	
	////////////////
	
	// properties/attributes not_supported directly by eTrice - server class must implement extra functionality

	// properties/attributes not_supported directly by eTrice - client class must implement proxy functionality

	def private getterMessageName(FAttribute attr) {
		"getAttribute" + attr.name.toFirstUpper
	}

	def private setterMessageName(FAttribute attr) {
		"setAttribute" + attr.name.toFirstUpper
	}
	
	def private generateGetterMessage(FAttribute attr) {
		RoomFactory::eINSTANCE.createMessage => [
			name = getterMessageName(attr)
			var doc = "Get-method for attribute " + attr.name
			if (attr.comment!=null)
				doc = doc + ": " + attr.comment.transformCommentFlat
			docu = doc.transformComment
		]
	}

	def private generateUpdateMessage(FAttribute attr) {
		RoomFactory::eINSTANCE.createMessage => [
			name = updateMessageName(attr)
			data = generateAttributeMessageParameter(attr)
			var doc = "Update-method for attribute " + attr.name
			if (attr.comment!=null)
				doc = doc + ": " + attr.comment.transformCommentFlat
			docu = doc.transformComment
		]
	}
	
	def private String updateMessageName(FAttribute attr) {
		"update" + attr.name.toFirstUpper
	}
	
	def private generateAttributeMessageParameter(FAttribute attr) {
		RoomFactory::eINSTANCE.createVarDecl => [
			name = "value"
			refType = attr.type.transformType.toRefableType
		]
	}
	
	def private generateSetterMessage(FAttribute attr) {
		RoomFactory::eINSTANCE.createMessage => [
			name = setterMessageName(attr)
			data = generateAttributeMessageParameter(attr)
			var doc = "Set-method for attribute " + attr.name
			if (attr.comment!=null)
				doc = doc + ": " + attr.comment.transformCommentFlat
			docu = doc.transformComment
		]
	}
	
	def public void generateAttributeAccess(ActorClass abstractServer, ActorClass abstractClient, FInterface modelInterface) {
		if (modelInterface.attributes.empty) return;
		
		val TransitionPoint attributeAccessAnchor = RoomFactory::eINSTANCE.createTransitionPoint => [
			name = "AttributeAccessAnchor"
		]
		abstractServer.stateMachine.trPoints += attributeAccessAnchor;

		val TransitionPoint attributeUpdateAnchor = RoomFactory::eINSTANCE.createTransitionPoint => [
			name ="AttributeUpdateAnchor"
		]
		abstractClient.stateMachine.trPoints += attributeUpdateAnchor;
		
		val ProtocolClass attributeAccessInterface = RoomFactory::eINSTANCE.createProtocolClass => [
			name = createUniqueAttributeAccessorInterfaceName(modelInterface)
		]
		(abstractServer.eContainer as RoomModel).protocolClasses += attributeAccessInterface;
		
		val serverPort = createPort(attributeAccessInterface, createUniqueAttributePortName(modelInterface), false);
		abstractServer.interfacePorts += serverPort;
		abstractServer.externalPorts += createExtPort(serverPort)
		val clientPort = createPort(attributeAccessInterface, createUniqueAttributePortName(modelInterface), true);
		abstractClient.interfacePorts += clientPort;
		abstractClient.externalPorts += createExtPort(clientPort)
		
		modelInterface.attributes.forEach[
			abstractServer.attributes += createRoomAttribute(it) => [
				docu = "This attribute is used to store the current value of the corresponding attribute defined in the franca interface.".transformComment
			]
			//TODO: decide whether the attribute is necessary on client when it is not interested in a broadcasted attribute and maybe there is no getter for manual updates
			abstractClient.attributes += createRoomAttribute(it) => [
				docu = "This attribute is used to store the latest update of the corresponding attribute defined in the franca interface.".transformComment
			]
			
			val getterMessage = generateGetterMessage;
			//request
			attributeAccessInterface.incomingMessages += getterMessage;
			val getAction = serverPort.name + "." + updateMessageName + "(this." + name +");"
			abstractServer.stateMachine.transitions += createTransition(
				attributeAccessAnchor.terminal,
				attributeAccessAnchor.terminal,
				"do" + getterMessageName.toFirstUpper,
				createTrigger(serverPort, getterMessage)
			) => [
				action = RoomFactory::eINSTANCE.createDetailCode => [
					lines += getAction
				]
			]
			// update of the attribute on client (sent after getter-Message)
			val updateMessage = generateUpdateMessage;
			attributeAccessInterface.outgoingMessages += updateMessage;
			val updateAction = "this." + name + " = " + "value" + ";"
			abstractClient.stateMachine.transitions += createTransition(
				attributeUpdateAnchor.terminal,
				attributeUpdateAnchor.terminal,
				"do" + updateMessageName.toFirstUpper,
				createTrigger(clientPort, updateMessage)
			) => [
				action = RoomFactory::eINSTANCE.createDetailCode => [
					lines += updateAction
				]
			]
		]
		modelInterface.attributes.filter[!readonly].forEach[
			val setterMessage = generateSetterMessage;
			attributeAccessInterface.incomingMessages += setterMessage;
			val setAction = "this." + name + " = " + "value" + ";"
			abstractServer.stateMachine.transitions += createTransition(
				attributeAccessAnchor.terminal,
				attributeAccessAnchor.terminal,
				"do" + setterMessageName(it).toFirstUpper,
				createTrigger(serverPort, setterMessage) 
			) => [
				action = RoomFactory::eINSTANCE.createDetailCode => [
					lines += setAction
				]
			]
		]
	}
	
	//must not be def create
	def createRoomAttribute(FAttribute attr) {
		RoomFactory::eINSTANCE.createAttribute => [
			name = attr.name
			type = attr.type.transformType.toRefableType
			if (attr.type.isMultiType) size = 3;
		]
	}

	
	def private String createUniqueAttributeAccessorInterfaceName(FInterface modelInterface) {
		//TODO: guarantee that name is unique
		"I" + modelInterface.name.toFirstUpper + "AttributeAccessors"
	}
	
	def private createUniqueAttributePortName(FInterface modelInterface) {
		//TODO: guarantee that name is unique
		"attributePort" + modelInterface.name.toFirstUpper
	}
	
}

