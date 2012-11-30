/*******************************************************************************
 * Copyright (c) 2012 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.core.dsl;

import java.util.Iterator;

import org.eclipse.emf.ecore.EObject;
import org.franca.core.franca.FModel;
import org.franca.core.franca.Import;
import org.franca.core.utils.ImportsProvider;

public class FrancaImportsProvider implements ImportsProvider {
	
	public Iterator<String> importsIterator(EObject model) {
		if (!(model instanceof FModel))
			return null;
		final FModel idlModel = (FModel) model;
		
		return new Iterator<String>() {
			Iterator<Import> it = idlModel.getImports().iterator();

			public boolean hasNext() {
				return it.hasNext();
			}

			public String next() {
				return it.next().getImportURI();
			}

			public void remove() {
				//operation not allowed
			}
		};
	}

}
