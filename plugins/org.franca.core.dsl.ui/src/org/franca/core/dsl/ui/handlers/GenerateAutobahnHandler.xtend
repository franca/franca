/** 
 * Copyright (c) 2018 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package org.franca.core.dsl.ui.handlers

import com.google.inject.Inject
import com.google.inject.Provider
import org.eclipse.core.commands.AbstractHandler
import org.eclipse.core.commands.ExecutionEvent
import org.eclipse.core.commands.ExecutionException
import org.eclipse.core.resources.IFile
import org.eclipse.core.resources.IProject
import org.eclipse.core.runtime.NullProgressMonitor
import org.eclipse.emf.common.util.URI
import org.eclipse.jface.viewers.ISelection
import org.eclipse.jface.viewers.IStructuredSelection
import org.eclipse.ui.handlers.HandlerUtil
import org.eclipse.xtext.builder.EclipseResourceFileSystemAccess2
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.franca.core.dsl.FrancaPersistenceManager
import org.franca.core.dsl.ui.util.SpecificConsole
import org.franca.core.franca.FModel
import org.franca.core.utils.FrancaRecursiveValidator
import org.franca.generators.FrancaAutobahnGenerator

/** 
 * Handler to generate client-side JS code for Autobahn API.</p>
 *  
 * @author Klaus Birken
 */
class GenerateAutobahnHandler extends AbstractHandler {
	@Inject FrancaPersistenceManager loader
	@Inject FrancaRecursiveValidator validator
	
	@Inject Provider<EclipseResourceFileSystemAccess2> fileAccessProvider

	@Inject FrancaAutobahnGenerator generator

	override Object execute(ExecutionEvent event) throws ExecutionException {
		var ISelection selection = HandlerUtil.getCurrentSelection(event)
		if (selection !== null && selection instanceof IStructuredSelection && !selection.isEmpty()) {
			var IFile file = (((selection as IStructuredSelection)).getFirstElement() as IFile)
			var URI uri = URI.createPlatformResourceURI(file.getFullPath().toString(), true)
			var URI rootURI = URI.createURI("classpath:/")
			var FModel fmodel = loader.loadModel(uri, rootURI)
			if (fmodel !== null) {
				if (! validator.hasErrors(fmodel.eResource())) {
					val IProject project = file.project
					val EclipseResourceFileSystemAccess2 fsa = fileAccessProvider.get
					fsa.setProject(project)
					fsa.setMonitor(new NullProgressMonitor)
					fsa.setOutputPath("./src-gen")
					fsa.outputConfigurations.get(IFileSystemAccess2.DEFAULT_OUTPUT).createOutputDirectory = true
					generator.doGenerate(fmodel.eResource, fsa, null)
				} else {
					var SpecificConsole console = new SpecificConsole("Franca")
					console.getErr().println("Aborting Autobahn/JS code generation due to validation errors!")
				}
			}
		}
		return null
	}
}
