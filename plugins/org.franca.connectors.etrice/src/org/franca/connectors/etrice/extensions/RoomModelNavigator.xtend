package org.franca.connectors.etrice.extensions

import org.eclipse.etrice.core.room.ActorClass
import org.eclipse.etrice.core.room.Port
import org.eclipse.etrice.core.room.GeneralProtocolClass
import org.eclipse.etrice.core.room.Message
import org.eclipse.etrice.core.room.ProtocolClass
import org.eclipse.etrice.core.room.CompoundProtocolClass

class RoomModelNavigator {
	
	def Iterable<Port> getAllVisibleIfPorts(ActorClass it) {
		if (base == null) return ifPorts;
		
		return ifPorts + getAllVisibleIfPorts(base)
	}
	
	def dispatch Iterable<Message> getAllVisibleIncomingMessages(ProtocolClass it) {
		if (base == null) return incomingMessages;
		
		return incomingMessages + getAllVisibleIncomingMessages(base)
	}
	
	def dispatch Iterable<Message> getAllVisibleIncomingMessages(CompoundProtocolClass it) {
		subProtocols.map[protocol.allVisibleIncomingMessages].flatten
	}
}