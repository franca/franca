package org.franca.deploymodel.dsl.tests.ui;

import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;

import org.eclipse.core.resources.IFolder;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IncrementalProjectBuilder;
import org.eclipse.emf.common.util.URI;
import org.eclipse.jdt.core.IClasspathEntry;
import org.eclipse.jdt.core.IJavaProject;
import org.eclipse.jdt.core.JavaCore;
import org.eclipse.xtext.ISetup;
import org.eclipse.xtext.junit4.ui.AbstractContentAssistProcessorTest;
import org.eclipse.xtext.junit4.ui.util.IResourcesSetupUtil;
import org.eclipse.xtext.junit4.ui.util.JavaProjectSetupUtil;
import org.eclipse.xtext.resource.XtextResource;
import org.eclipse.xtext.resource.XtextResourceSet;
import org.eclipse.xtext.ui.XtextProjectHelper;
import org.eclipse.xtext.util.StringInputStream;
import org.franca.deploymodel.dsl.ui.internal.FDeployActivator;
import org.junit.AfterClass;
import org.junit.BeforeClass;
import org.junit.Test;

import com.google.inject.Injector;
@SuppressWarnings("restriction")
public class ContentAssistUITest extends AbstractContentAssistProcessorTest {

	protected static List<IJavaProject> projects = new ArrayList<IJavaProject>();

	@BeforeClass
	public static void beforeClass() throws Exception {
		// Create Library Project
		IJavaProject libraryProject = createFrancaProject("libraryproject");
		IFolder folder = JavaProjectSetupUtil.addSourceFolder(libraryProject, "model");
		folder.getFile("d.fdepl").create(new StringInputStream(""),true,null);
		
		// Create SampleProject
		IJavaProject sampleProject = createFrancaProject("sample");
		folder = JavaProjectSetupUtil.addSourceFolder(sampleProject, "model");
		folder.getFile("a.fdepl").create(new StringInputStream(""),true,null);
		folder.getFile("b.fidl").create(new StringInputStream(""),true,null);
		folder = JavaProjectSetupUtil.addSourceFolder(sampleProject, "anotherModel");
		folder.getFile("c.fdepl").create(new StringInputStream(""),true,null);
		
		// Add Classpath-Dependency SampleProject-->LibraryProject
		IClasspathEntry[] oldEntries= sampleProject.getRawClasspath();
		int nEntries= oldEntries.length;
		IClasspathEntry[] newEntries= new IClasspathEntry[nEntries + 1];
		System.arraycopy(oldEntries, 0, newEntries, 0, nEntries);
		newEntries[nEntries]= JavaCore.newProjectEntry(libraryProject.getPath().makeAbsolute(),true);
		sampleProject.setRawClasspath(newEntries, null);
		sampleProject.getProject().refreshLocal(IProject.DEPTH_INFINITE, null);

		for (IJavaProject p : projects) {
			p.getProject().build(IncrementalProjectBuilder.FULL_BUILD, null);
		}
	}
	
	protected static IJavaProject createFrancaProject(String name) throws Exception {
		IJavaProject result = JavaProjectSetupUtil.createJavaProject(name);
		IResourcesSetupUtil.addNature(result.getProject(), XtextProjectHelper.NATURE_ID);
		projects.add(result);
		return result;
	}
	
	/**
	 * Overrides in order to bend the uri in a way that makes it reside in the sampleProject. <br/>
	 * Background: The builder creating the test (e.g. by <code>super.newBuilder()</code>) 
	 * invokes this method to create the model file.
	 */
	@Override
	protected XtextResource doGetResource(InputStream in, URI uri) throws Exception {
		XtextResourceSet rs = get(XtextResourceSet.class);
		System.out.println("ContentAssistUITest.doGetResource() rs: " + rs.getResources());
		XtextResource resource = (XtextResource) getResourceFactory().createResource(URI.createURI("" +
				"platform:/resource/sample/model/myTestModel.fdepl"));
		rs.getResources().add(resource);
		resource.load(in, null);
		return resource;
	}
	
	@AfterClass
	public static void afterClass() throws Exception {
		for (IJavaProject p : projects) {
			p.getProject().delete(true, null);
		}
	}

	@Override
	public ISetup doGetSetup() {
		return new ISetup() {
			@Override
			public Injector createInjectorAndDoEMFRegistration() {
				return FDeployActivator.getInstance().getInjector(FDeployActivator.ORG_FRANCA_DEPLOYMODEL_DSL_FDEPLOY);
			}
		};
	}

	
	@Test
	public void testEmptyModel() throws Exception {
		String[] expectedSuggestions = new String[]{
				"\"a.fdepl\"", "\"b.fidl\""          // same folder
				,"\"../anotherModel/c.fdepl\""       // different folder, same project
				,"\"platform:/resource/libraryproject/model/d.fdepl\"" // different project
				,"THE_IPBasedIPC_WithAlias", "THE_IpBasedIPC"};        // contributed by plugins
		super.newBuilder().append("import ").assertText(expectedSuggestions);
	}
}
