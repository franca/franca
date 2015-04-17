/*******************************************************************************
* Copyright (c) 2015 itemis AG (http://www.itemis.de).
* All rights reserved. This program and the accompanying materials
* are made available under the terms of the Eclipse Public License v1.0
* which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/epl-v10.html
*******************************************************************************/
package org.franca.deploymodel.dsl.generator.internal

import com.google.inject.Inject
import org.franca.deploymodel.dsl.fDeploy.FDDeclaration
import org.franca.deploymodel.dsl.fDeploy.FDEnumType
import org.franca.deploymodel.dsl.fDeploy.FDPropertyDecl
import org.franca.deploymodel.dsl.fDeploy.FDPropertyHost
import org.franca.deploymodel.dsl.fDeploy.FDSpecification

import static extension org.franca.deploymodel.dsl.generator.internal.GeneratorHelper.*
import static extension org.franca.deploymodel.dsl.generator.internal.HostLogic.*

class IDataGenerator {

	@Inject extension ImportManager
	
	def generate(FDSpecification spec) '''
		/**
		 * Interface for data deployment properties for '«spec.name»' specification
		 * 
		 * This is the data types related part only.
		 */		
		public interface IDataPropertyAccessor
		{
			«FOR d : spec.declarations»
				«d.genProperties»
			«ENDFOR»
			
			// overwrite-aware accessors
			public IDataPropertyAccessor getOverwriteAccessor (FField obj);
		}
	'''


	def private genProperties (FDDeclaration decl) '''
		«FOR p : decl.properties»
		«p.genProperty(decl.host)»
		«ENDFOR»
	'''
	
	def private genProperty (FDPropertyDecl it, FDPropertyHost host) {
		val ftype = host.getFrancaType(false)
//		val 
//		neededFrancaTypes.add(ftype)
		val etname = name.toFirstUpper
		val lname =
			if (type.array==null) {
				etname
			} else {
				setNeedArrayList
				etname.genListType
			}

		if (ftype!=null)
			'''
				// host '«host.getName»'
				«genEnumDecl»
				public «type.javaType» get«name.toFirstUpper» («ftype» obj);

			'''
		else
			""
	}
	
//	def private getReturnType
	
	def private genEnumDecl(FDPropertyDecl it) {
		if (type.complex!=null && type.complex instanceof FDEnumType) {
			val etname = name.toFirstUpper
			val enumerator = type.complex as FDEnumType
			 
			'''
			public enum «etname» {
				«FOR e : enumerator.enumerators SEPARATOR ", "»«e.name»«ENDFOR»
			}
			'''
		} else {
			""
		}
	}	
}
