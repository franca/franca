/** 
 * Copyright (c) 2018 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package org.franca.deploymodel.dsl

import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.naming.DefaultDeclarativeQualifiedNameProvider

class FDeployDeclarativeNameProvider extends DefaultDeclarativeQualifiedNameProvider {
	
	override getFullyQualifiedName(EObject obj) {
//		switch (obj) {
//			// default name provisioning for anonymous deployments:
//			// <current deployment package>.<short name of deployed entity>_<entity type>_depl
//			FDInterface,
//			FDTypes: {
//				if (obj.name === null) {
//					val node = NodeModelUtils.getNode(obj)
//					val segments = NodeModelUtils.getTokenText(node).split("\\s")
//					if (segments.length >= 5) {
//						val name = segments.get(4).split("\\.").last
//						obj.name = name + "_depl"
//					}
//				}
//			}
//		}
		return super.getFullyQualifiedName(obj)
	}
}
