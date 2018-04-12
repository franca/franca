/*******************************************************************************
 * Copyright (c) 2013 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.examples.basic.tests;

import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;

import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.xtext.testing.InjectWith;
import org.eclipse.xtext.testing.XtextRunner;
import org.franca.core.dsl.tests.FrancaIDLInjectorProvider;
import org.franca.core.dsl.FrancaPersistenceManager;
import org.franca.core.franca.FInterface;
import org.franca.core.franca.FModel;
import org.franca.core.utils.FileHelper;
import org.franca.examples.basic.generators.ExampleHppGenerator;
import org.junit.Test;
import org.junit.runner.RunWith;

import com.google.inject.Inject;

/**
 * Testcase for the example C++ header generator from Franca IDL interfaces.
 * 
 * @author kbirken
 *
 */
@RunWith(XtextRunner.class)
@InjectWith(FrancaIDLInjectorProvider.class)
public class HppGeneratorTest {

	@Inject
	FrancaPersistenceManager loader;
	
	@Test
	public void test() {
		System.out.println("*** HppGeneratorTest");
		
		// load example Franca IDL interface
    	URI root = URI.createURI("classpath:/");
    	URI loc = URI.createFileURI("org/example/MediaPlayer.fidl");
		FModel fmodel = loader.loadModel(loc, root);
		assertNotNull(fmodel);
		System.out.println("Franca IDL: package '" + fmodel.getName() + "'");
		
		// generate code from first interface in Franca model
		assertTrue(fmodel.getInterfaces().size()>0);
		FInterface api = fmodel.getInterfaces().get(0);
		ExampleHppGenerator generator = new ExampleHppGenerator();
		String code = generator.generateInterface(api).toString();
		System.out.println("Generated code:\n" + code);
		
		FileHelper.save("src-gen", getBasename(fmodel) + ".hpp", code);
	}

	// TODO: use FrancaGenerators.getBaseName lateron
	private static String getBasename (EObject obj) {
		String filename = obj.eResource().getURI().lastSegment();
		String basename = filename.substring(0, filename.lastIndexOf('.'));
		return basename;
	}

}
