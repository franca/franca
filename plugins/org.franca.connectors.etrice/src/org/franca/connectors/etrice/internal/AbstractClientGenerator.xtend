/*******************************************************************************
 * Copyright (c) 2012 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.connectors.etrice.internal

import org.franca.core.franca.FInterface
import org.eclipse.etrice.core.room.ProtocolClass
import org.eclipse.etrice.core.room.RoomFactory

import static extension org.franca.connectors.etrice.internal.RoomModelBuilder.*
import org.eclipse.etrice.core.room.ActorClass

class AbstractClientGenerator {

	private static String CLIENT_SUPER_STATE_NAME = "ClientSuperState"

	def createAbstractClientClass (FInterface src, ProtocolClass pc, ProtocolClass timerPC) {
		RoomFactory::eINSTANCE.createActorClass => [
			name = "Abstract" + src.name + "Client"
			^abstract = true
			
			//super state machine
			stateMachine = RoomFactory::eINSTANCE.createStateGraph => [
		
				val serverSuperState = RoomFactory::eINSTANCE.createSimpleState => [
					name = CLIENT_SUPER_STATE_NAME
					docu = RoomFactory::eINSTANCE.createDocumentation => [
						text += "This is the main state in this base state machine, used for handling of attribute updates."
					]
				]
				states += serverSuperState
				
				transitions += serverSuperState.terminal.createInitial("initClient") => [
//					action = RoomFactory::eINSTANCE.createDetailCode => [
//						commands += ""
//					]
				]
				
			]
		]
	}
	
	def findSuperStateToExtend(ActorClass anAbstractClient) {
		anAbstractClient.stateMachine.states.findFirst[name.equals(CLIENT_SUPER_STATE_NAME)]
	}
}
