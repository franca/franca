/*******************************************************************************
* Copyright (c) 2015 itemis AG (http://www.itemis.de).
* All rights reserved. This program and the accompanying materials
* are made available under the terms of the Eclipse Public License v1.0
* which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/epl-v10.html
*******************************************************************************/
package org.franca.deploymodel.dsl.generator.internal

import org.franca.deploymodel.dsl.fDeploy.FDSpecification

class InterfaceAccessorGenerator extends CommonAccessorMethodGenerator {
	
	def generate(FDSpecification spec) '''
		/**
		 * Accessor for deployment properties for '«spec.name»' specification.
		 */
		public static class InterfacePropertyAccessor
			«IF spec.base!=null»extends «spec.base.name».InterfacePropertyAccessor«ENDIF»
			implements IDataPropertyAccessor
		{
		
			final private MappingGenericPropertyAccessor target;
			private final DataPropertyAccessorHelper helper;
		
			public InterfacePropertyAccessor(FDeployedInterface target) {
				this.target = target;
				this.helper = new DataPropertyAccessorHelper(target, this);
			}
			
			«spec.generateAccessMethods(true)»
			
			«genHelpForGetOverwriteAccessor("FAttribute", "obj")»
			public IDataPropertyAccessor getOverwriteAccessor(FAttribute obj) {
				return helper.getOverwriteAccessorAux(obj);
			}
		
			«genHelpForGetOverwriteAccessor("FArgument", "obj")»
			public IDataPropertyAccessor getOverwriteAccessor(FArgument obj) {
				return helper.getOverwriteAccessorAux(obj);
			}
		
			@Override
			public IDataPropertyAccessor getOverwriteAccessor(FField obj) {
				return helper.getOverwriteAccessorAux(obj);
			}
		}
	'''
	
}
