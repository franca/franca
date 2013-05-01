/*******************************************************************************
 * Copyright (c) 2012 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.connectors.etrice.internal

import org.eclipse.etrice.core.room.ActorClass
import org.eclipse.etrice.core.room.ProtocolClass
import org.eclipse.etrice.core.room.RoomFactory
import org.franca.core.franca.FInterface

import static extension org.franca.connectors.etrice.internal.RoomModelBuilder.*

class AbstractServerGenerator {
	
	private static String SERVER_SUPER_STATE_NAME = "ServerSuperState"
	/**
	 * Generate an abstract server class as base for concrete implementations of the defined interface
	 * TODO timerPC will be used when bug is solved that allows to inherit the timer in the concrete class
	 * TODO also move interfaces into this class
	 */
	def ActorClass createAbstractServerClass (FInterface src, ProtocolClass pc, ProtocolClass timerPC) {
		RoomFactory::eINSTANCE.createActorClass => [
			name = "Abstract" + src.name + "Server"
			^abstract = true
			
			//super state machine
			stateMachine = RoomFactory::eINSTANCE.createStateGraph => [
		
				val serverSuperState = RoomFactory::eINSTANCE.createSimpleState => [
					name = SERVER_SUPER_STATE_NAME
					docu = RoomFactory::eINSTANCE.createDocumentation => [
						text += "This is the main state in this base state machine, used for management of attributes."
					]
				]
				states += serverSuperState
				
				transitions += serverSuperState.terminal.createInitial("initServer") => [
					action = RoomFactory::eINSTANCE.createDetailCode => [
						commands += "System.out.println(\"Super initial Transition triggered.\");"
					]
				]
				
			]
		]
	}
	
	def findSuperStateToExtend(ActorClass anAbstractServer) {
		anAbstractServer.stateMachine.states.findFirst[name.equals(SERVER_SUPER_STATE_NAME)]
	}
}
