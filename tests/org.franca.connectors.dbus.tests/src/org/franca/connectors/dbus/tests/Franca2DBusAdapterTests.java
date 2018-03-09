/*******************************************************************************
 * Copyright (c) 2013 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.connectors.dbus.tests;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.xtext.testing.InjectWith;
import org.franca.connectors.dbus.DBusConnector;
import org.franca.connectors.dbus.DBusModelContainer;
import org.franca.core.dsl.FrancaIDLTestsInjectorProvider;
import org.franca.core.dsl.FrancaPersistenceManager;
import org.franca.core.dsl.tests.util.XtextRunner2_Franca;
import org.franca.core.framework.FrancaModelMapper;
import org.franca.core.franca.FArgument;
import org.franca.core.franca.FAttribute;
import org.franca.core.franca.FBroadcast;
import org.franca.core.franca.FInterface;
import org.franca.core.franca.FMethod;
import org.franca.core.franca.FModel;
import org.junit.Test;
import org.junit.runner.RunWith;

import com.google.inject.Inject;

import model.emf.dbusxml.ArgType;
import model.emf.dbusxml.InterfaceType;
import model.emf.dbusxml.MethodType;
import model.emf.dbusxml.NodeType;
import model.emf.dbusxml.PropertyType;
import model.emf.dbusxml.SignalType;

@RunWith(XtextRunner2_Franca.class)
@InjectWith(FrancaIDLTestsInjectorProvider.class)
public class Franca2DBusAdapterTests {

	@Inject	FrancaPersistenceManager loader;
	
	@Test
	public void test_30() {
		doTransformTest("30-SimpleAttribute");
	}
	
	@Test
	public void testCycle_75() {
		doTransformTest("75-TestCycle");
	}
	
	@Test
	public void test_75() {
		doTransformTest("75-TestInterfaceInheritance");
	}

	@Test
	public void test_40() {
		doTransformTest("40-PolymorphicStructs");
	}

	@Test
	public void testIntegerRange_109() {
		doTransformTest("109-TestIntegerRange");
	}
	
	@Test
	public void TestUnion() {
		doTransformTest("TestUnion");
	}
	
	@Test
	public void TestEnum() {
		doTransformTest("TestEnum");
	}

	@SuppressWarnings("restriction")
	private void doTransformTest (String fileBasename) {
		// load example Franca IDL interface
		String inputfile = "model/testcases/" + fileBasename + ".fidl";
		System.out.println("Loading Franca file " + inputfile + " ...");
		FModel fmodel = loader.loadModel(inputfile);
		assertNotNull(fmodel);
		
		// transform to D-Bus Introspection XML
		DBusConnector conn = new DBusConnector();
		DBusModelContainer fromFranca = (DBusModelContainer)conn.fromFranca(fmodel);
		conn.saveModel(fromFranca, "src-gen/testcases/" + fileBasename + ".xml");
		
		// check that adapters pointing back to the right Franca model elements 
		NodeType n = fromFranca.model();
		checkBacklink(n, FModel.class);
		for(InterfaceType i : n.getInterface()) {
			checkBacklink(i, FInterface.class);
			for(PropertyType p : i.getProperty()) {
				checkBacklink(p, FAttribute.class);
			}
			for(MethodType m : i.getMethod()) {
				checkBacklink(m, FMethod.class);
				for(ArgType a : m.getArg())
					checkBacklink(a, FArgument.class);
			}
			for(SignalType s : i.getSignal()) {
				checkBacklink(s, FBroadcast.class);
				for(ArgType a : s.getArg())
					checkBacklink(a, FArgument.class);
			}
		}
	}
	
	private void checkBacklink (EObject dbusObject, Class<?> expectedType) {
		EObject francaObject = FrancaModelMapper.getFrancaElement(dbusObject);
		assertNotNull(francaObject);
		assertEquals(true, expectedType.isInstance(francaObject));
	}
}

