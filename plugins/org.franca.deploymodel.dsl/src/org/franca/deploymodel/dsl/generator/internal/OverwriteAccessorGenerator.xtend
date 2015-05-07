/*******************************************************************************
* Copyright (c) 2015 itemis AG (http://www.itemis.de).
* All rights reserved. This program and the accompanying materials
* are made available under the terms of the Eclipse Public License v1.0
* which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/epl-v10.html
*******************************************************************************/
package org.franca.deploymodel.dsl.generator.internal

import com.google.inject.Inject
import org.franca.deploymodel.dsl.fDeploy.FDEnumType
import org.franca.deploymodel.dsl.fDeploy.FDPropertyDecl
import org.franca.deploymodel.dsl.fDeploy.FDSpecification

import static extension org.franca.deploymodel.dsl.generator.internal.GeneratorHelper.*

class OverwriteAccessorGenerator extends AccessMethodGenerator {

	@Inject extension ImportManager
	
	def generate(FDSpecification spec) '''
		/**
		 * Accessor for getting overwritten property values.
		 */		
		public static class OverwriteAccessor implements IDataPropertyAccessor {
		
			private final MappingGenericPropertyAccessor target;
			private final IDataPropertyAccessor delegate;
			
			private final FDTypeOverwrites overwrites;
			private final Map<FField, FDField> mappedFields;
			private final Map<FEnumerator, FDEnumValue> mappedEnumerators;
			private final DataPropertyAccessorHelper helper;
		
			public OverwriteAccessor(
					FDTypeOverwrites overwrites,
					IDataPropertyAccessor delegate,
					MappingGenericPropertyAccessor genericAccessor)
			{
				this.target = genericAccessor;
				this.delegate = delegate;
				this.helper = new DataPropertyAccessorHelper(genericAccessor, this);
		
				this.overwrites = overwrites;
				this.mappedFields = Maps.newHashMap();
				this.mappedEnumerators = Maps.newHashMap();
				if (overwrites!=null) {
					if (overwrites instanceof FDCompoundOverwrites) {
						// build mapping for compound fields
						for(FDField f : ((FDCompoundOverwrites)overwrites).getFields()) {
							this.mappedFields.put(f.getTarget(), f);
						}
					}
					if (overwrites instanceof FDEnumerationOverwrites) {
						// build mapping for enumerators
						for(FDEnumValue e : ((FDEnumerationOverwrites)overwrites).getEnumerators()) {
							this.mappedEnumerators.put(e.getTarget(), e);
						}
					}
				}
			}
			
			«spec.generateAccessMethods(false)»
			
			@Override
			public IDataPropertyAccessor getOverwriteAccessor(FField obj) {
				// check if this field is overwritten
				if (mappedFields.containsKey(obj)) {
					FDField fo = mappedFields.get(obj);
					FDTypeOverwrites overwrites = fo.getOverwrites();
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


	override genMethod(
		FDPropertyDecl it,
		String francaType,
		boolean isData
	) '''
		«IF isData»
		@Override
		«ENDIF»
		public «type.javaType» «methodName»(«francaType» obj) {
			«IF francaType=="FEnumerator"»
				// check if this enumerator is overwritten
				if (mappedEnumerators.containsKey(obj)) {
					FDEnumValue fo = mappedEnumerators.get(obj);
					«genOverwriteAccess("fo")»
				}
			«ELSEIF francaType=="FField"»
				// check if this field is overwritten
				if (mappedFields.containsKey(obj)) {
					FDField fo = mappedFields.get(obj);
					«genOverwriteAccess("fo")»
				}
			«ELSE»
				if (overwrites!=null) {
					«genOverwriteAccess("overwrites")»
				}
			«ENDIF»
			return delegate.get«name»(obj);
		}
	'''

	def private genOverwriteAccess(FDPropertyDecl it, String objname) '''
		«type.javaType» v = target.get«type.javaType»(«objname», "«name»");
		if (v!=null)
			return v;
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
		public «returnType» «methodName»(«francaType» obj) {
			// check if this field is overwritten
			if (mappedFields.containsKey(obj)) {
				FDField fo = mappedFields.get(obj);
				String e = target.getEnum(fo, "«enumType»");
				«IF type.array!=null»
				// TODO: handling of arrays
				«ENDIF»
				if (e!=null)
					return helper.convert«name»(e);
			}
			return delegate.get«name»(obj);
		}
	'''

/*
			«IF type.array!=null»
			List<«enumType»> es = new ArrayList<«enumType»>();
			for(String ev : e) {
				«enumType» v = helper.convert«enumType»(ev);
				if (v==null) {
					return null;
				} else {
					es.add(v);
				}
			}
			return es;
			«ELSE»
			return helper.convert«enumType»(e);
			«ENDIF»
 */
	
}
