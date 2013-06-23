/*******************************************************************************
 * Copyright (c) 2012 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.core.ui.addons.contractviewer;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IResourceChangeEvent;
import org.eclipse.core.resources.IResourceChangeListener;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.gef4.zest.core.widgets.Graph;
import org.eclipse.gef4.zest.core.widgets.ZestStyles;
import org.eclipse.gef4.zest.layouts.algorithms.SpringLayoutAlgorithm;
import org.eclipse.swt.SWT;
import org.eclipse.swt.events.SelectionListener;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Display;
import org.eclipse.ui.IPartListener;
import org.eclipse.ui.IWorkbenchPage;
import org.eclipse.ui.PlatformUI;
import org.eclipse.ui.part.ViewPart;
import org.eclipse.xtext.resource.XtextResource;
import org.eclipse.xtext.ui.editor.XtextEditor;
import org.eclipse.xtext.ui.editor.utils.EditorUtils;
import org.eclipse.xtext.util.concurrent.IUnitOfWork;
import org.franca.core.franca.FModel;
import org.franca.core.ui.addons.contractviewer.util.FrancaControlAdapter;
import org.franca.core.ui.addons.contractviewer.util.FrancaEditorPartListener;
import org.franca.core.ui.addons.contractviewer.util.GraphSelectionListener;
import org.franca.core.ui.addons.contractviewer.util.IntermediateFrancaGraphModel;
import org.franca.core.ui.addons.contractviewer.util.ResourceChangeListener;
import org.franca.core.utils.FrancaRecursiveValidator;

import com.google.inject.Inject;
import com.google.inject.Injector;

/**
 * A {@link ViewPart} implementation used to display the Franca contracts in a directed graph form. 
 * 
 * @author Tamas Szabo
 *
 */
public class FrancaContractVisualizerView extends ViewPart {

	private static String viewId = "org.franca.core.ui.addons.contractviewer";
	private XtextEditor activeEditor;
	private IFile activeFile;
	private static FrancaContractVisualizerView instance;
	private FModel activeModel;
	private IntermediateFrancaGraphModel previousIntermediateModel;
	private IntermediateFrancaGraphModel intermediateModel;
	private Graph graph;
	private SelectionListener selectionListener;
	private IPartListener partListener;
	private IResourceChangeListener resourceChangeListener;
	private FrancaControlAdapter controlAdapter;
	public Composite parent;
	private boolean displayLabel;
	
	@Inject
	private Injector injector;
	
	@Inject
	private FrancaRecursiveValidator validator;
	
	public FrancaContractVisualizerView() {
		this.previousIntermediateModel = null;
		this.displayLabel = false;
	}
	
    public static FrancaContractVisualizerView getInstance() {
    	if (instance == null) {
	        IWorkbenchPage activePage = getActivePage();
	        if (activePage != null) {
	            instance = (FrancaContractVisualizerView) activePage.findView(viewId);
	        }
    	}
        return instance;
    }
    
	private static IWorkbenchPage getActivePage() {
		if (PlatformUI.getWorkbench().getActiveWorkbenchWindow() != null) {
			IWorkbenchPage activePage = PlatformUI.getWorkbench().getActiveWorkbenchWindow().getActivePage();
			if (activePage != null) {
				return activePage;
			}
		}
		return null;
	}
	
	@Override
	public void createPartControl(Composite parent) {
		this.parent = parent;
		partListener = new FrancaEditorPartListener();
		resourceChangeListener = new ResourceChangeListener();
		controlAdapter = new FrancaControlAdapter();
		parent.addControlListener(controlAdapter);
		
		IWorkbenchPage activePage = getActivePage();
		if (activePage != null) {
			activePage.addPartListener(partListener);
		}
		ResourcesPlugin.getWorkspace().addResourceChangeListener(resourceChangeListener, IResourceChangeEvent.POST_BUILD);
		
		selectionListener = new GraphSelectionListener();
		injector.injectMembers(selectionListener);
		graph = new Graph(parent, SWT.NONE);
		graph.setLayoutAlgorithm(new SpringLayoutAlgorithm(), false);
		graph.setConnectionStyle(ZestStyles.CONNECTIONS_DIRECTED);
		graph.addSelectionListener(selectionListener);
		activeEditor = EditorUtils.getActiveXtextEditor();
		if (activeEditor != null) {
			activeFile = (IFile) activeEditor.getEditorInput().getAdapter(IFile.class);
		}
		updateModel(false);
	}

	@Override
	public void setFocus() {
		graph.setFocus();
	}
	
	public void applyLayout() {
		this.graph.applyLayout();
	}
	
	public IFile getActiveFile() {
		return activeFile;
	}
	
	public void setActiveFile(IFile activeFile) {
		this.activeFile = activeFile;
	}
	
	public void setActiveEditor(XtextEditor activeEditor) {
		this.activeEditor = activeEditor;
	}
	
	public XtextEditor getActiveEditor() {
		return activeEditor;
	}
	
	public FModel getActiveModel() {
		return activeModel;
	}

	public void updateModel(final boolean forceUpdate) {
		if (activeEditor != null) {
			activeEditor.getDocument().readOnly(new IUnitOfWork.Void<XtextResource>() {
				@Override
				public void process(XtextResource resource) throws Exception {
					if (resource != null) {
						for (EObject obj : resource.getContents()) {
							if (obj instanceof FModel) {
								activeModel = (FModel) obj;
								intermediateModel = new IntermediateFrancaGraphModel(activeModel, displayLabel);
								break;
							}
						}
					}
				}
			});
		}
	
		Display.getDefault().asyncExec(new Runnable() {
			@Override
			public void run() {
				if (forceUpdate || (intermediateModel != null && (previousIntermediateModel == null || !previousIntermediateModel.equals(intermediateModel)))) {
					graph.clear();
					intermediateModel.getGraphNodes(graph);
					intermediateModel.getGraphConnections(graph);
					graph.applyLayout();
					previousIntermediateModel = intermediateModel;
				}
			}
		});
	}
	
	public void invertLabelPresentation() {
		this.displayLabel = !this.displayLabel;
		updateModel(true);
	}
	
	@Override
	public void dispose() {
		IWorkbenchPage activePage = getActivePage();
		if (activePage != null) {
			activePage.removePartListener(partListener);
		}
		ResourcesPlugin.getWorkspace().removeResourceChangeListener(resourceChangeListener);
		if (!parent.isDisposed()) parent.removeControlListener(controlAdapter);
		
		graph.removeSelectionListener(selectionListener);
		clear();
		graph.dispose();
		super.dispose();
	}
	
	public void clear() {
		this.activeEditor = null;
		this.activeFile = null;
		this.activeModel = null;
		this.intermediateModel = null;
		this.previousIntermediateModel = null;
		Display.getDefault().asyncExec(new Runnable() {
			@Override
			public void run() {
				if (!graph.isDisposed()) {
					graph.clear();					
				}
			}
		});
	}
}
