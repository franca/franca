package org.franca.core.dsl.resource

import org.eclipse.xtext.resource.EObjectDescription
import org.eclipse.emf.ecore.EObject
import org.franca.core.franca.FModel
import com.google.inject.Inject
import org.eclipse.xtext.naming.IQualifiedNameProvider
import org.eclipse.xtext.EcoreUtil2

class FrancaCoreEObjectDescriptions {
	public val static String USER_KEY_IMPORT_URIS = "IMPORT_URIS";
	public val static String SEPARATOR_CHAR = "#";
	
	
	@Inject extension
	IQualifiedNameProvider qualifiedNameProvider;
	
	/** Default-Impl intended for internal reuse */
	def internalCreateDefault(EObject o){
		val qn = o.getFullyQualifiedName
		if(qn!=null){
			return EObjectDescription::create(qn,o)			
		}
		return null
	}
	/** 
	 * Creates a EOBjectDescription. Whether the result has UserKeys depends on the type of the Object 
	 * - thus the dispatch
	 */
	def dispatch create(EObject o){
		o.internalCreateDefault
	}
	/** 
	 * Creates a EOBjectDescription. Whether the result has UserKeys depends on the type of the Object 
	 * - thus the dispatch
	 */
	def dispatch create(FModel m){
		if(m.imports.nullOrEmpty){
			return m.internalCreateDefault
		}
		val qn = m.getFullyQualifiedName
		if(qn!=null){
			val importedResources = m.imports?.map[EcoreUtil2::getResource(m.eResource,importURI)].filterNull
			val importUris = importedResources.map[URI].join(SEPARATOR_CHAR)
			val keys = newHashMap(USER_KEY_IMPORT_URIS -> importUris)
			val result = EObjectDescription::create(qn,m,keys)
			return result
		}
		return null
	}
}