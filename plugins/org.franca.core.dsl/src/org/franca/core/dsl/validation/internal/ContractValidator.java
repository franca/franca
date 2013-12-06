/*******************************************************************************
 * Copyright (c) 2012 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.core.dsl.validation.internal;

import java.util.List;

import org.eclipse.emf.common.util.TreeIterator;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EStructuralFeature;
import org.eclipse.emf.ecore.util.EcoreUtil;
import org.franca.core.FrancaModelExtensions;
import org.franca.core.contracts.IssueCollector;
import org.franca.core.contracts.TypeIssue;
import org.franca.core.contracts.TypeSystem;
import org.franca.core.dsl.validation.internal.util.FrancaContractDirectedGraphDataSource;
import org.franca.core.dsl.validation.internal.util.FrancaContractUndirectedGraphDataSource;
import org.franca.core.dsl.validation.internal.util.GraphUtil;
import org.franca.core.framework.FrancaHelpers;
import org.franca.core.franca.FAssignment;
import org.franca.core.franca.FAttribute;
import org.franca.core.franca.FBroadcast;
import org.franca.core.franca.FContract;
import org.franca.core.franca.FEventOnIf;
import org.franca.core.franca.FExpression;
import org.franca.core.franca.FGuard;
import org.franca.core.franca.FInterface;
import org.franca.core.franca.FMethod;
import org.franca.core.franca.FState;
import org.franca.core.franca.FTransition;
import org.franca.core.franca.FTrigger;
import org.franca.core.franca.FTypeRef;
import org.franca.core.franca.FrancaPackage;

import com.google.common.collect.Lists;

public class ContractValidator {

	public static void checkContract(ValidationMessageReporter reporter, FContract contract) {
		checkUsedInterfaceElements(reporter,  contract);
		// add more checks here
		if (!GraphUtil.isConnected(new FrancaContractUndirectedGraphDataSource(contract))) {
			reporter.reportError("The contract must define a connected graph!", contract, FrancaPackage.Literals.FCONTRACT__STATE_GRAPH);
		}
		
		for (FState state : GraphUtil.getSinks(new FrancaContractDirectedGraphDataSource(contract))) {
			reporter.reportWarning("The state '"+state.getName()+"' is a sink.", state, FrancaPackage.Literals.FMODEL_ELEMENT__NAME);
		}
	}
	
	private static void checkUsedInterfaceElements (ValidationMessageReporter reporter, FContract contract) {
		// collect interface elements used by this contract
		List<FAttribute> usedAttributes = Lists.newArrayList(); 
		List<FMethod> usedMethods = Lists.newArrayList(); 
		List<FBroadcast> usedBroadcasts = Lists.newArrayList(); 
		TreeIterator<Object> contents = EcoreUtil.getAllContents(contract.getStateGraph(), true);
		while (contents.hasNext()) {
			Object obj = contents.next();
			if (obj instanceof FTransition) {
				FTransition tt = (FTransition)obj;
				FEventOnIf ev = tt.getTrigger().getEvent();
				//during editing the model, there might not be an event right now
				if (ev != null) {
					if (ev.getSet()!=null) {
						usedAttributes.add(ev.getSet());
					} else if (ev.getUpdate()!=null) {
						usedAttributes.add(ev.getUpdate());
					} else if (ev.getCall()!=null) {
						usedMethods.add(ev.getCall());
					} else if (ev.getRespond()!=null) {
						usedMethods.add(ev.getRespond());
					} else if (ev.getSignal()!=null) {
						usedBroadcasts.add(ev.getSignal());
					}
				}
			}
		}

		FInterface api = FrancaModelExtensions.getInterface(contract);
		for(FAttribute e : api.getAttributes()) {
			if (! usedAttributes.contains(e)) {
				reporter.reportWarning("Attribute is not covered by contract, not needed?",
						e, FrancaPackage.Literals.FMODEL_ELEMENT__NAME);
			}
		}
		for(FMethod e : api.getMethods()) {
			if (! usedMethods.contains(e)) {
				reporter.reportWarning("Method is not covered by contract, not needed?",
						e, FrancaPackage.Literals.FMODEL_ELEMENT__NAME);
			}
		}
		for(FBroadcast e : api.getBroadcasts()) {
			if (! usedBroadcasts.contains(e)) {
				reporter.reportWarning("Broadcast is not covered by contract, not needed?",
						e, FrancaPackage.Literals.FMODEL_ELEMENT__NAME);
			}
		}
	}

	
	public static void checkTrigger (ValidationMessageReporter reporter, FTrigger trigger) {
	   FEventOnIf event = trigger.getEvent();
	   //while editing there might be no event right now
	   if (event != null) {
		   FMethod method = event.getRespond(); 
		   if (method!=null && method.isFireAndForget()) {
			   reporter.reportError("Fire-and-forget method will not send response message",
					   	trigger, FrancaPackage.Literals.FTRIGGER__EVENT);
		   }
	   }
	}
	
	
	public static void checkAssignment (ValidationMessageReporter reporter, FAssignment assignment) {
		FTypeRef typeRHS = checkExpression(reporter, assignment.getRhs(), assignment, FrancaPackage.Literals.FASSIGNMENT__RHS);
		if (typeRHS!=null) {
			FTypeRef typeLHS = checkExpression(reporter, assignment.getLhs(), assignment, FrancaPackage.Literals.FASSIGNMENT__LHS);
			if (! TypeSystem.isCompatibleType(typeRHS, typeLHS)) {
				reporter.reportError(
						"invalid expression type in assignment (is " +
								FrancaHelpers.getTypeString(typeRHS) + ", expected " +
								FrancaHelpers.getTypeString(typeLHS) + ")",
						assignment, FrancaPackage.Literals.FASSIGNMENT__RHS);
			}
		}
	}
	
	public static void checkGuard (ValidationMessageReporter reporter, FGuard guard) {
		FTypeRef type = checkExpression(reporter, guard.getCondition(), guard, FrancaPackage.Literals.FGUARD__CONDITION);
		
		if (! FrancaHelpers.isBoolean(type)) {
			reporter.reportError(
					"expected boolean type for guard expression (is " +
							FrancaHelpers.getTypeString(type) + ")",
					guard, FrancaPackage.Literals.FGUARD__CONDITION);
		}
	}

	private static FTypeRef checkExpression (
			ValidationMessageReporter reporter,
			FExpression expr,
			EObject loc, EStructuralFeature feat)
	{
		TypeSystem ts = new TypeSystem();
		IssueCollector issues = new IssueCollector();
		FTypeRef type = ts.evaluateType(expr, issues, loc, feat);
		if (! issues.getIssues().isEmpty()) {
			for(TypeIssue ti : issues.getIssues()) {
				reporter.reportError(ti.getMessage(), ti.getLocation(), ti.getFeature());
			}
			return null;
		}
		
		return type;
	}
}
