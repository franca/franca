/** 
 * Copyright (c) 2018 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package org.franca.generators

import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.AbstractGenerator
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.xtext.generator.IGeneratorContext
import org.franca.core.franca.FInterface
import org.franca.core.franca.FModel
import org.franca.generators.websocket.ClientJSBlueprintGenerator
import org.franca.generators.websocket.ClientJSProxyGenerator

import static extension org.franca.core.FrancaModelExtensions.*

/**
 * Generates client-side JS code for Autobahn-binding.</p>
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#code-generation
 */
class FrancaAutobahnGenerator extends AbstractGenerator {

	override void doGenerate(Resource resource, IFileSystemAccess2 fsa, IGeneratorContext context) {
		val genClientProxy = new ClientJSProxyGenerator
		val genClientBlueprint = new ClientJSBlueprintGenerator

		val interfaces = resource.allContents.toIterable.filter(typeof(FInterface)).toList
		if (! interfaces.empty) {
			// generate for first interface only
			val api = interfaces.get(0)

			// compute generation path from model's package name
			val path = api.model.path + "/"
			
			val clientStubContent = genClientProxy.generate(api, ClientJSProxyGenerator.Mode.AUTOBAHN)
			fsa.generateFile(path + genClientProxy.getFileName(api) + ".js", clientStubContent)

			val clientBlueprintContent = genClientBlueprint.generate(api)
			fsa.generateFile(path + genClientBlueprint.getFileName(api) + ".js", clientBlueprintContent)
		}
	}

	/**
	 * Transform a model's package FQN into a relative directory path.
	 */
	def private String getPath(FModel fmodel) {
		fmodel.name.replace(".", "/")
	}
	
}
