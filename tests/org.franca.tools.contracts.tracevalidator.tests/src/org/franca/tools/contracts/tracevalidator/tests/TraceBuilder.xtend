package org.franca.tools.contracts.tracevalidator.tests

import java.util.List
import org.franca.core.franca.FEventOnIf
import org.franca.core.franca.FrancaFactory
import org.franca.core.franca.FMethod
import org.franca.core.franca.FBroadcast
import org.franca.core.franca.FAttribute

class TraceBuilder {

	def static buildTrace((List<FEventOnIf>)=>void traceFunc) {
		val List<FEventOnIf> trace = newArrayList
		traceFunc.apply(trace)
		trace
	}

	def static call(List<FEventOnIf> trace, FMethod m) {
		val ev = FrancaFactory::eINSTANCE.createFEventOnIf
		ev.call = m
		trace.add(ev)
	}

	def static respond(List<FEventOnIf> trace, FMethod m) {
		val ev = FrancaFactory::eINSTANCE.createFEventOnIf
		ev.respond = m
		trace.add(ev)
	}
	
	def static error(List<FEventOnIf> trace, FMethod m) {
		val ev = FrancaFactory::eINSTANCE.createFEventOnIf
		ev.error = m
		trace.add(ev)
	}
	
	def static signal(List<FEventOnIf> trace, FBroadcast b) {
		val ev = FrancaFactory::eINSTANCE.createFEventOnIf
		ev.signal = b
		trace.add(ev)
	}

	def static set(List<FEventOnIf> trace, FAttribute a) {
		val ev = FrancaFactory::eINSTANCE.createFEventOnIf
		ev.set = a
		trace.add(ev)
	}

	def static update(List<FEventOnIf> trace, FAttribute a) {
		val ev = FrancaFactory::eINSTANCE.createFEventOnIf
		ev.update = a
		trace.add(ev)
	}

}