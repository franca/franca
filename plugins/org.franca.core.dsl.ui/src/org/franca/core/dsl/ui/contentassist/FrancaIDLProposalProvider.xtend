package org.franca.core.dsl.ui.contentassist

import com.google.common.base.Joiner
import com.google.inject.Inject
import java.util.List
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EObject
import org.eclipse.jdt.internal.core.JavaProject
import org.eclipse.jface.text.contentassist.ICompletionProposal
import org.eclipse.xtext.Assignment
import org.eclipse.xtext.resource.IContainer
import org.eclipse.xtext.resource.IResourceDescription
import org.eclipse.xtext.resource.XtextResourceSet
import org.eclipse.xtext.resource.impl.ResourceDescriptionsProvider
import org.eclipse.xtext.ui.editor.contentassist.ConfigurableCompletionProposal
import org.eclipse.xtext.ui.editor.contentassist.ContentAssistContext
import org.eclipse.xtext.ui.editor.contentassist.ICompletionProposalAcceptor
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
		var xtextresourceSet= model.eResource.resourceSet as XtextResourceSet
		var containers = containerManager.getVisibleContainers(descriptionManager.getResourceDescription(model.eResource),provider.getResourceDescriptions(model.eResource))
		
		var classPathContext = xtextresourceSet.classpathURIContext
		if (classPathContext instanceof JavaProject){
			containers.forEach[it.resourceDescriptions.filter[it.URI.toString!=model.eResource.URI.toString].forEach[classpathResources+=it.URI.toClassPathString]]
		}
 
		containers.forEach[it.resourceDescriptions.filter[it.URI.toString!=model.eResource.URI.toString].forEach[platformResources+=it.URI.toString]]
		if(context.prefix=="\"classpath:"){
			classpathResources.forEach[
			it.createProposal(context,acceptor)	
		]
		}
		else if(context.prefix=="\"platform:"){
			platformResources.forEach[
			it.createProposal(context,acceptor)
		]
		}
		else {
		platformResources.forEach[
			it.createProposal(context,acceptor)
		]
		classpathResources.forEach[
			it.createProposal(context,acceptor)	
		]
		}
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

						proposal.replacementLength =  proposal.replaceContextLength
						'''"«name.toString»"'''
				}
				
			}
			
		}
		acceptor.accept(proposal)	
	}



}