package org.franca.core.utils;

import java.io.File;

import org.eclipse.emf.mwe2.runtime.workflow.IWorkflowComponent;
import org.eclipse.emf.mwe2.runtime.workflow.IWorkflowContext;

public class IfFileExistsComponent implements IWorkflowComponent {

	String fileName;
	IWorkflowComponent component;

	public IfFileExistsComponent() {
	}

	public void setFileName (String fileName) {
		this.fileName = fileName; 
	}

	public void setComponent (IWorkflowComponent component) {
		this.component = component;
	}

	public boolean evaluate() {
		return new File(fileName).exists();
	}

	@Override
	public void preInvoke() {
		if (evaluate()) {
			component.preInvoke();
		}
	}

	@Override
	public void invoke(IWorkflowContext ctx) {
		if (evaluate()) {
			component.invoke(ctx);
		}
	}

	@Override
	public void postInvoke() {
		if (evaluate()) {
			component.postInvoke();
		}
	}

}

