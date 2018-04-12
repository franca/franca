/** 
 * Copyright (c) 2012 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package org.franca.core.dsl.validation.internal

import java.util.List
import org.eclipse.emf.common.util.TreeIterator
import org.eclipse.emf.ecore.util.EcoreUtil
import org.franca.core.FrancaModelExtensions
import org.franca.core.dsl.validation.internal.util.FrancaContractDirectedGraphDataSource
import org.franca.core.dsl.validation.internal.util.FrancaContractUndirectedGraphDataSource
import org.franca.core.dsl.validation.internal.util.GraphUtil
import org.franca.core.franca.FAssignment
import org.franca.core.franca.FAttribute
import org.franca.core.franca.FBroadcast
import org.franca.core.franca.FContract
import org.franca.core.franca.FDeclaration
import org.franca.core.franca.FEvaluableElement
import org.franca.core.franca.FEventOnIf
import org.franca.core.franca.FGuard
import org.franca.core.franca.FInterface
import org.franca.core.franca.FMethod
import org.franca.core.franca.FQualifiedElementRef
import org.franca.core.franca.FTransition
import org.franca.core.franca.FTrigger
import org.franca.core.typesystem.ActualType
import org.franca.core.typesystem.TypeSystem

import static org.franca.core.franca.FrancaPackage.Literals.*

class ContractValidator {

	def static void checkContract(ValidationMessageReporter reporter, FContract contract) {
		checkUsedInterfaceElements(reporter, contract)

		// add more checks here
		if (!GraphUtil.isConnected(new FrancaContractUndirectedGraphDataSource(contract))) {
			reporter.reportError("The contract must define a connected graph!", contract, FCONTRACT__STATE_GRAPH)
		}
		for(state : GraphUtil.getSinks(new FrancaContractDirectedGraphDataSource(contract))) {
			reporter.reportWarning('''The state '«»«state.getName()»' is a sink.''', state, FMODEL_ELEMENT__NAME)
		}
	}

	def private static void checkUsedInterfaceElements(ValidationMessageReporter reporter, FContract contract) {
		// collect interface elements used by this contract
		val List<FAttribute> usedAttributes = newArrayList
		val List<FMethod> usedMethods = newArrayList
		val List<FBroadcast> usedBroadcasts = newArrayList
		val TreeIterator<Object> contents = EcoreUtil.getAllContents(contract.stateGraph, true)
		while (contents.hasNext()) {
			val tt = contents.next
			if (tt instanceof FTransition) {
				var FEventOnIf ev = tt.trigger.event

				// during editing the model, there might not be an event right now
				if (ev !== null) {
					if (ev.set !== null) {
						usedAttributes.add(ev.set)
					} else if (ev.update !== null) {
						usedAttributes.add(ev.update)
					} else if (ev.call !== null) {
						usedMethods.add(ev.call)
					} else if (ev.respond !== null) {
						usedMethods.add(ev.respond)
					} else if (ev.signal !== null) {
						usedBroadcasts.add(ev.signal)
					}
				}
			}
		}
		val FInterface api = FrancaModelExtensions.getInterface(contract)
		for (e : api.attributes) {
			if (!usedAttributes.contains(e)) {
				reporter.reportWarning("Attribute is not covered by contract, not needed?", e,
					FMODEL_ELEMENT__NAME)
			}
		}
		for (e : api.methods) {
			if (!usedMethods.contains(e)) {
				reporter.reportWarning("Method is not covered by contract, not needed?", e,
					FMODEL_ELEMENT__NAME)
			}
		}
		for (e : api.broadcasts) {
			if (!usedBroadcasts.contains(e)) {
				reporter.reportWarning("Broadcast is not covered by contract, not needed?", e,
					FMODEL_ELEMENT__NAME)
			}
		}
	}

	def static void checkTrigger(ValidationMessageReporter reporter, FTrigger trigger) {
		val FEventOnIf event = trigger.event
		
		// while editing there might be no event right now
		if (event !== null) {
			var FMethod method = event.respond
			if (method !== null && method.isFireAndForget) {
				reporter.reportError("Fire-and-forget method will not send response message", trigger,
					FTRIGGER__EVENT)
			}
		}
	}

	def static void checkAssignment(ValidationMessageReporter reporter, FAssignment assignment) {
		val TypeSystem ts = new TypeSystem
		val FQualifiedElementRef lhs = assignment.lhs
		if (lhs.element !== null) {
			var FEvaluableElement te = lhs.element
			if (!(te instanceof FDeclaration)) {
				reporter.reportError("Left-hand side of assignment must be a state variable", assignment,
					FASSIGNMENT__LHS)
				return
			}
		}
		
		// check if types of LHS and RHS match
		val ActualType typeLHS = ts.getTypeOf(lhs)
		if (typeLHS === null) {
			reporter.reportError("Invalid left-hand side in assignment", assignment, FASSIGNMENT__LHS)
		} else {
			TypesValidator.checkExpression(reporter, assignment.rhs, typeLHS, assignment,
				FASSIGNMENT__RHS)
		}
	}

	def static void checkGuard(ValidationMessageReporter reporter, FGuard guard) {
		TypesValidator.checkExpression(reporter, guard.getCondition(), TypeSystem.BOOLEAN_TYPE, guard,
			FGUARD__CONDITION)
	}
}
