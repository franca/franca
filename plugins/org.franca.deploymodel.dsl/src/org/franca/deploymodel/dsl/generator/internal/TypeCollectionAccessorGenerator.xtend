/*******************************************************************************
* Copyright (c) 2015 itemis AG (http://www.itemis.de).
* All rights reserved. This program and the accompanying materials
* are made available under the terms of the Eclipse Public License v1.0
* which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/epl-v10.html
*******************************************************************************/
package org.franca.deploymodel.dsl.generator.internal

import org.franca.deploymodel.dsl.fDeploy.FDSpecification

class TypeCollectionAccessorGenerator extends CommonAccessorMethodGenerator {
	
	def generate(FDSpecification spec) '''
		/**
		 * Accessor for deployment properties for '«spec.name»' specification
		 */		
		public static class TypeCollectionPropertyAccessor
			«IF spec.base!=null»extends «spec.base.name».TypeCollectionPropertyAccessor«ENDIF»
			implements IDataPropertyAccessor
		{

			final private MappingGenericPropertyAccessor target;
			private final DataPropertyAccessorHelper helper;

			public TypeCollectionPropertyAccessor(FDeployedTypeCollection target) {
				this.target = target;
				this.helper = new DataPropertyAccessorHelper(target, this);
			}
			
			«spec.generateAccessMethods(false)»
			
			@Override
			public IDataPropertyAccessor getOverwriteAccessor(FField obj) {
				return helper.getOverwriteAccessorAux(obj);
			}
		}
	'''

}
