/*******************************************************************************
 * Copyright (c) 2012 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.connectors.etrice.internal

import org.eclipse.etrice.core.room.TransitionTerminal
import org.eclipse.etrice.core.room.Trigger
import org.eclipse.etrice.core.room.RoomFactory
import org.eclipse.etrice.core.room.ProtocolClass
import org.eclipse.etrice.core.room.Port
import org.eclipse.etrice.core.room.ActorClass
import org.eclipse.etrice.core.room.ActorRef
import org.eclipse.etrice.core.room.InterfaceItem
import org.eclipse.etrice.core.room.Message
import org.eclipse.etrice.core.room.DataType
import org.eclipse.etrice.core.room.State
import org.eclipse.etrice.core.room.SPPRef

class RoomModelBuilder {
	
	
	def static createImport (String namespace, String uri) {
		val it = RoomFactory::eINSTANCE.createImport
		importedNamespace = namespace
		importURI = uri
		it
	}

	def static createPort (ProtocolClass pc, String name, boolean conjugated) {
		val it = RoomFactory::eINSTANCE.createPort
		it.name = name
		it.conjugated = conjugated
		it.protocol = pc
		it
	}
	
	def static createExtPort (Port port) {
		val it = RoomFactory::eINSTANCE.createExternalPort
		ifport = port
		it		
	}

	def static createSAP (ProtocolClass pc, String name) {
		val it = RoomFactory::eINSTANCE.createSAPRef
		it.name = name
		it.protocol = pc
		it
	}

	def static createSPPoint (ActorRef aref, SPPRef sppref) {
		val it = RoomFactory::eINSTANCE.createSPPoint
		ref = aref
		service = sppref
		it
	}
	
	def static createSAPoint (ActorRef aref) {
		val it = RoomFactory::eINSTANCE.createRefSAPoint
		ref = aref
		it
	}
	

	def static createTransition (TransitionTerminal from,
		TransitionTerminal to, String name, Trigger trigger
	) {
		val tr = RoomFactory::eINSTANCE.createTriggeredTransition
		tr.name = name
		tr.from = from
		tr.to = to
		tr.triggers.add(trigger)
		tr		
	}
	
	def static createTrigger (InterfaceItem from, Message what) {
		val msg = RoomFactory::eINSTANCE.createMessageFromIf
		msg.from = from
		msg.message = what
		val it = RoomFactory::eINSTANCE.createTrigger
		msgFromIfPairs.add(msg)
		it
	}

	def static createInitial (TransitionTerminal to) {
		val tr = RoomFactory::eINSTANCE.createInitialTransition
		tr.name = "init"
		tr.to = to
		tr
	}
	
	def static getRef (ActorClass ac, String name) {
		val it = RoomFactory::eINSTANCE.createActorRef
		it.name = name
		it.type = ac
		it.size = 1
		it
	}

	def static createEndPoint (ActorRef aref, Port port) {
		val it = RoomFactory::eINSTANCE.createBindingEndPoint
		it.actorRef = aref
		it.port = port
		it
	}

	// TODO: what is a RefableType, what does the 'ref' flag mean?
	def static toRefableType (DataType roomtype) {
		val it = RoomFactory::eINSTANCE.createRefableType 
		type = roomtype
		ref = false
		it
	}

	def static getTerminal (State state) {
		val it = RoomFactory::eINSTANCE.createStateTerminal
		it.state = state
		it
	}	
	
	def static createDetailCode (String code) {
		val it = RoomFactory::eINSTANCE.createDetailCode
		commands.add(code)
		it
	}
	
	
}