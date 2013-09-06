/*******************************************************************************
 * Copyright (c) 2013 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.tools.contracts.tracegen.strategies.events;

import java.lang.reflect.InvocationTargetException;

import org.eclipse.emf.common.notify.Adapter;
import org.eclipse.emf.common.notify.Notification;
import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.common.util.TreeIterator;
import org.eclipse.emf.ecore.EClass;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EOperation;
import org.eclipse.emf.ecore.EReference;
import org.eclipse.emf.ecore.EStructuralFeature;
import org.eclipse.emf.ecore.resource.Resource;
import org.franca.core.franca.FAttribute;
import org.franca.core.franca.FBroadcast;
import org.franca.core.franca.FEventOnIf;
import org.franca.core.franca.FMethod;
import org.franca.core.franca.FrancaFactory;

/**
 * TODO: perhaps delete this class
 * 
 * @author Steffen Weik
 *
 */
public class UnknownEventOnIf implements FEventOnIf {
	
	private FEventOnIf event;
	private static UnknownEventOnIf instance;
	{
		instance = new UnknownEventOnIf();
	}
	
	public static UnknownEventOnIf getInstance() {
		return instance;
	}

	private UnknownEventOnIf() {
		this.event = FrancaFactory.eINSTANCE.createFEventOnIf();
	}
	
	@Override
	public EClass eClass() {
		return event.eClass();
	}

	@Override
	public Resource eResource() {
		return null;
	}

	@Override
	public EObject eContainer() {
		return null;
	}

	@Override
	public EStructuralFeature eContainingFeature() {
		return null;
	}

	@Override
	public EReference eContainmentFeature() {
		return null;
	}

	@Override
	public EList<EObject> eContents() {
		return event.eContents();
	}

	@Override
	public TreeIterator<EObject> eAllContents() {
		return event.eAllContents();
	}

	@Override
	public boolean eIsProxy() {
		return false;
	}

	@Override
	public EList<EObject> eCrossReferences() {
		return event.eCrossReferences();
	}

	@Override
	public Object eGet(EStructuralFeature feature) {
		return event.eGet(feature);
	}

	@Override
	public Object eGet(EStructuralFeature feature, boolean resolve) {
		return event.eGet(feature, resolve);
	}

	@Override
	public void eSet(EStructuralFeature feature, Object newValue) {
		event.eSet(feature, newValue);
	}

	@Override
	public boolean eIsSet(EStructuralFeature feature) {
		return event.eIsSet(feature);
	}

	@Override
	public void eUnset(EStructuralFeature feature) {
		event.eUnset(feature);
	}

	@Override
	public Object eInvoke(EOperation operation, EList<?> arguments)
			throws InvocationTargetException {
		return event.eInvoke(operation, arguments);
	}

	@Override
	public EList<Adapter> eAdapters() {
		return event.eAdapters();
	}

	@Override
	public boolean eDeliver() {
		return event.eDeliver();
	}

	@Override
	public void eSetDeliver(boolean deliver) {
		event.eSetDeliver(deliver);
	}

	@Override
	public void eNotify(Notification notification) {
		event.eNotify(notification);
	}

	@Override
	public FMethod getCall() {
		return event.getCall();
	}

	@Override
	public void setCall(FMethod value) {
		event.setCall(value);
	}

	@Override
	public FMethod getRespond() {
		return event.getRespond();
	}

	@Override
	public void setRespond(FMethod value) {
		event.setRespond(value);
	}

	@Override
	public FBroadcast getSignal() {
		return event.getSignal();
	}

	@Override
	public void setSignal(FBroadcast value) {
		event.setSignal(value);
	}

	@Override
	public FAttribute getSet() {
		return event.getSet();
	}

	@Override
	public void setSet(FAttribute value) {
		event.setSet(value);
	}

	@Override
	public FAttribute getUpdate() {
		return event.getUpdate();
	}

	@Override
	public void setUpdate(FAttribute value) {
		event.setUpdate(value);
	}

	@Override
	public FMethod getError() {
		return event.getError();
	}

	@Override
	public void setError(FMethod value) {
		event.setError(value);
	}

}
