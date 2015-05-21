/*******************************************************************************
* Copyright (c) 2015 itemis AG (http://www.itemis.de).
* All rights reserved. This program and the accompanying materials
* are made available under the terms of the Eclipse Public License v1.0
* which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/epl-v10.html
*******************************************************************************/
package org.franca.deploymodel.dsl.generator.internal

import java.util.HashSet
import java.util.Set
import org.franca.deploymodel.dsl.fDeploy.FDEnumType
import org.franca.deploymodel.dsl.fDeploy.FDPredefinedTypeId
import org.franca.deploymodel.dsl.fDeploy.FDTypeRef
import org.franca.deploymodel.dsl.fDeploy.FDeployPackage

class ImportManager {

	Set<String> neededFrancaTypes
	boolean needList
	boolean needArrayList

	def initImportManager() {
		// initialize
		neededFrancaTypes = new HashSet<String>()
		needList = false
		needArrayList = false
	}	

	def getJavaType (FDTypeRef typeRef) {
		val single =
			if (typeRef.complex==null) {
				switch (typeRef.predefined) {
					case FDPredefinedTypeId::BOOLEAN:    "Boolean"
					case FDPredefinedTypeId::INTEGER:    "Integer"
					case FDPredefinedTypeId::STRING:     "String"
					case FDPredefinedTypeId::INTERFACE:  {
						neededFrancaTypes.add("FInterface")
						"FInterface"
					}
					case FDPredefinedTypeId::INSTANCE:  {
						neededFrancaTypes.add("FDInterfaceInstance")
						"FDInterfaceInstance"
					}
				}
			} else {
				val ct = typeRef.complex
				switch (ct) {
					FDEnumType: "String"
				}
			}
		if (typeRef.array==null)
			single
		else {
			needList = true
			single.genListType
		}
	}
	
	def void addNeededFrancaType(String type) {
		neededFrancaTypes.add(type)
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
		this.neededFrancaTypes
	}
	
	def genImports() '''
		«IF needList»
		import java.util.List;
		import java.util.ArrayList;
		«ENDIF»
		import java.util.Map;

		«FOR p : neededFrancaTypes.map[fullImportPath].sort»
		import «p»;
		«ENDFOR»

		import com.google.common.collect.Maps;
	'''

	def private getFullImportPath(String t) {
		if (t.equals("EObject"))
			"org.eclipse.emf.ecore.EObject"
		else if (t.startsWith("FDeployed") || t=="MappingGenericPropertyAccessor")
			"org.franca.deploymodel.core." + t
		else if (t.isDeploymentType)
			"org.franca.deploymodel.dsl.fDeploy." + t
		else
			"org.franca.core.franca." + t
	}

	def private isDeploymentType(String t) {
		val all = FDeployPackage::eINSTANCE.EClassifiers.map[name]
		all.contains(t)
	}
}
