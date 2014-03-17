package org.franca.core.ui.addons.wizard;

import org.eclipse.emf.ecore.EObject;

/**
 * Classes which implement this interface can be registered for the selection
 * changes of a {@link ModelElementSelector} widget.
 * 
 * @author Tamas Szabo (itemis AG)
 * 
 */
public interface IModelElementSelectorListener {

	public void selectionChanged(EObject value);

}
