/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.deploymodel.dsl.tests.memcompiler

class ClassAnalyzer {
	var Class<?> classUnderAnalyzation
	new (Class<?> c){
		classUnderAnalyzation = c;
	}
	def methodsByName(String name){
		allMethods.filter[it.name.equals(name)]
	}
	def allMethods(){
		classUnderAnalyzation.declaredMethods
	}
	def allMethodNames(){
		allMethods.map[name]
	}


}