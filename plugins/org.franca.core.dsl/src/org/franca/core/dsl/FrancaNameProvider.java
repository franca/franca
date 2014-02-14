/*******************************************************************************
* Copyright (c) 2012 Harman International (http://www.harman.com).
* All rights reserved. This program and the accompanying materials
* are made available under the terms of the Eclipse Public License v1.0
* which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/epl-v10.html
*******************************************************************************/
package org.franca.core.dsl;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.xtext.naming.DefaultDeclarativeQualifiedNameProvider;
import org.eclipse.xtext.naming.QualifiedName;

public class FrancaNameProvider extends DefaultDeclarativeQualifiedNameProvider {

	@Override
	public QualifiedName getFullyQualifiedName(EObject e) {
//		if (e instanceof FType) {	
//			String name = "";
//			if (e instanceof FComplexType) {
//				FComplexType ctype = (FComplexType)e;
//				name = ctype.getName();
//			} else {
//				FType type = (FType)e;
//				name = type.getPredefined().toString();
//			}
//			
//			System.out.println("FrancaNameProvider::getFullyQualifiedName " + name);
//			if (! name.isEmpty()) {
//				return QualifiedName.create(name);
//			}
//		}
		return super.getFullyQualifiedName(e);
	}

}
