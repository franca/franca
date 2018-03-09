package org.franca.core.dsl.tests.ui

import org.eclipse.core.resources.IFile
import org.eclipse.core.resources.IMarker
import org.eclipse.core.resources.IProject
import org.eclipse.core.resources.IResource
import org.eclipse.core.runtime.CoreException
import org.eclipse.xtext.junit4.ui.util.IResourcesSetupUtil
import org.eclipse.xtext.junit4.ui.util.JavaProjectSetupUtil
import org.eclipse.xtext.ui.XtextProjectHelper
import org.junit.AfterClass
import org.junit.BeforeClass

import static org.junit.Assert.*

class AbstractMarkerTest {
	protected static IProject sampleProject;
	
	@BeforeClass
	def static void beforeClass() throws Exception {
		sampleProject = JavaProjectSetupUtil::createSimpleProject("sample");
		IResourcesSetupUtil::addNature(sampleProject, XtextProjectHelper::NATURE_ID);
	}

	@AfterClass
	def static void afterClass() throws Exception {
		sampleProject.delete(true, null);
	}
	
	def lineNumer(IMarker m){m.getAttribute(IMarker::LINE_NUMBER) as Integer}
	def message(IMarker m){m.getAttribute(IMarker::MESSAGE) as String}
	
	def getMarkers(IFile file) throws CoreException {
		IResourcesSetupUtil::waitForAutoBuild();
		return file.findMarkers(null, true, IResource::DEPTH_ZERO);
	}
	
	def toString(IMarker[] markers){
		return '''«markers.map['''«getAttribute(IMarker::LINE_NUMBER)» : «getAttribute(IMarker::MESSAGE)»]'''].join(", ")»]'''
	}

	
	def void assertMarkerExists(IFile file, int line, String messageSubString) throws CoreException {
		for(IMarker m: file.markers){
			if(m.lineNumer.equals(line) && m.message.contains(messageSubString)){
				return
			}
		}
		fail('''Couldn't find message '«messageSubString»@«line»' within Â«file.markers»''')	
	}
	
}

@Data class ExpectedMarker {
	int lineNo
	String message
}