/*******************************************************************************
 * Copyright (c) 2012 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.core.dsl.validation;

import java.util.List;

import org.eclipse.emf.common.util.TreeIterator;
import org.eclipse.emf.ecore.util.EcoreUtil;
import org.franca.core.framework.FrancaHelpers;
import org.franca.core.franca.FAttribute;
import org.franca.core.franca.FBroadcast;
import org.franca.core.franca.FContract;
import org.franca.core.franca.FEventOnIf;
import org.franca.core.franca.FInterface;
import org.franca.core.franca.FMethod;
import org.franca.core.franca.FTransition;
import org.franca.core.franca.FTrigger;
import org.franca.core.franca.FrancaPackage;

import com.google.common.collect.Lists;

public class ContractValidator {

	public static void checkContract (ValidationMessageReporter reporter, FContract contract) {
		checkUsedInterfaceElements(reporter,  contract);
		// add more checks here
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

		FInterface api = FrancaHelpers.getEnclosingInterface(contract);
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
	   FMethod method = trigger.getEvent().getRespond(); 
	   if (method!=null && method.getFireAndForget()!=null) {
		   reporter.reportError("Fire-and-forget method will not send response message",
				   	trigger, FrancaPackage.Literals.FTRIGGER__EVENT);
	   } 
	}
	
}
