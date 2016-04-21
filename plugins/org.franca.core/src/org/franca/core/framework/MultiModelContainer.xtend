package org.franca.core.framework

import java.util.List
import java.util.Map
import org.eclipse.emf.ecore.EObject

/**
 * An IModelContainer for an IDL language with include-functionality.
 */
class MultiModelContainer<T extends EObject> implements IModelContainer {
	
	/**
	 * A map containing the top-level model and all additional models which are #included
	 * from the top-level model or transitively. The map value contains the filename of the
	 * corresponding model.</p>
	 * 
	 * The first entry in the list is the top-level model.</p>
	 * 
	 * All resources corresponding to the various models should be contained in
	 * the same ResourceSet.</p>
	 */
	val Map<T, String> parts = newLinkedHashMap
	
	/**
	 * Constructor for creating the container for just one simple model.
	 * 
	 * @param model the OMG IDL model
	 */
	new (T model) {
		val name = model.eResource.getURI.lastSegment
		this.parts.put(model, name)
	}
	
	/**
	 * Constructor for creating the container for a top-level model which 
	 * might import other models (including transitive includes).
	 * 
	 * @param part2filename a map from all models to their corresponding filenames 
	 */
	new (Map<T, String> part2filename) {
		this.parts.putAll(part2filename)
	}
	
	def T model() {
		if (parts.empty)
			null
		else
			parts.keySet.iterator.next
	}
	
	def List<T> models() {
		newArrayList(this.parts.keySet)
	}

	def String getFilename(T unit) {
		this.parts.get(unit)
	}
}

