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
import org.franca.deploymodel.dsl.fDeploy.FDEnumType
import org.franca.deploymodel.dsl.fDeploy.FDPropertyDecl

import static extension org.franca.deploymodel.dsl.generator.internal.GeneratorHelper.*

class CommonAccessorMethodGenerator extends AccessMethodGenerator {

	@Inject extension ImportManager
	
	override genMethod(
		FDPropertyDecl it,
		Class<? extends EObject> argumentType,
		boolean isData
	) '''
		«IF isData»
		@Override
		«ENDIF»
		«generateMethod(argumentType)»
	'''

	def generateMethod(FDPropertyDecl it, Class<? extends EObject> argumentType) '''
		public «type.javaType» «methodName»(«argumentType.simpleName» obj) {
			return target.get«type.getter»(obj, «type.extraArgs»"«name»");
		}
	'''


	override genEnumMethod(
		FDPropertyDecl it,
		Class<? extends EObject> argumentType,
		String enumType,
		String returnType,
		FDEnumType enumerator,
		boolean isData
	) '''
		«IF isData»
		@Override
		«ENDIF»
		«generateEnumMethod(argumentType, enumType, returnType, enumerator)»
	'''
	
	
	def generateEnumMethod(
		FDPropertyDecl it,
		Class<? extends EObject> argumentType,
		String enumType,
		String returnType,
		FDEnumType enumerator
	) '''
		public «returnType» «methodName»(«argumentType.simpleName» obj) {
			«type.javaType» e = target.get«type.getter»(obj, "«enumType»");
			if (e==null) return null;
			«IF type.array!==null»
			List<«enumType»> es = new ArrayList<«enumType»>();
			for(String ev : e) {
				«enumType» v = DataPropertyAccessorHelper.convert«enumType»(ev);
				if (v==null) {
					return null;
				} else {
					es.add(v);
				}
			}
			return es;
			«ELSE»
			return DataPropertyAccessorHelper.convert«enumType»(e);
			«ENDIF»
		}
	'''

}