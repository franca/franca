package org.franca.core.ui.addons.contractviewer;

import java.lang.ref.WeakReference;
import java.util.Collections;
import java.util.Map;
import java.util.Set;

import org.eclipse.core.resources.IFile;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.gef4.zest.dot.DotGraph;
import org.eclipse.swt.SWT;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Display;
import org.eclipse.ui.IWorkbenchWindow;
import org.eclipse.ui.PlatformUI;
import org.eclipse.ui.part.ViewPart;
import org.eclipse.xtext.resource.XtextResource;
import org.eclipse.xtext.ui.editor.XtextEditor;
import org.eclipse.xtext.util.concurrent.IUnitOfWork;
import org.franca.core.contracts.ContractDotGenerator;
import org.franca.core.franca.FModel;
import org.franca.core.franca.FState;
import org.franca.core.franca.FTransition;

public class FrancaContractVisualizerView extends ViewPart {

	private static String viewId = "org.franca.core.ui.addons.contractviewer";
	private XtextEditor activeEditor;
	private IFile activeFile;
	private static WeakReference<FrancaContractVisualizerView> instance;
	private FModel activeModel;
	private Map<FState, Set<FTransition>> backwardIndex;
	private DotGraph graph;
	private ContractDotGenerator generator;
	
	public FrancaContractVisualizerView() {
		instance = new WeakReference<FrancaContractVisualizerView>(null);
		generator = new ContractDotGenerator();
	}
	
    public static FrancaContractVisualizerView getInstance() {
    	if (instance.get() == null) {
	        IWorkbenchWindow activeWorkbenchWindow = PlatformUI.getWorkbench().getActiveWorkbenchWindow();
	        if (activeWorkbenchWindow != null && activeWorkbenchWindow.getActivePage() != null) {
	            instance = new WeakReference<FrancaContractVisualizerView>((FrancaContractVisualizerView) activeWorkbenchWindow.getActivePage().findView(viewId));
	        }
    	}
        return instance.get();
    }
	
	@Override
	public void createPartControl(Composite parent) {
		graph = new DotGraph(parent, SWT.NONE);
	}

	@Override
	public void setFocus() {
		graph.setFocus();
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
	
	public Map<FState, Set<FTransition>> getBackwardIndex() {
		return Collections.unmodifiableMap(backwardIndex);
	}
	
	public void updateModel() {
		activeEditor.getDocument().readOnly(new IUnitOfWork.Void<XtextResource>() {
			@Override
			public void process(XtextResource resource) throws Exception {
				if (resource != null) {
					for (EObject obj : resource.getContents()) {
						if (obj instanceof FModel) {
							activeModel = (FModel) obj;
						}
					}
				}
			}
		});
		
		if (activeModel != null) {
			final CharSequence dot = generator.generate(activeModel);
			Display.getDefault().asyncExec(new Runnable() {
				@Override
				public void run() {
					graph.clear();
					graph.add(dot.toString());
				}
			});
			
		}
	}
}
