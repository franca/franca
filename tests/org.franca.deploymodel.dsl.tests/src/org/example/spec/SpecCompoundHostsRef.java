/*******************************************************************************
* This file has been generated by Franca's FDeployGenerator.
* Source: deployment specification 'org.example.spec.SpecCompoundHosts'
*******************************************************************************/
package org.example.spec;

import java.util.List;
import java.util.ArrayList;
import java.util.Map;

import org.eclipse.emf.ecore.EObject;
import org.franca.core.franca.FArgument;
import org.franca.core.franca.FArrayType;
import org.franca.core.franca.FAttribute;
import org.franca.core.franca.FEnumerationType;
import org.franca.core.franca.FEnumerator;
import org.franca.core.franca.FField;
import org.franca.core.franca.FModelElement;
import org.franca.deploymodel.core.FDeployedInterface;
import org.franca.deploymodel.core.FDeployedProvider;
import org.franca.deploymodel.core.FDeployedTypeCollection;
import org.franca.deploymodel.core.MappingGenericPropertyAccessor;
import org.franca.deploymodel.dsl.fDeploy.FDCompoundOverwrites;
import org.franca.deploymodel.dsl.fDeploy.FDEnumValue;
import org.franca.deploymodel.dsl.fDeploy.FDEnumerationOverwrites;
import org.franca.deploymodel.dsl.fDeploy.FDField;
import org.franca.deploymodel.dsl.fDeploy.FDOverwriteElement;
import org.franca.deploymodel.dsl.fDeploy.FDTypeOverwrites;

import com.google.common.collect.Maps;

public class SpecCompoundHostsRef {

	public interface Enums
	{
		public enum StringProp {
			p, q, r, s, t, u, v, w, x, y, z
		}
		 
		public enum StringEnumArrayProp {
			a, b, c
		}
	}
	
	/**
	 * Interface for data deployment properties for 'org.example.spec.SpecCompoundHosts' specification
	 * 
	 * This is the data types related part only.
	 */
	public interface IDataPropertyAccessor
		extends Enums
	{
		// host 'strings'
		public StringProp getStringProp(EObject obj);
		public List<StringEnumArrayProp> getStringEnumArrayProp(EObject obj);
		public List<Integer> getStringIntArrayProp(EObject obj);
		
		// host 'enumerations'
		public Integer getEnumerationProp(FEnumerationType obj);
		
		// host 'enumerators'
		public Integer getEnumeratorProp(FEnumerator obj);
		
		// host 'arrays'
		public Integer getArrayProp(FArrayType obj);
		public Integer getArrayProp(FField obj);
		
		// host 'structs'
		public Integer getStructProp(EObject obj);
		
		// host 'struct_fields'
		public Integer getSFieldProp(FField obj);
		
		// host 'unions'
		public Integer getUnionProp(EObject obj);
		
		// host 'union_fields'
		public Integer getUFieldProp(FField obj);
		
		
		/**
		 * Get an overwrite-aware accessor for deployment properties.</p>
		 *
		 * This accessor will return overwritten property values in the context 
		 * of a Franca FField object. I.e., the FField obj has a datatype
		 * which can be overwritten in the deployment definition (e.g., Franca array,
		 * struct, union or enumeration). The accessor will return the overwritten values.
		 * If the deployment definition didn't overwrite the value, this accessor will
		 * delegate to its parent accessor.</p>
		 *
		 * @param obj a Franca FField which is the context for the accessor
		 * @return the overwrite-aware accessor
		 */
		public IDataPropertyAccessor getOverwriteAccessor(FField obj);
	}

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
	
		public static StringProp convertStringProp(String val) {
			if (val.equals("p"))
				return StringProp.p; else 
			if (val.equals("q"))
				return StringProp.q; else 
			if (val.equals("r"))
				return StringProp.r; else 
			if (val.equals("s"))
				return StringProp.s; else 
			if (val.equals("t"))
				return StringProp.t; else 
			if (val.equals("u"))
				return StringProp.u; else 
			if (val.equals("v"))
				return StringProp.v; else 
			if (val.equals("w"))
				return StringProp.w; else 
			if (val.equals("x"))
				return StringProp.x; else 
			if (val.equals("y"))
				return StringProp.y; else 
			if (val.equals("z"))
				return StringProp.z;
			return null;
		}
		
