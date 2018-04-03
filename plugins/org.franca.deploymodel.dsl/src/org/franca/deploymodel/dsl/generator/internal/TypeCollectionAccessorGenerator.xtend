/*******************************************************************************
* Copyright (c) 2015 itemis AG (http://www.itemis.de).
* All rights reserved. This program and the accompanying materials
* are made available under the terms of the Eclipse Public License v1.0
* which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/epl-v10.html
*******************************************************************************/
package org.franca.deploymodel.dsl.generator.internal

import com.google.inject.Inject
import org.franca.core.franca.FArrayType
import org.franca.deploymodel.core.FDeployedTypeCollection
import org.franca.deploymodel.dsl.fDeploy.FDSpecification

import static extension org.franca.deploymodel.dsl.generator.internal.GeneratorHelper.*

class TypeCollectionAccessorGenerator extends CommonAccessorMethodGenerator {
	
	@Inject extension ImportManager

	def generate(FDSpecification spec) {
		val context = new CodeContext
		val methods = spec.generateAccessMethods(false, context)

		'''
			/**
			 * Accessor for deployment properties for Franca type collections according
			 * to deployment specification '«spec.name»'.
			 */		
			public static class TypeCollectionPropertyAccessor
				«IF spec.base!==null»extends «spec.base.qualifiedClassname».TypeCollectionPropertyAccessor«ENDIF»
				implements IDataPropertyAccessor
			{
				«IF context.targetNeeded»
				private final MappingGenericPropertyAccessor target;
				«ENDIF»
				private final DataPropertyAccessorHelper helper;
			
				«addNeededOtherType(FDeployedTypeCollection)»
				public TypeCollectionPropertyAccessor(FDeployedTypeCollection target) {
					«IF spec.base!==null»
					super(target);
					«ENDIF»
					«IF context.targetNeeded»
					this.target = target;
					«ENDIF»
					this.helper = new DataPropertyAccessorHelper(target, this);
				}
				
				«methods»
				
				@Override
				public IDataPropertyAccessor getOverwriteAccessor(FField obj) {
					return helper.getOverwriteAccessorAux(obj);
				}
			
				@Override
				«addNeededFrancaType(FArrayType)»
				public IDataPropertyAccessor getOverwriteAccessor(FArrayType obj) {
					return helper.getOverwriteAccessorAux(obj);
				}
			}
		'''
	}
	
}
