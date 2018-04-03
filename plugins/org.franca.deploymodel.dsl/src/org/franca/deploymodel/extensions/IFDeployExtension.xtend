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
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.scoping.IScope
import org.franca.deploymodel.dsl.fDeploy.FDElement
import org.franca.deploymodel.dsl.fDeploy.FDValue

/** 
 * Extension point which can be used to specify deployment extensions.</p>
 * 
 * @author Klaus Birken (itemis AG)
 */
interface IFDeployExtension {

	/**
	 * Definition of a new deployment host for this extension.</p>
	 */
	static class Host {
		String name
		
		new(String name) { this.name = name }
		
		def String getName() { name }
		
		override String toString() {
			"§" + name + "§"
		}
 	}

	/**
	 * Short description of this extension to be used by the IDE's user interface.</p>
	 */
	def String getShortDescription()

	/**
	 * A common base class for deployment definition roots and elements.</p> 
	 */
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

	/**
	 * Descriptor of a new root element for deployment definitions.</p>
	 */
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

	/**
	 * Descriptor of a new child element for deployment definitions.</p>
	 */
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

	/**
	 * Called by the framework to get the list of new root elements
	 * provided by this deployment definition extension.</p>
	 */
	def Collection<RootDef> getRoots()

	
	static class HostMixinDef {
		public enum AccessorArgumentStyle {
			BY_RULE_CLASS,
			BY_TARGET_FEATURE
		}
		
		val public static CHILD_ELEMENT = "$CHILD_ELEMENT$"
		
		EClass clazz
		AccessorArgumentStyle argumentStyle
		String accessorPrefix
		Collection<Host> hosts
		
		/**
		 * Constructor for mixin which provides additional hosts for Franca IDL concepts.</p>
		 * 
		 * Their properties will be added to existing IDataPropertyAccessor classes.</p>
		 */
		new(EClass clazz, AccessorArgumentStyle argumentStyle, Collection<Host> hosts) {
			this(clazz, argumentStyle, null, hosts)
		}
		
		/**
		 * Constructor for mixin which provides additional hosts for non-Franca concepts.</p>
		 * 
		 * These mixins will get own PropertyAccessor classes (named <em>accessorPrefix</em>PropertyAccessor).</p> 
		 * 
		 * @param accessorPrefix prefix for property accessor class name, or CHILD_ELEMENT if this mixin
		 *                       should be added to other property accessor based on class hierarchy  
		 */
		new(EClass clazz, AccessorArgumentStyle argumentStyle, String accessorPrefix, Collection<Host> hosts) {
			this.clazz = clazz
			this.argumentStyle = argumentStyle
			this.accessorPrefix = accessorPrefix
			this.hosts = hosts
		}
		
		def EClass getHostingClass() { clazz }
		def AccessorArgumentStyle getAccessorArgument() { argumentStyle }
		def Collection<Host> getHosts() { this.hosts }

		def boolean isNonFrancaMixin() {
			accessorPrefix!==null
		}
		
		def String getAccessorRootPrefix() {
			if (accessorPrefix===null || accessorPrefix==CHILD_ELEMENT) {
				null
			} else {
				accessorPrefix
			}
		}
		
		def boolean isChildMixin() {
			accessorPrefix==CHILD_ELEMENT
		}
	}
	
	/**
	 * Called by the framework to get the list of new mixin elements
	 * provided by this deployment extension.</p>
	 */
	def Collection<HostMixinDef> getMixins()

	/**
	 * Descriptor for a new deployment property type.</p>
	 * 
	 * Use this to define additional types of properties, extending the built-in
	 * type system of the deployment DSL (which supports Integer, String, Boolean, etc.).</p>  
	 */
	static class TypeDef {
		String name
		(IScope)=>IScope scopeFunc
		(FDElement)=>FDValue defaultCreator
		Class<? extends EObject> runtimeType
		
		/**
		 * Define a new property type for the deployment DSL.</p>
		 * 
		 * Use this to define additional types of properties, extending the built-in
		 * type system of the deployment DSL (which supports Integer, String, Boolean, etc.).</p>
		 * 
		 * @param name the type name used by the concrete syntax of deployment specifications
		 * @param scopeFunc implementation of scoping for the new type
		 * @param defaultCreator a function which provides a default value (based on a given FDElement context)
		 * @param runtimeType the Java class which will be used to represent this type in the
		 *        generated PropertyAccessor class
		 */
		new(
			String name,
			(IScope)=>IScope scopeFunc,
			(FDElement)=>FDValue defaultCreator, 
			Class<? extends EObject> runtimeType
		) {
			this.name = name
			this.scopeFunc = scopeFunc
			this.defaultCreator = defaultCreator
			this.runtimeType = runtimeType
		}
		
		def String getName() {
			name
		}
		
		def IScope getScope(IScope all) {
			if (scopeFunc===null)
				IScope.NULLSCOPE
			else
				scopeFunc.apply(all)
		}
		
		def FDValue createDefaultValue(FDElement element) {
			defaultCreator?.apply(element)
		}
		
		def Class<? extends EObject> getRuntimeType() {
			runtimeType
		}
	}
	
	/**
	 * Called by the framework to get the list of additional property types
	 * provided by this deployment extension.</p>
	 */
	def Collection<TypeDef> getTypes()
}
