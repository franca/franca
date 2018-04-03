/*******************************************************************************
* Copyright (c) 2015 itemis AG (http://www.itemis.de).
* All rights reserved. This program and the accompanying materials
* are made available under the terms of the Eclipse Public License v1.0
* which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/epl-v10.html
*******************************************************************************/
package org.franca.deploymodel.dsl.generator.internal

import com.google.common.collect.Sets
import com.google.inject.Singleton
import java.util.Set
import org.eclipse.emf.ecore.EObject
import org.franca.core.franca.FInterface
import org.franca.deploymodel.dsl.fDeploy.FDEnumType
import org.franca.deploymodel.dsl.fDeploy.FDExtensionType
import org.franca.deploymodel.dsl.fDeploy.FDPredefinedTypeId
import org.franca.deploymodel.dsl.fDeploy.FDTypeRef
import org.franca.deploymodel.extensions.ExtensionRegistry

@Singleton
class ImportManager {

	Set<Class<? extends EObject>> neededFrancaTypes
	Set<Class<?>> neededOtherTypes
	
	boolean needList
	boolean needArrayList

	def initImportManager() {
		// initialize
		neededFrancaTypes = newHashSet
		neededOtherTypes = newHashSet
		needList = false
		needArrayList = false
	}	

	def getJavaType(FDTypeRef typeRef) {
		val single =
			if (typeRef.complex===null) {
				switch (typeRef.predefined) {
					case FDPredefinedTypeId::BOOLEAN:    "Boolean"
					case FDPredefinedTypeId::INTEGER:    "Integer"
					case FDPredefinedTypeId::STRING:     "String"
					case FDPredefinedTypeId::INTERFACE:  {
						neededFrancaTypes.add(FInterface)
						"FInterface"
					}
				}
			} else {
				val ct = typeRef.complex
				switch (ct) {
					FDEnumType: "String"
					FDExtensionType: {
						val typeDef = ExtensionRegistry.findType(ct.name)
						val t = typeDef.runtimeType
						neededFrancaTypes.add(t)
						t.simpleName
					}
				}
			}
		if (typeRef.array===null)
			single
		else {
			needList = true
			single.genListType
		}
	}
	
	def void addNeededFrancaType(Class<? extends EObject> clazz) {
		neededFrancaTypes.add(clazz)
	}
	
	def void addNeededOtherType(Class<?> clazz) {
		neededOtherTypes.add(clazz)
	}
	
	def genListType (String type) {
		setNeedArrayList
		'''List<«type»>'''
	}

	def setNeedArrayList() {
		this.needArrayList = true
	}

	def needList() {
		this.needList
	}
	
	def getNeededFrancaTypes() {
		this.neededFrancaTypes.map[simpleName]
	}
	
	def genImports() '''
		«IF needList»
		import java.util.List;
		import java.util.ArrayList;
		«ENDIF»
		import java.util.Map;

		«FOR p : Sets.union(neededFrancaTypes, neededOtherTypes).map[canonicalName].filterNull.sort»
		import «p»;
		«ENDFOR»

		import com.google.common.collect.Maps;
	'''
}
