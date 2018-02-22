/*******************************************************************************
 * Copyright (c) 2018 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.deploymodel.extensions;

import java.util.Collection;

import com.google.common.collect.ImmutableList;
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
	
	abstract class AbstractElement {
		private String tag;
		private Collection<Host> hosts;
		private Collection<Element> children;
		
		public AbstractElement(String tag, Collection<Host> hosts) {
			this.tag = tag;
			this.hosts = hosts;
			this.children = Lists.newArrayList();
		}
		
		public void addChild(Element child) {
			children.add(child);
			child.setParent(this);
		}

		public String getTag() {
			return tag;
		}
		
		public Collection<Host> getHosts() {
			return hosts;
		}
		
		public Collection<Element> getChildren() {
			return children;
		}
	}
	
	class Element extends AbstractElement {

		private AbstractElement parent;
		
		public Element(String tag, Collection<Host> hosts) {
			super(tag, hosts);
		}
		
		public void setParent(AbstractElement parent) {
			this.parent = parent;
		}
	}
	
	class Root extends AbstractElement {
		// the extension which owns this root
		private IFDeployExtension extension;
		
		public Root(IFDeployExtension extension, String tag, Collection<Host> hosts) {
			super(tag, hosts);
			this.extension = extension;
		}

		public IFDeployExtension getExtension() {
			return extension;
		}
	}
	
	public Collection<Root> getRoots();
}
