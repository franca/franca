/*******************************************************************************
* Copyright (c) 2015 itemis AG (http://www.itemis.de).
* All rights reserved. This program and the accompanying materials
* are made available under the terms of the Eclipse Public License v1.0
* which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/epl-v10.html
*******************************************************************************/
package org.franca.deploymodel.dsl.generator.internal

import com.google.inject.Inject
import org.franca.deploymodel.core.FDPropertyHost
import org.franca.deploymodel.dsl.fDeploy.FDDeclaration
import org.franca.deploymodel.dsl.fDeploy.FDEnumType
import org.franca.deploymodel.dsl.fDeploy.FDPropertyDecl
import org.franca.deploymodel.dsl.fDeploy.FDSpecification

import static extension org.franca.deploymodel.dsl.generator.internal.GeneratorHelper.*
import static extension org.franca.deploymodel.dsl.generator.internal.HostLogic.*

class ProviderAccessorGenerator {

	@Inject extension ImportManager
	@Inject CommonAccessorMethodGenerator helper

	def generate(FDSpecification spec) {
		val context = new CodeContext
		val methods =
			'''
				«FOR d : spec.declarations»
					«d.genProperties(context)»
				«ENDFOR»
			'''

		'''
			/**
			 * Accessor for deployment properties for providers and interface instances
			 * according to the '«spec.name»' specification.
			 */
			public static class ProviderPropertyAccessor
				«IF spec.base!==null»extends «spec.base.qualifiedClassname».ProviderPropertyAccessor«ENDIF»
				implements Enums
			{
				«IF context.targetNeeded»
				final private FDeployedProvider target;
				«ENDIF»				
			
				«addNeededFrancaType("FDeployedProvider")»
				public ProviderPropertyAccessor(FDeployedProvider target) {
					«IF spec.base!==null»
					super(target);
					«ENDIF»
					«IF context.targetNeeded»
					this.target = target;
					«ENDIF»
				}
				
				«methods»
			}
		'''
	}
	
	def private genProperties(FDDeclaration decl, ICodeContext context) '''
		«IF decl.properties.size > 0 && decl.host.isProviderHost»
			// host '«decl.host.getName»'
			«FOR p : decl.properties»
			«p.genProperty(decl.host, context)»
			«ENDFOR»
			
		«ENDIF»
	'''
	
	def private genProperty(FDPropertyDecl it, FDPropertyHost host, ICodeContext context) {
		val francaType = host.getFrancaTypeProvider
		addNeededFrancaType(francaType)
		if (francaType!==null) {
			context.requireTargetMember
			if (isEnum) {
				val enumType = name.toFirstUpper
				val retType =
					if (type.array===null) {
						enumType
					} else {
						enumType.genListType.toString
					}
				val enumerator = type.complex as FDEnumType
				helper.generateEnumMethod(it, francaType, enumType, retType, enumerator)
			} else {
				helper.generateMethod(it, francaType)
			}
		} else
			""
	}
	

}

