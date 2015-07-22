/*******************************************************************************
* Copyright (c) 2015 itemis AG (http://www.itemis.de).
* All rights reserved. This program and the accompanying materials
* are made available under the terms of the Eclipse Public License v1.0
* which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/epl-v10.html
*******************************************************************************/
package org.franca.deploymodel.dsl.generator.internal

import org.franca.deploymodel.dsl.fDeploy.FDEnumType
import org.franca.deploymodel.dsl.fDeploy.FDPredefinedTypeId
import org.franca.deploymodel.dsl.fDeploy.FDTypeRef
import org.franca.deploymodel.dsl.fDeploy.FDPropertyDecl
import org.franca.deploymodel.dsl.fDeploy.FDSpecification

class GeneratorHelper {

	def static getGetter(FDTypeRef typeRef) {
		val single =
			if (typeRef.complex==null) {
				switch (typeRef.predefined) {
					case FDPredefinedTypeId::BOOLEAN:   "Boolean"
					case FDPredefinedTypeId::INTEGER:   "Integer"
					case FDPredefinedTypeId::STRING:    "String"
					case FDPredefinedTypeId::INTERFACE: "Interface"
					case FDPredefinedTypeId::INSTANCE:  "InterfaceInstance"
				}
			} else {
				switch (typeRef.complex) {
					FDEnumType: "Enum"
				}
			}
		if (typeRef.array==null)
			single
		else
			single + "Array"
	}
	
	def static hasEnumType(FDPropertyDecl decl) {
		val t = decl.type.complex
		t!=null && (t instanceof FDEnumType)
	}

	def static isEnum(FDPropertyDecl it) {
		type.complex!=null && type.complex instanceof FDEnumType
	}

	def static genListType(String type) '''List<«type»>'''
	
	def static getMethodName(FDPropertyDecl it) '''get«name.toFirstUpper»'''

	def static getPackage (FDSpecification it) {
		val sep = name.lastIndexOf(".")
		if (sep>0)
			name.substring(0, sep)
		else
			""
	}

	def static classname (FDSpecification it) {
		val sep = name.lastIndexOf(".")
		val basename = if (sep>0) name.substring(sep+1) else name
		basename.toFirstUpper
	}

	def static getQualifiedClassname(FDSpecification it) {
		val p = package
		if (p.empty)
			classname
		else
			p + "." + classname
	}

}
