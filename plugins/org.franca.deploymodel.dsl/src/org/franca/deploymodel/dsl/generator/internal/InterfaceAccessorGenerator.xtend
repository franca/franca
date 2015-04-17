/*******************************************************************************
* Copyright (c) 2015 itemis AG (http://www.itemis.de).
* All rights reserved. This program and the accompanying materials
* are made available under the terms of the Eclipse Public License v1.0
* which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/epl-v10.html
*******************************************************************************/
package org.franca.deploymodel.dsl.generator.internal

import org.franca.deploymodel.dsl.fDeploy.FDDeclaration
import org.franca.deploymodel.dsl.fDeploy.FDPropertyDecl
import org.franca.deploymodel.dsl.fDeploy.FDPropertyHost
import org.franca.deploymodel.dsl.fDeploy.FDSpecification
import org.franca.deploymodel.dsl.fDeploy.FDEnumType

class InterfaceAccessorGenerator {
	
	def generate(FDSpecification spec) '''
		/**
		 * Accessor for deployment properties for '«spec.name»' specification
		 */		
		public static class InterfacePropertyAccessor implements IDataPropertyAccessor {
	
			final private MappingGenericPropertyAccessor target;
			private final DataPropertyAccessorHelper helper;
	
			public InterfacePropertyAccessor (FDeployedInterface target) {
				this.target = target;
				this.helper = new DataPropertyAccessorHelper(target, this);
			}
			
				«FOR d : spec.declarations»
				«d.genProperties»
			«ENDFOR»
			
			public IDataPropertyAccessor getOverwriteAccessor (FAttribute obj) {
				return helper.getOverwriteAccessorAux(obj);
			}
	
			public IDataPropertyAccessor getOverwriteAccessor (FArgument obj) {
				return helper.getOverwriteAccessorAux(obj);
			}
	
			@Override
			public IDataPropertyAccessor getOverwriteAccessor (FField obj) {
				return helper.getOverwriteAccessorAux(obj);
			}
		}
	'''


	def private genProperties (FDDeclaration decl) '''
		«FOR p : decl.properties»
		«p.genProperty(decl.host)»
		«ENDFOR»
	'''
	
	def private genProperty (FDPropertyDecl it, FDPropertyHost host) '''
		«it.name»
	'''
	
}
