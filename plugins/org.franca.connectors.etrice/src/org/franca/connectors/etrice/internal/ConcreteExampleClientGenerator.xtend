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
import org.eclipse.etrice.core.room.SimpleState
import org.eclipse.etrice.core.room.Message
import org.eclipse.etrice.core.room.PrimitiveType
import org.eclipse.etrice.core.room.DataClass
import org.eclipse.etrice.core.room.DataType
import com.google.inject.Inject
import org.eclipse.etrice.core.room.ActorClass

import static extension org.franca.connectors.etrice.internal.RoomModelBuilder.*

class ConcreteExampleClientGenerator {

	@Inject extension AbstractClientGenerator
	@Inject extension ProtocolClassGenerator
	
	def createExampleClientClass (ActorClass abstractClient, FInterface src, ProtocolClass pc, ProtocolClass timerPC) {
		val it = RoomFactory::eINSTANCE.createActorClass
		name = src.name + "ExampleClient"
		base = abstractClient

		val p = pc.createPort("messageAPI", true)
		ifPorts.add(p)
		val port = p.createExtPort
		extPorts.add(port)
		
//		val timerSAP = timerPC.createSAP("timer")
//		strSAPs.add(timerSAP)
		
		stateMachine = RoomFactory::eINSTANCE.createStateGraph
		
		val refinedClientSuperState = RoomFactory::eINSTANCE.createRefinedState
		refinedClientSuperState.setTarget(findSuperStateToExtend(abstractClient))
		stateMachine.states += refinedClientSuperState
		
		refinedClientSuperState.subgraph = RoomFactory::eINSTANCE.createStateGraph
		val stateMachine = refinedClientSuperState.subgraph //hides it.stateMachine!

		var SimpleState lastState = null
		var Message readyMsg = null
		for(m : src.methods) {
			val s = RoomFactory::eINSTANCE.createSimpleState
			s.name = "waitingFor" + m.name.toFirstUpper
			val msg = pc.incomingMessages.findFirst[name.equals(m.name)]
			val type = msg.data?.refType?.type
			s.entryCode = createDetailCode(
				"messageAPI." + m.name + "(" +
				(if (type!=null) type.createDefaultStr else "") +
				");"
			)
			stateMachine.states.add(s)

			if (lastState==null) {
				stateMachine.transitions.add(s.terminal.createInitial)
			} else {
				stateMachine.transitions.add(
					lastState.terminal.createTransition(
						s.terminal,
						"done" + src.methods.indexOf(m),
						p.createTrigger(readyMsg)
					)
				)
			}
			lastState = s
			readyMsg = pc.getOutgoingMessage(m)
		}

		val sReady = RoomFactory::eINSTANCE.createSimpleState
		sReady.name = "ready"
		stateMachine.states.add(sReady)
		if (lastState==null) {
			stateMachine.transitions.add(
				sReady.terminal.createInitial
			)
		} else {
			stateMachine.transitions.add(
				lastState.terminal.createTransition(
					sReady.terminal,
					"done",
					p.createTrigger(readyMsg)
				)
			)
		}
		
		it
	}


	def private dispatch createDefaultStr (PrimitiveType it) {
		defaultValueLiteral
	}
	
	def private dispatch createDefaultStr (DataClass it) {
		val sb = new StringBuilder
		sb.append("new " + name + "(")
		var sep = ''
		for(a : attributes) {
			sb.append(sep + a.refType.type.createDefaultStr)
			sep = ', '
		}
		sb.append(")")
		sb.toString
		
	}

	def private dispatch createDefaultStr (DataType it) {
		""
	}
	
}
