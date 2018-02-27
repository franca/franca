/** 
 * Copyright (c) 2014 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package org.franca.deploymodel.dsl.ui

import org.eclipse.ui.plugin.AbstractUIPlugin

/** 
 * Use this class to register components to be used within the IDE.
 * This version of the module assumes that org.eclipse.jdt.core and dependent 
 * plug-ins are installed in the runtime platform. If not, FDeployUiModuleWithoutJDT
 * should be used.
 * @see FDeployUiModuleWithoutJDT
 */
class FDeployUiModule extends org.franca.deploymodel.dsl.ui.AbstractFDeployUiModule {
	new(AbstractUIPlugin plugin) {
		super(plugin)
	}
}
