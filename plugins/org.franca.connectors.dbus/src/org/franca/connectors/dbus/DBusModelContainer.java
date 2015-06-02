/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.connectors.dbus;

import java.util.List;

import model.emf.dbusxml.NodeType;

import org.franca.core.framework.IModelContainer;

import com.google.common.collect.Lists;

public class DBusModelContainer implements IModelContainer {
	private NodeType model = null;
	private List<String> comments = Lists.newArrayList();
	
	public DBusModelContainer (NodeType model) {
		this.model = model;
	}
	
	public NodeType model() {
		return model;
	}
	
	/**
	 * Add a comment line to a D-Bus model.
	 * 
	 * Several lines may be added. This information might be used by downstream
	 * tools which use the D-Bus model and generate code or store it into a 
	 * Introspection file.
	 * 
	 * @param line one line of comment
	 */
	public void addComment(String line) {
		comments.add(line);
	}
	
	/**
	 * Access all comment lines which have been added to the model before.
	 * 
	 * @return the comment lines
	 */
	public Iterable<String> getComments() {
		return comments;
	}

 }
