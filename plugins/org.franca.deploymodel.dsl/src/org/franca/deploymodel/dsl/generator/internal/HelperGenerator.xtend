/*******************************************************************************
* Copyright (c) 2015 itemis AG (http://www.itemis.de).
* All rights reserved. This program and the accompanying materials
* are made available under the terms of the Eclipse Public License v1.0
* which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/epl-v10.html
*******************************************************************************/
package org.franca.deploymodel.dsl.generator.internal

import com.google.inject.Inject
import org.franca.deploymodel.dsl.fDeploy.FDDeclaration
import org.franca.deploymodel.dsl.fDeploy.FDEnumType
import org.franca.deploymodel.dsl.fDeploy.FDPropertyDecl
import org.franca.deploymodel.dsl.fDeploy.FDPropertyHost
import org.franca.deploymodel.dsl.fDeploy.FDSpecification

class HelperGenerator {

	@Inject extension ImportManager
	
	def generate(FDSpecification spec) '''
		/**
		 * Helper class for data-related property accessors.
		 */		
		public static class DataPropertyAccessorHelper implements Enums
		{
			final private MappingGenericPropertyAccessor target;
			final private IDataPropertyAccessor owner;
			
			public DataPropertyAccessorHelper(
				MappingGenericPropertyAccessor target,
				IDataPropertyAccessor owner
			) {
				this.target = target;
				this.owner = owner;
			}

			«FOR d : spec.declarations»
				«d.genProperties»
			«ENDFOR»
			
			«addNeededFrancaType("FModelElement")»
			protected IDataPropertyAccessor getOverwriteAccessorAux(FModelElement obj) {
				«addNeededFrancaType("FDOverwriteElement")»
				FDOverwriteElement fd = (FDOverwriteElement)target.getFDElement(obj);
				FDTypeOverwrites overwrites = fd.getOverwrites();
				if (overwrites==null)
					return owner;
				else
					return new OverwriteAccessor(overwrites, owner, target);
			}
		}
	'''


	def private genProperties (FDDeclaration decl) '''
		«FOR p : decl.properties»
		«p.genProperty(decl.host)»
		«ENDFOR»
	'''
	
	def private genProperty (FDPropertyDecl it, FDPropertyHost host) '''
		«genEnumConverter»
	'''
	
	def private genEnumConverter(FDPropertyDecl it) {
		if (type.complex!=null && type.complex instanceof FDEnumType) {
			val etname = name.toFirstUpper
			val enumerator = type.complex as FDEnumType
			 
			'''
			public static «etname» convert«etname»(String val) {
				«FOR e : enumerator.enumerators SEPARATOR " else "»
				if (val.equals("«e.name»"))
					return «etname».«e.name»;
				«ENDFOR»
				return null;
			}
			
			'''
		} else {
			""
		}
	}	
}
