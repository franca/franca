/*******************************************************************************
 * Copyright (c) 2015 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.deploymodel.dsl.generator.internal

import com.google.inject.Inject
import org.eclipse.emf.ecore.EObject
import org.franca.core.franca.FArgument
import org.franca.core.franca.FArrayType
import org.franca.core.franca.FAttribute
import org.franca.core.franca.FField
import org.franca.deploymodel.core.FDPropertyHost
import org.franca.deploymodel.dsl.fDeploy.FDAbstractExtensionElement
import org.franca.deploymodel.dsl.fDeploy.FDBuiltInPropertyHost
import org.franca.deploymodel.dsl.fDeploy.FDDeclaration
import org.franca.deploymodel.dsl.fDeploy.FDEnumType
import org.franca.deploymodel.dsl.fDeploy.FDPropertyDecl
import org.franca.deploymodel.dsl.fDeploy.FDSpecification

import static extension org.franca.deploymodel.dsl.generator.internal.GeneratorHelper.*
import static extension org.franca.deploymodel.dsl.generator.internal.HostLogic.*

abstract class AccessMethodGenerator {

	@Inject extension ImportManager
	
	def generateAccessMethods(FDSpecification spec, boolean forInterfaces, ICodeContext context) '''
		«FOR d : spec.declarations»
			«d.genProperties(forInterfaces, context)»
		«ENDFOR»
	'''

	abstract def protected CharSequence genMethod(
		FDPropertyDecl it,
		Class<? extends EObject> argumentType,
		boolean isData
	)
	
	abstract def protected CharSequence genEnumMethod(
		FDPropertyDecl it,
		Class<? extends EObject> argumentType,
		String enumType,
		String returnType,
		FDEnumType enumerator,
		boolean isData
	)


	def private genProperties(FDDeclaration decl, boolean forInterfaces, ICodeContext context) {
		val hostContext = getHostContext(forInterfaces)
		val argtype = decl.host.getArgumentType(hostContext)
		if (decl.properties.size > 0 && argtype!==null) {
			val isExtensionClass = FDAbstractExtensionElement.isAssignableFrom(argtype)
			if (! isExtensionClass) {
				return '''
					// host '«decl.host.getName»'
					«FOR p : decl.properties»
					«p.genProperty(decl.host, forInterfaces, context)»
					«ENDFOR»
						
				'''
			}
		}
		""			
	}
	
	def private genProperty(FDPropertyDecl pd, FDPropertyHost host, boolean forInterfaces, ICodeContext context) {
		if (host.isBuiltIn(FDBuiltInPropertyHost::ARRAYS)) {
			// special handling for ARRAYS,
			// might be explicit array types or inline arrays
			'''
				«genProperty(pd, host, FArrayType, false, context)»
				«genProperty(pd, host, FField, false, context)»
				«IF forInterfaces»
				«genProperty(pd, host, FAttribute, true, context)»
				«genProperty(pd, host, FArgument, true, context)»
				«ENDIF»
			'''
		} else {
			val hostContext = getHostContext(forInterfaces)
			val argtype = host.getArgumentType(hostContext)
			genProperty(pd, host, argtype, false, context)
		}
	}
	
	def private getHostContext(boolean forInterfaces) {
		if (forInterfaces)
			HostLogic.Context.FRANCA_INTERFACE
		else
			HostLogic.Context.FRANCA_TYPE
	}

	def private genProperty(
		FDPropertyDecl it,
		FDPropertyHost host,
		Class<? extends EObject> argumentType,
		boolean forceInterfaceOnly,
		ICodeContext context
	) {
		addNeededFrancaType(argumentType)
		val isOnlyForInterface = forceInterfaceOnly || host.isInterfaceOnly 
		if (argumentType!==null) {
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
				genEnumMethod(argumentType, enumType, retType, enumerator, !isOnlyForInterface)
			} else {
				genMethod(argumentType, !isOnlyForInterface)
			}
		} else
			""
	}


	/**
	 * Generate javadoc helptext for getOverwriteAccessor methods.
	 * 
	 * @param argumentType the typename of the method's parameter
	 * @param objname the name of the method's parameter
	 */
	def protected genHelpForGetOverwriteAccessor(Class<? extends EObject> argumentType, String objname) {
		val typename = argumentType.simpleName
		'''
			/**
			 * Get an overwrite-aware accessor for deployment properties.</p>
			 *
			 * This accessor will return overwritten property values in the context 
			 * of a Franca «typename» object. I.e., the «typename» «objname» has a datatype
			 * which can be overwritten in the deployment definition (e.g., Franca array,
			 * struct, union or enumeration). The accessor will return the overwritten values.
			 * If the deployment definition didn't overwrite the value, this accessor will
			 * delegate to its parent accessor.</p>
			 *
			 * @param «objname» a Franca «typename» which is the context for the accessor
			 * @return the overwrite-aware accessor
			 */
		'''
	}

}
