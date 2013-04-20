package org.franca.core.ui.addons.contractviewer.util;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.IResourceDelta;
import org.eclipse.core.resources.IResourceDeltaVisitor;
import org.franca.core.ui.addons.contractviewer.FrancaContractVisualizerView;

class DeltaVisitor implements IResourceDeltaVisitor {

    public boolean visit(IResourceDelta delta) {
        IResource res = delta.getResource();
        if (res instanceof IFile && delta.getKind() == IResourceDelta.CHANGED) {
            IFile file = (IFile) res;
            FrancaContractVisualizerView view = FrancaContractVisualizerView.getInstance();
            if (view != null) {
            	if (view.getActiveFile().equals(file)) {
            		view.updateModel();
            	}
            }
            return false;
        }
        return true;
    }
}
