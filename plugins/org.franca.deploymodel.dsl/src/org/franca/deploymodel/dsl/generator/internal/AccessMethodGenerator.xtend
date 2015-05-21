package org.franca.deploymodel.dsl.generator.internal

import com.google.inject.Inject
import org.franca.deploymodel.dsl.fDeploy.FDDeclaration
import org.franca.deploymodel.dsl.fDeploy.FDEnumType
import org.franca.deploymodel.dsl.fDeploy.FDPropertyDecl
import org.franca.deploymodel.dsl.fDeploy.FDPropertyHost
import org.franca.deploymodel.dsl.fDeploy.FDSpecification

import static extension org.franca.deploymodel.dsl.generator.internal.GeneratorHelper.*
import static extension org.franca.deploymodel.dsl.generator.internal.HostLogic.*

abstract class AccessMethodGenerator {

	@Inject extension ImportManager
	
	def generateAccessMethods (FDSpecification spec, boolean forInterfaces) '''
		«FOR d : spec.declarations»
			«d.genProperties(forInterfaces)»
		«ENDFOR»
	'''

	abstract def protected CharSequence genMethod(
		FDPropertyDecl it,
		String francaType,
		boolean isData
	)
	
	abstract def protected CharSequence genEnumMethod(
		FDPropertyDecl it,
		String francaType,
		String enumType,
		String returnType,
		FDEnumType enumerator,
		boolean isData
	)


	def private genProperties(FDDeclaration decl, boolean forInterfaces) '''
		«IF decl.properties.size > 0 && decl.host.getFrancaType(forInterfaces)!=null»
			// host '«decl.host.getName»'
			«FOR p : decl.properties»
			«p.genProperty(decl.host, forInterfaces)»
			«ENDFOR»
			
		«ENDIF»
	'''
	
	def private genProperty(FDPropertyDecl pd, FDPropertyHost host, boolean forInterfaces) {
		if (host==FDPropertyHost::ARRAYS) {
			// special handling for ARRAYS,
			// might be explicit array types or inline arrays
			'''
				«genProperty(pd, host, "FArrayType", false)»
				«genProperty(pd, host, "FField", false)»
				«IF forInterfaces»
				«genProperty(pd, host, "FAttribute", true)»
				«genProperty(pd, host, "FArgument", true)»
				«ENDIF»
			'''
		} else {
			val ftype = host.getFrancaType(forInterfaces)
			genProperty(pd, host, ftype, false)
		}
	}
	

	def private genProperty(
		FDPropertyDecl it,
		FDPropertyHost host,
		String francaType,
		boolean forceInterfaceOnly
	) {
		addNeededFrancaType(francaType)
		val isOnlyForInterface = forceInterfaceOnly || host.isInterfaceOnly 
		if (francaType!=null) {
			if (isEnum) {
				val enumType = name.toFirstUpper
				val retType =
					if (type.array==null) {
						enumType
					} else {
						enumType.genListType.toString
					}
				val enumerator = type.complex as FDEnumType
				genEnumMethod(francaType, enumType, retType, enumerator, !isOnlyForInterface)
			} else {
				genMethod(francaType, !isOnlyForInterface)
			}
		} else
			""
	}


	/**
	 * Generate javadoc helptext for getOverwriteAccessor methods.
	 * 
	 * @param typename the typename of the method's parameter
	 * @param objname the name of the method's parameter
	 */
	def protected genHelpForGetOverwriteAccessor(String typename, String objname) '''
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
