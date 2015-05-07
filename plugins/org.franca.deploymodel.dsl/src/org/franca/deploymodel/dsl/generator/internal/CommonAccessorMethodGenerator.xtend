package org.franca.deploymodel.dsl.generator.internal

import com.google.inject.Inject
import org.franca.deploymodel.dsl.fDeploy.FDEnumType
import org.franca.deploymodel.dsl.fDeploy.FDPropertyDecl

import static extension org.franca.deploymodel.dsl.generator.internal.GeneratorHelper.*

class CommonAccessorMethodGenerator extends AccessMethodGenerator {

	@Inject extension ImportManager
	
	override genMethod(
		FDPropertyDecl it,
		String francaType,
		boolean isData
	) '''
		«IF isData»
		@Override
		«ENDIF»
		«generateMethod(francaType)»
	'''

	def generateMethod(FDPropertyDecl it, String francaType) '''
		public «type.javaType» «methodName»(«francaType» obj) {
			return target.get«type.getter»(obj, "«name»");
		}
	'''


	override genEnumMethod(
		FDPropertyDecl it,
		String francaType,
		String enumType,
		String returnType,
		FDEnumType enumerator,
		boolean isData
	) '''
		«IF isData»
		@Override
		«ENDIF»
		«generateEnumMethod(francaType, enumType, returnType, enumerator)»
	'''
	
	
	def generateEnumMethod(
		FDPropertyDecl it,
		String francaType,
		String enumType,
		String returnType,
		FDEnumType enumerator
	) '''
		public «returnType» «methodName»(«francaType» obj) {
			«type.javaType» e = target.get«type.getter»(obj, "«enumType»");
			if (e==null) return null;
			«IF type.array!=null»
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