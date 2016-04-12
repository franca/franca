package org.franca.core.dsl.ui.contentassist

import com.google.inject.Inject
import org.eclipse.emf.ecore.EObject
import org.eclipse.jdt.internal.core.JavaProject
import org.eclipse.xtext.Assignment
import org.eclipse.xtext.resource.IContainer
import org.eclipse.xtext.resource.IResourceDescription
import org.eclipse.xtext.resource.XtextResourceSet
import org.eclipse.xtext.resource.impl.ResourceDescriptionsProvider
import org.eclipse.xtext.scoping.IGlobalScopeProvider
import org.eclipse.xtext.ui.editor.contentassist.ContentAssistContext
import org.eclipse.xtext.ui.editor.contentassist.ICompletionProposalAcceptor
import org.eclipse.emf.common.util.URI
import java.util.List
import com.google.common.base.Joiner
import org.eclipse.xtext.ui.editor.contentassist.ConfigurableCompletionProposal
import org.eclipse.xtext.ui.editor.contentassist.ReplacementTextApplier

class FrancaIDLProposalProvider extends AbstractFrancaIDLProposalProvider {
	
	
	@Inject
	private IResourceDescription.Manager descriptionManager;
	@Inject
	private IContainer.Manager containerManager;
	@Inject
	private ResourceDescriptionsProvider provider;


	override completeImport_ImportURI(EObject model, Assignment assignment, ContentAssistContext context, ICompletionProposalAcceptor acceptor) {
		val platformResources = newArrayList()
		val classpathResources = newArrayList()
		var xtextresource= model.eResource.resourceSet as XtextResourceSet
		var containers = containerManager.getVisibleContainers(descriptionManager.getResourceDescription(model.eResource),provider.getResourceDescriptions(model.eResource))
		
		var classPathContext = xtextresource.classpathURIContext
		if (classPathContext instanceof JavaProject){
			containers.forEach[it.resourceDescriptions.forEach[classpathResources+=it.URI.toClassPathString]]
		}

		containers.forEach[it.resourceDescriptions.forEach[platformResources+=it.URI.toString]]
		
		platformResources.forEach[
			it.createProposal(context,acceptor)
		]
		classpathResources.forEach[
			it.createProposal(context,acceptor)	
		]
		
		super.completeImport_ImportURI(model, assignment, context, acceptor)
		
	}
	
	def toClassPathString(URI uri){
		val segments = uri.segmentsList.classPathSegments
		'''classpath:/«Joiner.on('/').join(segments)»'''.toString
		

	}
	
	def classPathSegments(List<String> list){
		var sublist = list.subList(3,list.size)
		sublist
	}
	
	def createProposal(String name, ContentAssistContext context, ICompletionProposalAcceptor acceptor){
		var proposal  = createCompletionProposal('''«name.toString»''',context)
			if(proposal instanceof ConfigurableCompletionProposal){
			var c = proposal as ConfigurableCompletionProposal
			
			c.textApplier = new ReplacementTextApplier(){
			
				override getActualReplacementString(ConfigurableCompletionProposal proposal) {
						'''"«name.toString»"'''
				}
				
			}
			
		}
		acceptor.accept(proposal)	
	}
	
	
}