package org.franca.deploymodel.dsl.tests.xpect;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IWorkspaceRoot;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.Path;
import org.eclipse.jdt.core.IJavaProject;
import org.eclipse.jdt.core.JavaCore;
import org.eclipse.xtext.junit4.ui.util.JavaProjectSetupUtil;
import org.xpect.xtext.lib.setup.FileSetupContext;
import org.xpect.xtext.lib.setup.workspace.Workspace;
/** Extends Xpect's {@link JavaProject} in order to provide projectReferences as additional feature.<br/>
 * A setup might look like
 * <pre>
	XPECT_SETUP org.franca.deploymodel.dsl.tests.xpect.ui.FrancaDeploymodelXpectUITests
	Workspace{
		JavaProject "libraryproject"{ ...	}
		org.franca.deploymodel.dsl.tests.xpect.JavaProject "sample"{ 
			projectReference = "libraryproject" 
			...
		}
	} 
	END_SETUP
 </pre>
  */ 
public class JavaProject extends org.xpect.xtext.lib.setup.workspace.JavaProject {
	protected List<String> projectReferences = new ArrayList<String>();

	public JavaProject(String name) {
		super(name);
	}

	public JavaProject() {
		super();
	}

	public void addProjectReference(String project) {
		projectReferences.add(project);
	}

	@Override
	public IProject create(FileSetupContext ctx, IWorkspaceRoot container, Workspace.Instance instance)
			throws CoreException, IOException {
		for (String projectRef : projectReferences) {
			IJavaProject javaProject = JavaProjectSetupUtil.findJavaProject(projectRef);
			addClasspathEntry(JavaCore.newProjectEntry(javaProject.getPath().makeAbsolute(), true));
		}
		return super.create(ctx, container, instance);
	}
}
