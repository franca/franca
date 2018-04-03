/*******************************************************************************
* Copyright (c) 2018 itemis AG (http://www.itemis.de).
* 
* All rights reserved. This program and the accompanying materials
* are made available under the terms of the Eclipse Public License v1.0
* which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/epl-v10.html
*******************************************************************************/
package org.franca.deploymodel.dsl.generator.internal

import com.google.inject.Inject
import org.eclipse.emf.ecore.EObject
import org.franca.deploymodel.core.FDPropertyHost
import org.franca.deploymodel.core.FDeployedRootElement
import org.franca.deploymodel.dsl.fDeploy.FDDeclaration
import org.franca.deploymodel.dsl.fDeploy.FDEnumType
import org.franca.deploymodel.dsl.fDeploy.FDPropertyDecl
import org.franca.deploymodel.dsl.fDeploy.FDSpecification
import org.franca.deploymodel.extensions.ExtensionRegistry

import static extension org.franca.deploymodel.dsl.generator.internal.GeneratorHelper.*
import static extension org.franca.deploymodel.dsl.generator.internal.HostLogic.*

/**
 * Generates a specific PropertyAccessor class for a root element definition
 * from a deployment extension.</p>
 * 
 * @author Klaus Birken (itemis AG)  
 */
class RootElementAccessorGenerator {

	@Inject extension ImportManager
	@Inject CommonAccessorMethodGenerator helper

	def generate(FDSpecification spec, Class<? extends EObject> rootClass, String prefix, String extensionName, (FDPropertyHost)=>boolean checkHost) {
		val context = new CodeContext
		val rootTag = prefix.toFirstUpper
		val deployed = '''FDeployedRootElement<«rootClass.simpleName»>'''
		val methods =
			'''
				«FOR d : spec.declarations»
					«d.genProperties(checkHost, context)»
				«ENDFOR»
			'''

		'''
			/**
			 * Accessor for deployment properties for '«prefix»' roots
			 * (which are defined by the '«extensionName»' extension)
			 * according to the '«spec.name»' specification.
			 */
			public static class «rootTag»PropertyAccessor
				«IF spec.base!==null»extends «spec.base.qualifiedClassname».«rootTag»PropertyAccessor«ENDIF»
				implements Enums
			{
				«IF context.targetNeeded»
				final private «deployed» target;
				«ENDIF»				
			
				«addNeededOtherType(FDeployedRootElement)»
				«addNeededFrancaType(rootClass)»
				public «rootTag»PropertyAccessor(«deployed» target) {
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
	
	def private genProperties(FDDeclaration decl, (FDPropertyHost)=>boolean checkHost, ICodeContext context) '''
		«IF decl.properties.size > 0 && checkHost.apply(decl.host)»
			// host '«decl.host.getName»'
			«FOR p : decl.properties»
			«p.genProperty(decl.host, context)»
			«ENDFOR»
			
		«ENDIF»
	'''
	
	def private genProperty(FDPropertyDecl it, FDPropertyHost host, ICodeContext context) {
		val argumentType = host.getArgumentType(HostLogic.Context.NON_FRANCA)
		if (argumentType!==null) {
			addNeededFrancaType(argumentType)
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
				helper.generateEnumMethod(it, argumentType, enumType, retType, enumerator)
			} else {
				helper.generateMethod(it, argumentType)
			}
		} else
			""
	}
	

}

