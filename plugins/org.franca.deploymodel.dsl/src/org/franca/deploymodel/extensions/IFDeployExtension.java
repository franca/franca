/*******************************************************************************
 * Copyright (c) 2018 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.deploymodel.extensions;

import java.util.Collection;

import org.eclipse.emf.ecore.EClass;

import com.google.common.collect.Lists;

/**
 * TODO: Document deployment extensions.
 * 
 * @author Klaus Birken (itemis AG)
 *
 */
public interface IFDeployExtension {

	class Host {
		private String name;
		
		public Host(String name) {
			this.name = name;
		}
		
		public String getName() {
			return name;
		}
	}

	public String getShortDescription();
	
	abstract class AbstractElementDef {
		private String tag;
		private EClass targetClass;
		private Collection<Host> hosts;
		private Collection<ElementDef> children;
		
		public AbstractElementDef(String tag, Collection<Host> hosts) {
			this(tag, null, hosts);
		}
		
		public AbstractElementDef(String tag, EClass targetClass, Collection<Host> hosts) {
			this.tag = tag;
			this.targetClass = targetClass;
			this.hosts = hosts;
			this.children = Lists.newArrayList();
		}
		
		public void addChild(ElementDef child) {
			children.add(child);
			child.setParent(this);
		}

		public String getTag() {
			return tag;
		}
		
		public EClass getTargetClass() {
			return targetClass;
		}
		
		public Collection<Host> getHosts() {
			return hosts;
		}
		
		public Collection<ElementDef> getChildren() {
			return children;
		}
	}
	
	class ElementDef extends AbstractElementDef {

		private AbstractElementDef parent;
		
		public ElementDef(String tag, Collection<Host> hosts) {
			super(tag, hosts);
		}
		
		public ElementDef(String tag, EClass targetClass, Collection<Host> hosts) {
			super(tag, targetClass, hosts);
		}
		
		public void setParent(AbstractElementDef parent) {
			this.parent = parent;
		}
	}
	
	class RootDef extends AbstractElementDef {
		// the extension which owns this root
		private IFDeployExtension extension;
		
		public RootDef(IFDeployExtension extension, String tag, Collection<Host> hosts) {
			this(extension, tag, null, hosts);
		}

		public RootDef(IFDeployExtension extension, String tag, EClass targetClass, Collection<Host> hosts) {
			super(tag, targetClass, hosts);
			this.extension = extension;
		}

		public IFDeployExtension getExtension() {
			return extension;
		}
	}
	
	public Collection<RootDef> getRoots();
}
