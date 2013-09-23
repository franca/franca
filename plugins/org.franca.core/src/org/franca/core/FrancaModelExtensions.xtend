/*******************************************************************************
 * Copyright (c) 2012 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.core

import java.util.List
import java.util.Map
import java.util.Queue
import java.util.Set
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.Resource
import org.franca.core.franca.FContract
import org.franca.core.franca.FInterface
import org.franca.core.franca.FModel
import org.franca.core.franca.FStateGraph
import org.franca.core.franca.FTypeCollection
import org.franca.core.franca.Import

class FrancaModelExtensions {
	
	def static getModel (EObject obj) {
		getParentObject(obj, typeof(FModel))
	}
	
	def static getTypeCollection (EObject obj) {
		getParentObject(obj, typeof(FTypeCollection))
	}
	
	def static getInterface (EObject obj) {
		getParentObject(obj, typeof(FInterface))
	}
	
	def static getStateGraph (EObject obj) {
		getParentObject(obj, typeof(FStateGraph))
	}
	
	def static getContract (EObject obj) {
		getParentObject(obj, typeof(FContract))
	}
	
	
	def private static <T extends EObject> getParentObject (EObject it, Class<T> clazz) {
		var x = it
		
		do {
			x = x.eContainer
			if (clazz.isInstance(x))
				return x as T
		} while (x!=null)
		
		return null
	}


	/**
	 * Get all FModels which are imported by current model (transitively).
	 */
	def static getAllImportedModels (FModel model) {
		val rset = model.eResource.resourceSet
		val Set<Resource> visited = newHashSet
		val Queue<Resource> todo = newLinkedList(model.eResource)
		val Map<Resource, Set<Import>> importedVia = newHashMap
		val List<FModel> imported = newArrayList
		while (! todo.empty) {
			val r = todo.poll
			if (! visited.contains(r)) {
				visited.add(r)
				
				val m = r.getFModel
				if (m!=null) {
					// add imported models to queue				
					for(imp : m.imports) {
						val uri = imp.importURI
						val importURI = URI::createURI(uri)
						val resolvedURI = importURI.resolve(m.eResource.URI);
						val res = rset.getResource(resolvedURI, true)
						todo.add(res)
						
						// remember imported model
						val importedModel = res.getFModel
						if (importedModel!=null)
							imported.add(importedModel)
							
						// remember top-level import statement which lead to this import
						if (! importedVia.containsKey(res))
							importedVia.put(res, newHashSet)
						if (m==model) {
							importedVia.get(res).add(imp)
						} else {
							val via = importedVia.get(r)
							importedVia.get(res).addAll(via)
						}
						
					}
				}
			}
		}
		new ImportedModelInfo(imported, importedVia)
	}

	def private static getFModel (Resource res) {
		if (res.contents==null || res.contents.empty) {
			null
		} else {
			val obj = res.contents.get(0)
			if (obj instanceof FModel) {
				obj as FModel
			} else {
				null
			}
		}					
	}

}

@Data
class ImportedModelInfo {
	Iterable<FModel> importedModels
	Map<Resource, Set<Import>> importVia
	
	def getViaString (Resource res) {
		val via = importVia.get(res)
		via.join(', ', ["'" + importURI + "'"])
	}
}
