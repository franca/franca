/*******************************************************************************
 * Copyright (c) 2012 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.connectors.etrice.internal

import com.google.inject.Inject
import org.eclipse.etrice.core.room.ActorClass
import org.eclipse.etrice.core.room.ProtocolClass
import org.eclipse.etrice.core.room.RoomFactory
import org.franca.core.franca.FInterface

import static extension org.franca.connectors.etrice.internal.RoomModelBuilder.*

class ConcreteExampleServerGenerator {
	
	@Inject extension AbstractServerGenerator
	@Inject extension ProtocolClassGenerator
	
	/**
	 * concrete Subclass as an sample implementation of the model interface
	 */
	def createExampleServerClass(ActorClass abstractServer, FInterface src, ProtocolClass pc, ProtocolClass timerPC) {
		
		val concreteServer = RoomFactory::eINSTANCE.createActorClass
		concreteServer.name = src.name + "ExampleServer"
		concreteServer.base = abstractServer
		
		//The following ports should be declared in the base actor but because of a bug the behavior wont recognize them
		//--> TODO move up, once the bug has been solved
		val messageAPI = pc.createPort("messageAPI", false)
		concreteServer.ifPorts += messageAPI
		val port = messageAPI.createExtPort
		concreteServer.extPorts += port
		val timerSAP = timerPC.createSAP("timer")
		concreteServer.strSAPs += timerSAP
		//<--
		
		//server behavior as sub state machine
		concreteServer.stateMachine = RoomFactory::eINSTANCE.createStateGraph
		
		val refinedServerSuperState = RoomFactory::eINSTANCE.createRefinedState
		refinedServerSuperState.setTarget(findSuperStateToExtend(abstractServer))
		concreteServer.stateMachine.states += refinedServerSuperState
		
		refinedServerSuperState.subgraph = RoomFactory::eINSTANCE.createStateGraph
		val subStateGraph = refinedServerSuperState.subgraph
		
		val sIdle = RoomFactory::eINSTANCE.createSimpleState
		sIdle.name = "idle"
		subStateGraph.states += sIdle
		subStateGraph.transitions += sIdle.terminal.createInitial("initToIdle") => [
			action = RoomFactory::eINSTANCE.createDetailCode => [
				commands += "System.out.println(\"Transition initToIdle triggered.\");"
			]			
		]
		
		val timeoutMsg = timerPC.outgoingMessages.findFirst[name.equals("timeout")]
		for(m : src.methods) {
			val s = RoomFactory::eINSTANCE.createSimpleState
			s.name = "do" + m.name.toFirstUpper
			s.entryCode = createDetailCode("timer.startTimeout(1000);")
			val reply = pc.getOutgoingMessage(m)
			s.exitCode = createDetailCode("messageAPI." + reply.name + "(true); // TODO: insert real value here")
			subStateGraph.states += s

			val msg = pc.incomingMessages.findFirst[name.equals(m.name)]
			subStateGraph.transitions += 
				sIdle.terminal.createTransition(
					s.terminal,
					"start" + m.name.toFirstUpper,
					messageAPI.createTrigger(msg)
				)

			subStateGraph.transitions += 
				s.terminal.createTransition(
					sIdle.terminal,
					"done" + m.name.toFirstUpper,
					timerSAP.createTrigger(timeoutMsg)
				)
		}
		
		concreteServer
	}
}
