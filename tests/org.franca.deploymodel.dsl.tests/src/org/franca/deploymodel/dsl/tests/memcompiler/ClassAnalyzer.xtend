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