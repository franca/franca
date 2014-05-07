/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.core.ui.addons.wizard;

import java.util.ArrayList;
import java.util.List;

import org.eclipse.core.resources.IProject;
import org.eclipse.emf.ecore.EClass;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.jface.dialogs.Dialog;
import org.eclipse.swt.SWT;
import org.eclipse.swt.events.KeyAdapter;
import org.eclipse.swt.events.KeyEvent;
import org.eclipse.swt.events.SelectionAdapter;
import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Text;
import org.eclipse.xtext.naming.IQualifiedNameProvider;

import com.google.inject.Injector;

/**
 * A {@link Composite} widget, which can be used to select {@link EObject}
 * instances of a given {@link EClass} type from the Xtext index.
 * 
 * @author Tamas Szabo (itemis AG)
 * 
 */
public class ModelElementSelector extends Composite {

	private Text inputText;
	private Button dialogButton;
	private Button clearButton;
	private EObject value;
	private GridLayout layout;
	private ModelElementSelectorDialog dialog;
	private IQualifiedNameProvider nameProvider;
	private List<IModelElementSelectorListener> listeners;

	public ModelElementSelector(Composite parent, IProject project, EClass type, Injector injector) {
		super(parent, SWT.NONE);
		this.listeners = new ArrayList<IModelElementSelectorListener>();
		this.nameProvider = injector.getInstance(IQualifiedNameProvider.class);
		this.dialog = new ModelElementSelectorDialog(nameProvider);
		injector.injectMembers(dialog);
		this.dialog.initializeElements(project, type);
		this.setFont(parent.getFont());
		this.setBackground(parent.getBackground());
		this.createControls();
	}

	@Override
	protected void checkSubclass() {
	}

	public void addModelElementSelectorListener(IModelElementSelectorListener listener) {
		this.listeners.add(listener);
	}

	public void removeModelElementSelectorListener(IModelElementSelectorListener listener) {
		this.listeners.remove(listener);
	}

	protected void createControls() {
		layout = new GridLayout();
		layout.numColumns = 5;
		layout.marginBottom = 0;
		layout.marginHeight = 0;
		layout.marginLeft = 0;
		layout.marginRight = 0;
		layout.marginTop = 0;
		layout.marginWidth = 0;
		this.setLayout(layout);

		inputText = new Text(this, SWT.LEFT);
		inputText.setEditable(false);
		GridData gridData = new GridData(SWT.FILL, SWT.CENTER, true, true);
		gridData.horizontalSpan = 3;
		inputText.setLayoutData(gridData);

		clearButton = new Button(this, SWT.PUSH);
		clearButton.setText("X");
		gridData = new GridData(SWT.END, SWT.CENTER, false, true);
		gridData.horizontalSpan = 1;
		clearButton.setLayoutData(gridData);

		dialogButton = new Button(this, SWT.PUSH);
		dialogButton.setText("Browse");
		gridData = new GridData(SWT.END, SWT.CENTER, false, true);
		gridData.horizontalSpan = 1;
		dialogButton.setLayoutData(gridData);

		dialogButton.addKeyListener(new KeyAdapter() {
			public void keyReleased(KeyEvent e) {
				if (e.character == '\u001b') { // Escape
					dialog.close();
				}
			}
		});

		dialogButton.addSelectionListener(new SelectionAdapter() {

			public void widgetSelected(SelectionEvent event) {
				if (dialog.open() == Dialog.OK && dialog.getFirstResult() != null) {
					value = (EObject) dialog.getFirstResult();
					inputText.setText(nameProvider.getFullyQualifiedName(value).toString());
					for (IModelElementSelectorListener listener : listeners) {
						listener.selectionChanged(value);
					}
				}
			}
		});

		clearButton.addSelectionListener(new SelectionAdapter() {
			@Override
			public void widgetSelected(SelectionEvent e) {
				value = null;
				inputText.setText("");
				for (IModelElementSelectorListener listener : listeners) {
					listener.selectionChanged(value);
				}
			}
		});
	}

	@Override
	public void dispose() {
		super.dispose();
		if (layout != null) {
			layout = null;
		}
	}

	public EObject getValue() {
		return value;
	}

}
