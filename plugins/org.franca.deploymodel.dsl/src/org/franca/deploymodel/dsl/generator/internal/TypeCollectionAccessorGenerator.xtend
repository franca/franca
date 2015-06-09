/*******************************************************************************
* Copyright (c) 2015 itemis AG (http://www.itemis.de).
* All rights reserved. This program and the accompanying materials
* are made available under the terms of the Eclipse Public License v1.0
* which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/epl-v10.html
*******************************************************************************/
package org.franca.deploymodel.dsl.generator.internal

import com.google.inject.Inject
import org.franca.deploymodel.dsl.fDeploy.FDSpecification

import static extension org.franca.deploymodel.dsl.generator.internal.GeneratorHelper.*

class TypeCollectionAccessorGenerator extends CommonAccessorMethodGenerator {
	
	@Inject extension ImportManager

	def generate(FDSpecification spec) '''
		/**
		 * Accessor for deployment properties for Franca type collections according
		 * to deployment specification '«spec.name»'.
		 */		
		public static class TypeCollectionPropertyAccessor
			«IF spec.base!=null»extends «spec.base.qualifiedClassname».TypeCollectionPropertyAccessor«ENDIF»
			implements IDataPropertyAccessor
		{
			final private MappingGenericPropertyAccessor target;
			private final DataPropertyAccessorHelper helper;

			«addNeededFrancaType("FDeployedTypeCollection")»
			public TypeCollectionPropertyAccessor(FDeployedTypeCollection target) {
				«IF spec.base!=null»
				super(target);
				«ENDIF»
				this.target = target;
				this.helper = new DataPropertyAccessorHelper(target, this);
			}
			
			«spec.generateAccessMethods(false)»
			
			@Override
			public IDataPropertyAccessor getOverwriteAccessor(FField obj) {
				return helper.getOverwriteAccessorAux(obj);
			}
		
			@Override
			«addNeededFrancaType("FArrayType")»
			public IDataPropertyAccessor getOverwriteAccessor(FArrayType obj) {
				return helper.getOverwriteAccessorAux(obj);
			}
		}
	'''

}
