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
	
	def genListType (String type) '''List<«type»>'''

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
		// TODO: actually generate needed imports
		import java.util.Map;
		
		import org.eclipse.emf.ecore.EObject;
		import org.example.spec.SpecCompoundHosts.IDataPropertyAccessor.StringProp;
		import org.franca.core.franca.FArgument;
		import org.franca.core.franca.FArrayType;
		import org.franca.core.franca.FAttribute;
		import org.franca.core.franca.FEnumerationType;
		import org.franca.core.franca.FEnumerator;
		import org.franca.core.franca.FField;
		import org.franca.core.franca.FModelElement;
		import org.franca.deploymodel.core.FDeployedInterface;
		import org.franca.deploymodel.core.FDeployedTypeCollection;
		import org.franca.deploymodel.core.MappingGenericPropertyAccessor;
		import org.franca.deploymodel.dsl.fDeploy.FDCompoundOverwrites;
		import org.franca.deploymodel.dsl.fDeploy.FDEnumValue;
		import org.franca.deploymodel.dsl.fDeploy.FDEnumerationOverwrites;
		import org.franca.deploymodel.dsl.fDeploy.FDField;
		import org.franca.deploymodel.dsl.fDeploy.FDOverwriteElement;
		import org.franca.deploymodel.dsl.fDeploy.FDTypeOverwrites;
		
		import com.google.common.collect.Maps;
	'''
/*
		«IF needList»
		import java.util.List;
		import java.util.ArrayList;
		«ENDIF»
		«FOR t : neededFrancaTypes»
		«IF t.equals("EObject")»
		import org.eclipse.emf.ecore.EObject;
		«ELSEIF t.equals("FDProvider") || t.equals("FDInterfaceInstance")»
		import org.franca.deploymodel.dsl.fDeploy.«t»;
		«ELSE»
		import org.franca.core.franca.«t»;
		«ENDIF»
		«ENDFOR»
 */

}
