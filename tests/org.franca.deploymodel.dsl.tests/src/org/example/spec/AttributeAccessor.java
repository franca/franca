package org.example.spec;

import java.util.List;
import java.util.Map;

import org.eclipse.emf.ecore.EObject;
import org.franca.core.franca.FField;
import org.franca.deploymodel.core.MappingGenericPropertyAccessor;
import org.franca.deploymodel.dsl.fDeploy.FDAttribute;
import org.franca.deploymodel.dsl.fDeploy.FDCompoundOverwrites;
import org.franca.deploymodel.dsl.fDeploy.FDFieldOverwrite;

import com.google.common.collect.Maps;

public class AttributeAccessor extends AbstractSpecCompoundHostsDataPropertyAccessor {

	private final ISpecCompoundHostsDataPropertyAccessor delegate;
	private final MappingGenericPropertyAccessor genericAccessor;
	
	private final Map<FField, FDFieldOverwrite> mapping;
	
	public AttributeAccessor(
			FDAttribute data,
			ISpecCompoundHostsDataPropertyAccessor delegate,
			MappingGenericPropertyAccessor genericAccessor)
	{
		this.delegate = delegate;
		this.genericAccessor = genericAccessor;

		// build mapping
		this.mapping = Maps.newHashMap();
		FDCompoundOverwrites overwrites = data.getOverwrites();
		if (overwrites!=null) {
			List<FDFieldOverwrite> fields = overwrites.getFields();
			for(FDFieldOverwrite f : fields) {
				this.mapping.put(f.getTarget(), f);
			}
		}
	}
	
	@Override
	public StringProp getStringProp (EObject obj) {
		// check if this field is overwritten
		if (mapping.containsKey(obj)) {
			FDFieldOverwrite fo = mapping.get(obj);
			String e = genericAccessor.getEnum(fo, "StringProp");
			if (e==null) return null;
			return convertStringProp(e);
		} else {
			return delegate.getStringProp(obj);
		}
	}

	@Override
	public Integer getArrayProp (EObject obj) {
		if (mapping.containsKey(obj)) {
			FDFieldOverwrite fo = mapping.get(obj);
			return genericAccessor.getInteger(fo, "ArrayProp");
		} else {
			return delegate.getArrayProp(obj);
		}
	}
	
	@Override
	public Integer getSFieldProp (FField obj) {
		// check if this field is overwritten
		if (mapping.containsKey(obj)) {
			FDFieldOverwrite fo = mapping.get(obj);
			return genericAccessor.getInteger(fo, "SFieldProp");
		} else {
			return delegate.getSFieldProp(obj);
		}
	}

}