		public static StringEnumArrayProp convertStringEnumArrayProp(String val) {
			if (val.equals("a"))
				return StringEnumArrayProp.a; else 
			if (val.equals("b"))
				return StringEnumArrayProp.b; else 
			if (val.equals("c"))
				return StringEnumArrayProp.c;
			return null;
		}
		
		
		protected IDataPropertyAccessor getOverwriteAccessorAux(FModelElement obj) {
			FDOverwriteElement fd = (FDOverwriteElement)target.getFDElement(obj);
			FDTypeOverwrites overwrites = fd.getOverwrites();
			if (overwrites==null)
				return owner;
			else
				return new OverwriteAccessor(overwrites, owner, target);
		}
	}

	/**
	 * Accessor for deployment properties for 'org.example.spec.SpecCompoundHosts' specification
	 */		
	public static class TypeCollectionPropertyAccessor
		implements IDataPropertyAccessor
	{
		final private MappingGenericPropertyAccessor target;
		private final DataPropertyAccessorHelper helper;
	
		public TypeCollectionPropertyAccessor(FDeployedTypeCollection target) {
			this.target = target;
			this.helper = new DataPropertyAccessorHelper(target, this);
		}
		
		// host 'strings'
		@Override
		public StringProp getStringProp(EObject obj) {
			String e = target.getEnum(obj, "StringProp");
			if (e==null) return null;
			return DataPropertyAccessorHelper.convertStringProp(e);
		}
		@Override
		public List<StringEnumArrayProp> getStringEnumArrayProp(EObject obj) {
			List<String> e = target.getEnumArray(obj, "StringEnumArrayProp");
			if (e==null) return null;
			List<StringEnumArrayProp> es = new ArrayList<StringEnumArrayProp>();
			for(String ev : e) {
				StringEnumArrayProp v = DataPropertyAccessorHelper.convertStringEnumArrayProp(ev);
				if (v==null) {
					return null;
				} else {
					es.add(v);
				}
			}
			return es;
		}
		@Override
		public List<Integer> getStringIntArrayProp(EObject obj) {
			return target.getIntegerArray(obj, "StringIntArrayProp");
		}
		
		// host 'enumerations'
		@Override
		public Integer getEnumerationProp(FEnumerationType obj) {
			return target.getInteger(obj, "EnumerationProp");
		}
		
		// host 'enumerators'
		@Override
		public Integer getEnumeratorProp(FEnumerator obj) {
			return target.getInteger(obj, "EnumeratorProp");
		}
		
		// host 'arrays'
		@Override
		public Integer getArrayProp(FArrayType obj) {
			return target.getInteger(obj, "ArrayProp");
		}
		@Override
		public Integer getArrayProp(FField obj) {
			return target.getInteger(obj, "ArrayProp");
		}
		
		// host 'structs'
		@Override
		public Integer getStructProp(EObject obj) {
			return target.getInteger(obj, "StructProp");
		}
		
		// host 'struct_fields'
		@Override
		public Integer getSFieldProp(FField obj) {
			return target.getInteger(obj, "SFieldProp");
		}
		
		// host 'unions'
		@Override
		public Integer getUnionProp(EObject obj) {
			return target.getInteger(obj, "UnionProp");
		}
		
		// host 'union_fields'
		@Override
		public Integer getUFieldProp(FField obj) {
			return target.getInteger(obj, "UFieldProp");
		}
		
		
		@Override
		public IDataPropertyAccessor getOverwriteAccessor(FField obj) {
			return helper.getOverwriteAccessorAux(obj);
		}
	}

	/**
	 * Accessor for deployment properties for 'org.example.spec.SpecCompoundHosts' specification.
	 */
	public static class InterfacePropertyAccessor
		implements IDataPropertyAccessor
	{
		final private MappingGenericPropertyAccessor target;
		private final DataPropertyAccessorHelper helper;
	
		public InterfacePropertyAccessor(FDeployedInterface target) {
			this.target = target;
			this.helper = new DataPropertyAccessorHelper(target, this);
		}
		
		// host 'strings'
		@Override
		public StringProp getStringProp(EObject obj) {
			String e = target.getEnum(obj, "StringProp");
			if (e==null) return null;
			return DataPropertyAccessorHelper.convertStringProp(e);
		}
		@Override
		public List<StringEnumArrayProp> getStringEnumArrayProp(EObject obj) {
			List<String> e = target.getEnumArray(obj, "StringEnumArrayProp");
			if (e==null) return null;
			List<StringEnumArrayProp> es = new ArrayList<StringEnumArrayProp>();
			for(String ev : e) {
				StringEnumArrayProp v = DataPropertyAccessorHelper.convertStringEnumArrayProp(ev);
				if (v==null) {
					return null;
				} else {
					es.add(v);
				}
			}
			return es;
		}
		@Override
		public List<Integer> getStringIntArrayProp(EObject obj) {
			return target.getIntegerArray(obj, "StringIntArrayProp");
		}
		
		// host 'attributes'
		public Integer getAttributeProp(FAttribute obj) {
			return target.getInteger(obj, "AttributeProp");
		}
		
		// host 'arguments'
		public Integer getArgumentProp(FArgument obj) {
			return target.getInteger(obj, "ArgumentProp");
		}
		
		// host 'enumerations'
		@Override
		public Integer getEnumerationProp(FEnumerationType obj) {
			return target.getInteger(obj, "EnumerationProp");
		}
		
		// host 'enumerators'
		@Override
		public Integer getEnumeratorProp(FEnumerator obj) {
			return target.getInteger(obj, "EnumeratorProp");
		}
		
		// host 'arrays'
		@Override
		public Integer getArrayProp(FArrayType obj) {
			return target.getInteger(obj, "ArrayProp");
		}
		@Override
		public Integer getArrayProp(FField obj) {
			return target.getInteger(obj, "ArrayProp");
		}
		public Integer getArrayProp(FAttribute obj) {
			return target.getInteger(obj, "ArrayProp");
		}
		public Integer getArrayProp(FArgument obj) {
			return target.getInteger(obj, "ArrayProp");
		}
		
		// host 'structs'
		@Override
		public Integer getStructProp(EObject obj) {
			return target.getInteger(obj, "StructProp");
		}
		
		// host 'struct_fields'
		@Override
		public Integer getSFieldProp(FField obj) {
			return target.getInteger(obj, "SFieldProp");
		}
		
		// host 'unions'
		@Override
		public Integer getUnionProp(EObject obj) {
			return target.getInteger(obj, "UnionProp");
		}
		
		// host 'union_fields'
		@Override
		public Integer getUFieldProp(FField obj) {
			return target.getInteger(obj, "UFieldProp");
		}
		
		
		/**
		 * Get an overwrite-aware accessor for deployment properties.</p>
		 *
		 * This accessor will return overwritten property values in the context 
		 * of a Franca FAttribute object. I.e., the FAttribute obj has a datatype
		 * which can be overwritten in the deployment definition (e.g., Franca array,
		 * struct, union or enumeration). The accessor will return the overwritten values.
		 * If the deployment definition didn't overwrite the value, this accessor will
		 * delegate to its parent accessor.</p>
		 *
		 * @param obj a Franca FAttribute which is the context for the accessor
		 * @return the overwrite-aware accessor
		 */
		public IDataPropertyAccessor getOverwriteAccessor(FAttribute obj) {
			return helper.getOverwriteAccessorAux(obj);
		}
	
		/**
		 * Get an overwrite-aware accessor for deployment properties.</p>
		 *
		 * This accessor will return overwritten property values in the context 
		 * of a Franca FArgument object. I.e., the FArgument obj has a datatype
		 * which can be overwritten in the deployment definition (e.g., Franca array,
		 * struct, union or enumeration). The accessor will return the overwritten values.
		 * If the deployment definition didn't overwrite the value, this accessor will
		 * delegate to its parent accessor.</p>
		 *
		 * @param obj a Franca FArgument which is the context for the accessor
		 * @return the overwrite-aware accessor
		 */
		public IDataPropertyAccessor getOverwriteAccessor(FArgument obj) {
			return helper.getOverwriteAccessorAux(obj);
		}
	
		@Override
		public IDataPropertyAccessor getOverwriteAccessor(FField obj) {
			return helper.getOverwriteAccessorAux(obj);
		}
	}

	/**
	 * Accessor for deployment properties for 'org.example.spec.SpecCompoundHosts' specification.
	 */
	public static class ProviderPropertyAccessor
		implements Enums
	{
		final private FDeployedProvider target;
	
		public ProviderPropertyAccessor(FDeployedProvider target) {
			this.target = target;
		}
		
	}

	/**
	 * Accessor for getting overwritten property values.
	 */		
	public static class OverwriteAccessor
		implements IDataPropertyAccessor
	{
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
		
		// host 'strings'
		@Override
		public StringProp getStringProp(EObject obj) {
			// check if this field is overwritten
			if (mappedFields.containsKey(obj)) {
				FDField fo = mappedFields.get(obj);
				String e = target.getEnum(fo, "StringProp");
				if (e!=null)
					return DataPropertyAccessorHelper.convertStringProp(e);
			}
			return delegate.getStringProp(obj);
		}
		@Override
		public List<StringEnumArrayProp> getStringEnumArrayProp(EObject obj) {
			// check if this field is overwritten
			if (mappedFields.containsKey(obj)) {
				FDField fo = mappedFields.get(obj);
				List<String> e = target.getEnumArray(fo, "StringEnumArrayProp");
				if (e!=null) {
					List<StringEnumArrayProp> es = new ArrayList<StringEnumArrayProp>();
					for(String ev : e) {
						StringEnumArrayProp v = DataPropertyAccessorHelper.convertStringEnumArrayProp(ev);
						if (v!=null) {
							es.add(v);
						}
					}
					return es;
				}
			}
			return delegate.getStringEnumArrayProp(obj);
		}
		@Override
		public List<Integer> getStringIntArrayProp(EObject obj) {
			if (overwrites!=null) {
				List<Integer> v = target.getIntegerArray(overwrites, "StringIntArrayProp");
				if (v!=null)
					return v;
			}
			return delegate.getStringIntArrayProp(obj);
		}
		
		// host 'enumerations'
		@Override
		public Integer getEnumerationProp(FEnumerationType obj) {
			if (overwrites!=null) {
				Integer v = target.getInteger(overwrites, "EnumerationProp");
				if (v!=null)
					return v;
			}
			return delegate.getEnumerationProp(obj);
		}
		
		// host 'enumerators'
		@Override
		public Integer getEnumeratorProp(FEnumerator obj) {
			// check if this enumerator is overwritten
			if (mappedEnumerators.containsKey(obj)) {
				FDEnumValue fo = mappedEnumerators.get(obj);
				Integer v = target.getInteger(fo, "EnumeratorProp");
				if (v!=null)
					return v;
			}
			return delegate.getEnumeratorProp(obj);
		}
		
		// host 'arrays'
		@Override
		public Integer getArrayProp(FArrayType obj) {
			if (overwrites!=null) {
				Integer v = target.getInteger(overwrites, "ArrayProp");
				if (v!=null)
					return v;
			}
			return delegate.getArrayProp(obj);
		}
		@Override
		public Integer getArrayProp(FField obj) {
			// check if this field is overwritten
			if (mappedFields.containsKey(obj)) {
				FDField fo = mappedFields.get(obj);
				Integer v = target.getInteger(fo, "ArrayProp");
				if (v!=null)
					return v;
			}
			return delegate.getArrayProp(obj);
		}
		
		// host 'structs'
		@Override
		public Integer getStructProp(EObject obj) {
			if (overwrites!=null) {
				Integer v = target.getInteger(overwrites, "StructProp");
				if (v!=null)
					return v;
			}
			return delegate.getStructProp(obj);
		}
		
		// host 'struct_fields'
		@Override
		public Integer getSFieldProp(FField obj) {
			// check if this field is overwritten
			if (mappedFields.containsKey(obj)) {
				FDField fo = mappedFields.get(obj);
				Integer v = target.getInteger(fo, "SFieldProp");
				if (v!=null)
					return v;
			}
			return delegate.getSFieldProp(obj);
		}
		
		// host 'unions'
		@Override
		public Integer getUnionProp(EObject obj) {
			if (overwrites!=null) {
				Integer v = target.getInteger(overwrites, "UnionProp");
				if (v!=null)
					return v;
			}
			return delegate.getUnionProp(obj);
		}
		
		// host 'union_fields'
		@Override
		public Integer getUFieldProp(FField obj) {
			// check if this field is overwritten
			if (mappedFields.containsKey(obj)) {
				FDField fo = mappedFields.get(obj);
				Integer v = target.getInteger(fo, "UFieldProp");
				if (v!=null)
					return v;
			}
			return delegate.getUFieldProp(obj);
		}
		
		
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
}
	
