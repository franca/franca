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
		
		public enum Nameable {
			NO_NAME,
			OPTIONAL_NAME,
			MANDATORY_NAME
		}
		
		private String tag;
		private EClass targetClass;
		private Nameable isNameable;
		private Collection<Host> hosts;
		private Collection<ElementDef> children;
		
		public AbstractElementDef(String tag, Nameable isNameable, Collection<Host> hosts) {
			this(tag, null, isNameable, hosts);
		}
		
		public AbstractElementDef(String tag, EClass targetClass, Nameable isNameable, Collection<Host> hosts) {
			this.tag = tag;
			this.targetClass = targetClass;
			this.isNameable = isNameable;
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
		
		public boolean mayHaveName() {
			return isNameable != Nameable.NO_NAME;
		}

		public boolean mustHaveName() {
			return isNameable == Nameable.MANDATORY_NAME;
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
		
		public ElementDef(String tag, Nameable isNameable, Collection<Host> hosts) {
			super(tag, isNameable, hosts);
		}
		
		public ElementDef(String tag, EClass targetClass, Nameable isNameable, Collection<Host> hosts) {
			super(tag, targetClass, isNameable, hosts);
		}
		
		public void setParent(AbstractElementDef parent) {
			this.parent = parent;
		}
	}
	
	class RootDef extends AbstractElementDef {
		// the extension which owns this root
		private IFDeployExtension extension;
		
		public RootDef(IFDeployExtension extension, String tag, Nameable isNameable, Collection<Host> hosts) {
			this(extension, tag, null, isNameable, hosts);
		}

		public RootDef(IFDeployExtension extension, String tag, EClass targetClass, Nameable isNameable, Collection<Host> hosts) {
			super(tag, targetClass, isNameable, hosts);
			this.extension = extension;
		}

		public IFDeployExtension getExtension() {
			return extension;
		}
	}
	
	public Collection<RootDef> getRoots();
}
