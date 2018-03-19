/** 
 * Copyright (c) 2018 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package org.franca.deploymodel.extensions

import java.util.Collection
import org.eclipse.emf.ecore.EClass

/** 
 * TODO: Document deployment extensions.
 * 
 * @author Klaus Birken (itemis AG)
 */
interface IFDeployExtension {

	static class Host {
		String name
		new(String name) { this.name = name }
		def String getName() { name }
	}

	def String getShortDescription()

	static abstract class AbstractElementDef {
		public enum Nameable { NO_NAME, OPTIONAL_NAME, MANDATORY_NAME }

		String tag
		EClass targetClass
		Nameable isNameable
		Collection<Host> hosts
		Collection<ElementDef> children

		new(String tag, Nameable isNameable, Collection<Host> hosts) {
			this(tag, null, isNameable, hosts)
		}

		new(String tag, EClass targetClass, Nameable isNameable, Collection<Host> hosts) {
			this.tag = tag
			this.targetClass = targetClass
			this.isNameable = isNameable
			this.hosts = hosts
			this.children = newArrayList
		}

		def void addChild(ElementDef child) {
			children.add(child)
			child.setParent(this)
		}

		def String getTag() { tag }
		def boolean mayHaveName() { isNameable !== Nameable.NO_NAME }
		def boolean mustHaveName() { isNameable === Nameable.MANDATORY_NAME }
		def EClass getTargetClass() { targetClass }
		def Collection<Host> getHosts() { hosts }
		def Collection<ElementDef> getChildren() { children }
	}

	static class ElementDef extends AbstractElementDef {
		AbstractElementDef parent

		new(String tag, Nameable isNameable, Collection<Host> hosts) {
			super(tag, isNameable, hosts)
		}

		new(String tag, EClass targetClass, Nameable isNameable, Collection<Host> hosts) {
			super(tag, targetClass, isNameable, hosts)
		}

		def void setParent(AbstractElementDef parent) {
			this.parent = parent
		}
	}

	static class RootDef extends AbstractElementDef {
		IFDeployExtension ^extension

		new(IFDeployExtension ^extension, String tag, Nameable isNameable, Collection<Host> hosts) {
			this(^extension, tag, null, isNameable, hosts)
		}

		new(IFDeployExtension ^extension, String tag, EClass targetClass, Nameable isNameable, Collection<Host> hosts) {
			super(tag, targetClass, isNameable, hosts)
			this.^extension = ^extension
		}

		def IFDeployExtension getExtension() {
			^extension
		}
	}

	def Collection<RootDef> getRoots()

}
