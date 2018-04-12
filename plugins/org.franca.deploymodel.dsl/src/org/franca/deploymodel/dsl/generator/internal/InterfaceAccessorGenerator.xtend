/*******************************************************************************
* Copyright (c) 2015 itemis AG (http://www.itemis.de).
* All rights reserved. This program and the accompanying materials
* are made available under the terms of the Eclipse Public License v1.0
* which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/epl-v10.html
*******************************************************************************/
package org.franca.deploymodel.dsl.generator.internal

import com.google.inject.Inject
import org.franca.core.franca.FArgument
import org.franca.core.franca.FArrayType
import org.franca.core.franca.FAttribute
import org.franca.core.franca.FField
import org.franca.deploymodel.core.FDeployedInterface
import org.franca.deploymodel.dsl.fDeploy.FDSpecification

import static extension org.franca.deploymodel.dsl.generator.internal.GeneratorHelper.*

class InterfaceAccessorGenerator extends CommonAccessorMethodGenerator {

	@Inject extension ImportManager
	
	def generate(FDSpecification spec) {
		val context = new CodeContext
		val methods = spec.generateAccessMethods(true, context)

		'''
			/**
			 * Accessor for deployment properties for Franca interfaces according to
			 * deployment specification '«spec.name»'.
			 */
			public static class InterfacePropertyAccessor
				«IF spec.base!==null»extends «spec.base.qualifiedClassname».InterfacePropertyAccessor«ENDIF»
				implements IDataPropertyAccessor
			{
				«IF context.targetNeeded»
				private final MappingGenericPropertyAccessor target;
				«ENDIF»
				private final DataPropertyAccessorHelper helper;
			
				«addNeededOtherType(FDeployedInterface)»
				public InterfacePropertyAccessor(FDeployedInterface target) {
					«IF spec.base!==null»
					super(target);
					«ENDIF»
					«IF context.targetNeeded»
					this.target = target;
					«ENDIF»
					this.helper = new DataPropertyAccessorHelper(target, this);
				}
				
				«methods»
				
				«genHelpForGetOverwriteAccessor(FAttribute, "obj")»
				«addNeededFrancaType(FAttribute)»
				public IDataPropertyAccessor getOverwriteAccessor(FAttribute obj) {
					return helper.getOverwriteAccessorAux(obj);
				}
			
				«genHelpForGetOverwriteAccessor(FArgument, "obj")»
				«addNeededFrancaType(FArgument)»
				public IDataPropertyAccessor getOverwriteAccessor(FArgument obj) {
					return helper.getOverwriteAccessorAux(obj);
				}
			
				@Override
				«addNeededFrancaType(FField)»
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
