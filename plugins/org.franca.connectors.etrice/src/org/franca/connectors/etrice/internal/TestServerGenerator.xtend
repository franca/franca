/*******************************************************************************
 * Copyright (c) 2012 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.connectors.etrice.internal

import org.eclipse.etrice.core.room.RoomFactory
import static extension org.franca.connectors.etrice.internal.RoomModelBuilder.*
import org.franca.core.franca.FInterface
import org.eclipse.etrice.core.room.ProtocolClass
import com.google.inject.Inject

class TestServerGenerator {

	@Inject extension ProtocolClassGenerator
	
	def createServerClass (FInterface src, ProtocolClass pc, ProtocolClass timerPC) {
		val it = RoomFactory::eINSTANCE.createActorClass
		name = src.name + "Server"
		
		val p = pc.createPort("api", false)
		ifPorts.add(p)
		val port = p.createExtPort
		extPorts.add(port)
		val timerSAP = timerPC.createSAP("timer")
		strSAPs.add(timerSAP)
		
		stateMachine = RoomFactory::eINSTANCE.createStateGraph

		val sIdle = RoomFactory::eINSTANCE.createSimpleState
		sIdle.name = "idle"
		stateMachine.states.add(sIdle)
		stateMachine.transitions.add(sIdle.terminal.createInitial)
		
		val timeoutMsg = timerPC.outgoingMessages.findFirst[name.equals("timeout")]
		for(m : src.methods) {
			val s = RoomFactory::eINSTANCE.createSimpleState
			s.name = "do" + m.name.toFirstUpper
			s.entryCode = createDetailCode("timer.startTimeout(1000);")
			val reply = pc.getOutgoingMessage(m)
			s.exitCode = createDetailCode("api." + reply.name + "(true); // TODO: insert real value here")
			stateMachine.states.add(s)

			val msg = pc.incomingMessages.findFirst[name.equals(m.name)]
			stateMachine.transitions.add(
				sIdle.terminal.createTransition(
					s.terminal,
					"start" + m.name.toFirstUpper,
					p.createTrigger(msg)
				)
			)

			stateMachine.transitions.add(
				s.terminal.createTransition(
					sIdle.terminal,
					"done" + m.name.toFirstUpper,
					timerSAP.createTrigger(timeoutMsg)
				)
			)
		}
		
		it
	}
	
}
