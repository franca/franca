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
import org.franca.deploymodel.dsl.fDeploy.FDPropertyDecl
import org.franca.deploymodel.dsl.fDeploy.FDPropertyHost
import org.franca.deploymodel.dsl.fDeploy.FDSpecification

class OverwriteAccessorGenerator {

	@Inject extension ImportManager
	
	def generate(FDSpecification spec) '''
		/**
		 * Accessor for getting overwritten property values.
		 */		
		public static class OverwriteAccessor implements IDataPropertyAccessor {
		
			final private MappingGenericPropertyAccessor target;
			private final IDataPropertyAccessor delegate;
			
			private final Map<FField, FDFieldOverwrite> mapping;
			private final DataPropertyAccessorHelper helper;
			
			public OverwriteAccessor(
					FDCompoundOverwrites overwrites,
					IDataPropertyAccessor delegate,
					MappingGenericPropertyAccessor genericAccessor)
			{
				this.target = genericAccessor;
				this.delegate = delegate;
				this.helper = new DataPropertyAccessorHelper(genericAccessor, this);
		
				// build mapping
				this.mapping = Maps.newHashMap();
				if (overwrites!=null) {
					List<FDFieldOverwrite> fields = overwrites.getFields();
					for(FDFieldOverwrite f : fields) {
						this.mapping.put(f.getTarget(), f);
					}
				}
			}
		
			«FOR d : spec.declarations»
				«d.genProperties»
			«ENDFOR»
			
			@Override
			public IDataPropertyAccessor getOverwriteAccessor (FField obj) {
				// check if this field is overwritten
				if (mapping.containsKey(obj)) {
					FDFieldOverwrite fo = mapping.get(obj);
					FDCompoundOverwrites overwrites = fo.getOverwrites();
					if (overwrites==null)
						return this; // TODO: correct?
					else
						// TODO: this or delegate?
						return new OverwriteAccessor(overwrites, this, target);
					
				}
				return delegate.getOverwriteAccessor(obj);
			}
		}
	'''


	def private genProperties (FDDeclaration decl) '''
		«FOR p : decl.properties»
		«p.genProperty(decl.host)»
		«ENDFOR»
	'''
	
	def private genProperty (FDPropertyDecl it, FDPropertyHost host) '''
	'''
	
}
