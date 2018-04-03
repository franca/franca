/*******************************************************************************
* Copyright (c) 2015 itemis AG (http://www.itemis.de).
* All rights reserved. This program and the accompanying materials
* are made available under the terms of the Eclipse Public License v1.0
* which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/epl-v10.html
*******************************************************************************/
package org.franca.deploymodel.dsl.generator.internal

import com.google.inject.Inject
import org.eclipse.emf.ecore.EObject
import org.franca.core.franca.FEnumerator
import org.franca.core.franca.FField
import org.franca.deploymodel.core.MappingGenericPropertyAccessor
import org.franca.deploymodel.dsl.fDeploy.FDCompoundOverwrites
import org.franca.deploymodel.dsl.fDeploy.FDEnumType
import org.franca.deploymodel.dsl.fDeploy.FDEnumValue
import org.franca.deploymodel.dsl.fDeploy.FDEnumerationOverwrites
import org.franca.deploymodel.dsl.fDeploy.FDField
import org.franca.deploymodel.dsl.fDeploy.FDPropertyDecl
import org.franca.deploymodel.dsl.fDeploy.FDSpecification
import org.franca.deploymodel.dsl.fDeploy.FDTypeOverwrites

import static extension org.franca.deploymodel.dsl.generator.internal.GeneratorHelper.*

class OverwriteAccessorGenerator extends AccessMethodGenerator {

	@Inject extension ImportManager
	
	def generate(FDSpecification spec) '''
		/**
		 * Accessor for getting overwritten property values.
		 */		
		public static class OverwriteAccessor
			«IF spec.base!==null»extends «spec.base.qualifiedClassname».OverwriteAccessor«ENDIF»
			implements IDataPropertyAccessor
		{
			«addNeededOtherType(MappingGenericPropertyAccessor)»
			private final MappingGenericPropertyAccessor target;
			private final IDataPropertyAccessor delegate;
			
			private final FDTypeOverwrites overwrites;
			«addNeededFrancaType(FField)»
			private final Map<FField, FDField> mappedFields;
			«addNeededFrancaType(FEnumerator)»
			private final Map<FEnumerator, FDEnumValue> mappedEnumerators;
		
			«addNeededFrancaType(FDTypeOverwrites)»
			public OverwriteAccessor(
					FDTypeOverwrites overwrites,
					IDataPropertyAccessor delegate,
					MappingGenericPropertyAccessor genericAccessor)
			{
				«IF spec.base!==null»
				super(overwrites, delegate, genericAccessor);
				«ENDIF»
				this.target = genericAccessor;
				this.delegate = delegate;
		
				this.overwrites = overwrites;
				this.mappedFields = Maps.newHashMap();
				this.mappedEnumerators = Maps.newHashMap();
				if (overwrites!=null) {
					if (overwrites instanceof FDCompoundOverwrites) {
						// build mapping for compound fields
						«addNeededFrancaType(FDField)»
						«addNeededFrancaType(FDCompoundOverwrites)»
						for(FDField f : ((FDCompoundOverwrites)overwrites).getFields()) {
							this.mappedFields.put(f.getTarget(), f);
						}
					}
					if (overwrites instanceof FDEnumerationOverwrites) {
						// build mapping for enumerators
						«addNeededFrancaType(FDEnumValue)»
						«addNeededFrancaType(FDEnumerationOverwrites)»
						for(FDEnumValue e : ((FDEnumerationOverwrites)overwrites).getEnumerators()) {
							this.mappedEnumerators.put(e.getTarget(), e);
						}
					}
				}
			}
			
			«spec.generateAccessMethods(false, new CodeContext)»
			
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

			@Override
			public IDataPropertyAccessor getOverwriteAccessor(FArrayType obj) {
				// check if this array is overwritten
				if (overwrites!=null) {
					// TODO: this or delegate?
					return new OverwriteAccessor(overwrites, this, target);
				}
				return delegate.getOverwriteAccessor(obj);
			}
		}
	'''


	override genMethod(
		FDPropertyDecl it,
		Class<? extends EObject> argumentType,
		boolean isData
	) '''
		«IF isData»
		@Override
		«ENDIF»
		public «type.javaType» «methodName»(«argumentType.simpleName» obj) {
			«IF argumentType==FEnumerator»
				// check if this enumerator is overwritten
				if (mappedEnumerators.containsKey(obj)) {
					FDEnumValue fo = mappedEnumerators.get(obj);
					«genOverwriteAccess("fo")»
				}
			«ELSEIF argumentType==FField»
				// check if this field is overwritten
				if (mappedFields.containsKey(obj)) {
					FDField fo = mappedFields.get(obj);
					«genOverwriteAccess("fo")»
				}
			«ELSEIF argumentType==EObject»
				if (obj instanceof FField) {
					// check if this field is overwritten
					if (mappedFields.containsKey(obj)) {
						FDField fo = mappedFields.get(obj);
						«genOverwriteAccess("fo")»
					}
				} else {
					if (overwrites!=null) {
						// this is some model element which might be overwritten
						«genOverwriteAccess("obj")»
					}
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
		«type.javaType» v = target.get«type.getter»(«objname», «type.extraArgs»"«name»");
		if (v!=null)
			return v;
	'''


	override genEnumMethod(
		FDPropertyDecl it,
		Class<? extends EObject> argumentType,
		String enumType,
		String returnType,
		FDEnumType enumerator,
		boolean isData
	) '''
		«IF isData»
		@Override
		«ENDIF»
		public «returnType» «methodName»(«argumentType.simpleName» obj) {
			«IF argumentType==FEnumerator»
				// check if this enumerator is overwritten
				if (mappedEnumerators.containsKey(obj)) {
					FDEnumValue fo = mappedEnumerators.get(obj);
					«genEnumOverwriteAccess(enumType, "fo")»
				}
			«ELSEIF argumentType==FField»
				// check if this field is overwritten
				if (mappedFields.containsKey(obj)) {
					FDField fo = mappedFields.get(obj);
					«genEnumOverwriteAccess(enumType, "fo")»
				}
			«ELSEIF argumentType==EObject»
				if (obj instanceof FField) {
					// check if this field is overwritten
					if (mappedFields.containsKey(obj)) {
						FDField fo = mappedFields.get(obj);
						«genEnumOverwriteAccess(enumType, "fo")»
					}
				} else {
					if (overwrites!=null) {
						// this is some model element which might be overwritten
						«genEnumOverwriteAccess(enumType, "obj")»
					}
				}
			«ELSE»
				if (overwrites!=null) {
					«genEnumOverwriteAccess(enumType, "overwrites")»
				}
			«ENDIF»
			return delegate.get«name»(obj);
		}
	'''

	def private genEnumOverwriteAccess(
		FDPropertyDecl it,
		String enumType,
		String objname
	) '''
		«type.javaType» e = target.get«type.getter»(«objname», "«enumType»");
		if (e!=null) {
			«IF type.array!==null»
				List<«enumType»> es = new ArrayList<«enumType»>();
				for(String ev : e) {
					«enumType» v = DataPropertyAccessorHelper.convert«name»(ev);
					if (v!=null) {
						es.add(v);
					}
				}
				return es;
			«ELSE»
				return DataPropertyAccessorHelper.convert«name»(e);
			«ENDIF»
		}
	'''
	
}
