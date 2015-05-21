package org.franca.core.contracts

import org.franca.core.franca.FEventOnIf

class FEventUtils {

	def static String getEventLabel(FEventOnIf it) {
		if (call!=null) {
			"call " + call.name
		} else if (respond!=null) {
			"respond " + respond.name
		} else if (error!=null) {
			"error " + error.name
		} else if (signal!=null) {
			"signal " + signal.name
		} else if (set!=null) {
			"set " + set.name
		} else if (update!=null) {
			"update " + update.name
		} else {
			"unknown_event"
		}
	}

	def static String getEventID(FEventOnIf it) {
		eventLabel.replace(' ', '_')
	}
		
	def static boolean isClientToServer(FEventOnIf it) {
		call!=null || set!=null
	}
	
	def static boolean isEqual(FEventOnIf a, FEventOnIf b) {
		if (a.call!=null && b.call!=null) {
			a.call==b.call
		} else if (a.respond!=null && b.respond!=null) {
			a.respond==b.respond
		} else if (a.error!=null && b.error!=null) {
			a.error==b.error
		} else if (a.set!=null && b.set!=null) {
			a.set==b.set
		} else if (a.update!=null && b.update!=null) {
			a.update==b.update
		} else
			false
	}
}

