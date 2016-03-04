/*******************************************************************************
 * Copyright (c) 2013 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.examples.validators.fidl;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.IPath;
import org.eclipse.core.runtime.Path;
import org.eclipse.emf.common.util.URI;
import org.eclipse.xtext.validation.ValidationMessageAcceptor;
import org.franca.core.dsl.validation.IFrancaExternalValidator;
import org.franca.core.franca.FModel;
import org.franca.core.franca.FrancaPackage;

public class PackageNameValidator implements IFrancaExternalValidator {

	@Override
	public void validateModel(FModel model,
			ValidationMessageAcceptor messageAcceptor) {

		URI modelURI = model.eResource().getURI();
		String ps = modelURI.toPlatformString(true);
		if (ps==null) {
			throw new RuntimeException("Invalid model URI '" + modelURI.toString() + "'");
		}
		IFile file = ResourcesPlugin.getWorkspace().getRoot().getFile(new Path(ps));
		if (file.exists()) {
			IPath relativePath = file.getProjectRelativePath();
			String[] tokens = relativePath.toString().split("/");

			StringBuilder sb = new StringBuilder();
			if (tokens.length > 2) {
				for (int i = 1; i < tokens.length - 1; i++) {
					sb.append(tokens[i]);
					if (i != tokens.length - 2) {
						sb.append(".");
					}
				}
			}

			if (!sb.toString().equals(model.getName())) {
				messageAcceptor
						.acceptError(
								"The name of the container package and model package must be the same!",
								model, FrancaPackage.Literals.FMODEL__NAME,
								ValidationMessageAcceptor.INSIGNIFICANT_INDEX,
								null);
			}
		}
	}
}
