/*******************************************************************************
 * Copyright (c) 2018 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.core.dsl.tests.formatting

import com.google.inject.Inject
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.xtext.resource.SaveOptions
import org.eclipse.xtext.serializer.ISerializer
import org.eclipse.xtext.testing.util.ParseHelper
import org.franca.core.franca.FModel

/**
 * Base class for all Franca IDL formatter tests.
 */
class FormatterTestBase {

	@Inject extension ISerializer
	@Inject extension ParseHelper<FModel> 

	val SaveOptions options = SaveOptions.newBuilder.format.options
	
	/**
	 * Parse a textual fidl model and serialize it (which includes formatting).
	 */
	def protected String format(String input) {
		input.parse.serialize(options)
	}

	/**
	 * Serialize a manually created Franca model (which includes formatting).</p>
	 * 
	 * We need to attach the model to a resource, in order to make the AbstractFormatter2 work.</p>
	 */
	def protected String format(FModel fmodel) {
		fmodel.attachResource.serialize(options)
	}

	/**
	 * Helper which removes all whitespaces from empty lines in multiline strings.
	 */
	def protected String chompEmpty(String it) {
		replaceAll("(?m)^[ \t]*\r?\n", "\n")
	}

	/**
	 * The new AbstractFormatter2 API only formats a model on serialization
	 * if the model is contained in a resource.
	 */
	def private attachResource(FModel model) {
		val rset = new ResourceSetImpl
		val res = rset.createResource(URI.createURI("dummy.fidl"))
		res.contents.add(model)
		return model
	}

}
