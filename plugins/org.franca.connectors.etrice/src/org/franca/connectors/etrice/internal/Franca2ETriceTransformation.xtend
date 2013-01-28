/*******************************************************************************
 * Copyright (c) 2012 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.connectors.etrice.internal

import com.google.inject.Inject
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.etrice.core.room.ActorRef
import org.eclipse.etrice.core.room.ProtocolClass
import org.eclipse.etrice.core.room.RoomFactory
import org.eclipse.etrice.core.room.RoomModel
import org.eclipse.etrice.core.room.SubSystemClass
import org.franca.core.franca.FInterface
import org.franca.core.franca.FModel

import static extension org.franca.connectors.etrice.internal.CommentGenerator.*
import static extension org.franca.connectors.etrice.internal.RoomModelBuilder.*

/**
 * The top-level class for transformation of Franca models (*.fidl) to 
 * ROOM models (i.e., for using them with eTrice).
 * 
 * @author: Klaus Birken (itemis)
 */
class Franca2ETriceTransformation {

	@Inject extension TypeGenerator
	@Inject extension ProtocolClassGenerator
	@Inject extension TestClientGenerator
	@Inject extension TestServerGenerator
	@Inject ModelLib modellib

	def create RoomFactory::eINSTANCE.createRoomModel transform (FModel src, String uriModelLib, ResourceSet resourceSet) {
		name = src.name
		
		var doc = "Generated from Franca IDL model " + src.name + " by Franca2ETriceTransformation."
		docu = doc.transformComment 

		// load ROOM modellib
		val importLibs = modellib.init(uriModelLib, resourceSet)
		imports.addAll(importLibs)
		
		// create the environment for all test units
		val sys = createSubSystem
		val timerPC = modellib.getPTimerProtocol
		val tac = modellib.getTimingServiceActor
		val timingRef = tac.getRef("timingService")
		sys.actorRefs.add(timingRef)

		// create everything needed for each Franca interface
		for (i : src.interfaces) {
			// transform each interface into one ProtocolClass
			val pc = i.transformInterface
			protocolClasses.add(pc)
				
			// transform each interface into one application ActorClass
			createInterfaceTestunit(i, pc, sys, timingRef, timerPC)
		}
			
		// final step: get new data types from TypeGenerator
		primitiveTypes.addAll(newPrimitiveTypes)
		dataClasses.addAll(newDataClasses)
	}

	
	/**
	 * Create a LogicalSystem and a SubSystem which will be the environment
	 * for the testunits.
	 */
	def private createSubSystem (RoomModel it) {
		val logical = RoomFactory::eINSTANCE.createLogicalSystem
		logical.name = "System"
		systems.add(logical)
		
		val subsystem = RoomFactory::eINSTANCE.createSubSystemClass
		subsystem.name = "SubSystem"
		logical.subSystems.add(subsystem.getRef("subsystem"))
		subSystemClasses.add(subsystem)
		subsystem
	}


	/**
	 * Create a test unit, consisting of a client and a server for the Franca interface.
	 * the client will call one method from the Franca interface after another, waiting 
	 * for the response from the server. The server will react to each method call with
	 * a proper response after a predefined timeout.
	 */
	def private createInterfaceTestunit (RoomModel it, FInterface src, ProtocolClass pc, SubSystemClass sys, ActorRef timingRef, ProtocolClass timerPC) {
		
		// create an "application" ActorClass which will contain the whole test unit
		val app = src.createApplicationActor
		val appRef = app.getRef(app.name.toFirstLower)
		sys.actorRefs.add(appRef)
		actorClasses.add(app)
		
		// create server and client class
		val server = src.createServerClass(pc, timerPC)
		val client = src.createClientClass(pc, timerPC)
		actorClasses.add(server)
		actorClasses.add(client)
		
		// create layer connection in order to access the Timer service
		val layerConn = RoomFactory::eINSTANCE.createLayerConnection
		layerConn.from = appRef.createSAPoint
		layerConn.to = timingRef.createSPPoint(modellib.getTimerSPPRef)
		sys.connections.add(layerConn)

		// connect client and server via binding
		val clientRef = client.getRef("client")
		val serverRef = server.getRef("server")
		app.actorRefs.add(clientRef)		
		app.actorRefs.add(serverRef)		
		val b = RoomFactory::eINSTANCE.createBinding
		b.endpoint1 = clientRef.createEndPoint(client.ifPorts.get(0))
		b.endpoint2 = serverRef.createEndPoint(server.ifPorts.get(0))
		app.bindings.add(b)
	}

	
	def private getRef (SubSystemClass src, String name) {
		val it = RoomFactory::eINSTANCE.createSubSystemRef
		it.name = name
		it.type = src
		it
	}
	
	def create RoomFactory::eINSTANCE.createActorClass createApplicationActor (FInterface src) {
		name = src.name + "Application"
	}

	
}