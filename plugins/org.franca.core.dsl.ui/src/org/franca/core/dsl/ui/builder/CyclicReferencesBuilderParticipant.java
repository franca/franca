package org.franca.core.dsl.ui.builder;

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Set;

import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;
import org.eclipse.xtext.builder.IXtextBuilderParticipant;
import org.eclipse.xtext.resource.IEObjectDescription;
import org.eclipse.xtext.resource.IResourceDescription;
import org.eclipse.xtext.resource.IResourceDescription.Delta;
import org.eclipse.xtext.resource.IResourceDescriptions;
import org.eclipse.xtext.ui.editor.validation.MarkerCreator;
import org.eclipse.xtext.ui.editor.validation.MarkerIssueProcessor;
import org.eclipse.xtext.ui.validation.MarkerTypeProvider;
import org.eclipse.xtext.util.CancelIndicator;
import org.eclipse.xtext.validation.CheckMode;
import org.eclipse.xtext.validation.IResourceValidator;
import org.eclipse.xtext.validation.Issue;
import org.franca.core.dsl.resource.FrancaCoreEObjectDescriptions;
import org.franca.core.franca.FrancaPackage;
import org.franca.core.utils.digraph.Digraph;
import org.franca.core.utils.digraph.Digraph.HasCyclesException;
import org.franca.core.utils.digraph.Digraph.NotExistingEdge;
import org.franca.core.utils.digraph.Edge;

import com.google.inject.Inject;

/**
 * This Participant triggers the Xtext-Validation for eResources which aren't part of the delta, but are part of at least one cycle of importURI-references
 * covering (a part of) the delta.<br/>
 * Purpose is to add/remove errormarkers to/from those resources which are affected indirectly if another resources closes/removes such dependency cycles.
 * 
 * @author holzer
 */
public class CyclicReferencesBuilderParticipant implements IXtextBuilderParticipant {
	@Inject
	private IResourceDescriptions resourceDescriptions;

	@Inject
	IResourceValidator resValidator;

	@Inject
	MarkerCreator markerCreator;

	@Inject
	MarkerTypeProvider markerTypeProvider;

	@Override
	public void build(IBuildContext context, final IProgressMonitor monitor) throws CoreException {
		Set<URI> urisFromCycles = analyzeImportUriCycles(context.getDeltas());
		if (urisFromCycles != null) {
			for (URI u : urisFromCycles) {
				if (u.isPlatformResource()) {
					String platformString = u.toPlatformString(true);
					IResource member = ResourcesPlugin.getWorkspace().getRoot().findMember(platformString);
					// First idea was to simply touch the member.
					// For some reason, a touch did not trigger a build/validation of the member
					// Hence, we duplicated the code of org.eclipse.xtext.ui.editor.validation.ValidationJob.run(IProgressMonitor)
					if (member != null) {
						Resource resource = new ResourceSetImpl().getResource(u, true);
						List<Issue> issues = resValidator.validate(resource, CheckMode.ALL, new CancelIndicator() {
							public boolean isCanceled() {
								return monitor.isCanceled();
							}
						});
						MarkerIssueProcessor processor = new MarkerIssueProcessor(member, markerCreator, markerTypeProvider);
						processor.processIssues(issues, monitor);
						if (monitor.isCanceled()) {
							return;
						}
					}

				}
			}
		}
	}

	/**
	 * Detetcs importURI-cycles within deltas' EResources (considering both d.getNew() and d.getNew) and returns the URIs of such eResources 
	 * that are part of a cycle but not part of the delta.<br/>
	 * Example 1.: Let's say we have
	 * <ul>
	 * <li/>deltas containing two elements: [old=a.fidl{... import "b.fidl"}]], [new=c.fidl{... import "a.fidl"}]
	 * <li/>we have at least 3 resources in the workspace: a.fidl (which according to deltas is about to be deleted), b.fidl{... import "c.fidl"} which is
	 * not in any delta and c.fidl.
	 * </ul>
	 * In that case, this method returns the URIs of {b.fidl}<br/>
	 * 
	 * Example 2.: Let's say we have
	 * <ul>
	 * <li/>deltas containing one element: [[new=a.fidl{... import "b.fidl"}]
	 * <li/>we have resources in the workspace as follows: 
	 *  b.fidl{... import "c.fidl"} and c.fidl{... import "b.fidl"} 
	 * </ul>
	 * In that case, this method returns an emtpy Set because the resources belonging to the cycle and the
	 * resources belonging to the deltas do not intersect.
	 * 
	 */
	protected Set<URI> analyzeImportUriCycles(Collection<Delta> deltas) {
		Digraph<IResourceDescription> diGraph = new Digraph<IResourceDescription>();
		Set<IResourceDescription> alreadyVisited = new HashSet<IResourceDescription>();
		Set<IResourceDescription> directlyImported = new HashSet<IResourceDescription>();
		for (Delta d : deltas) {
			directlyImported.addAll(addToDiGraph(diGraph, d.getNew(), alreadyVisited));
			directlyImported.addAll(addToDiGraph(diGraph, d.getOld(), alreadyVisited));
		}
		while (!directlyImported.isEmpty()) {
			Set<IResourceDescription> directlyImportedNextGen = new HashSet<IResourceDescription>();
			for (IResourceDescription iResourceDescription : directlyImported) {
				directlyImportedNextGen.addAll(addToDiGraph(diGraph, iResourceDescription, alreadyVisited));
			}
			directlyImported = directlyImportedNextGen;
		}
		try {
			diGraph.topoSort();
		} catch (HasCyclesException e) {
			// Step1: Collect all URIs that are part of any cycle
			Set<URI> result = urisFromEdges(diGraph);

			// Step2: Remove the URIs that belong to the delta
			// since they are expected to be validated by Xtext's standard mechanisms
			Set<URI> urisFromDeltas = new HashSet<URI>();
			result.removeAll(urisFromDeltas);
			for (Delta d : deltas) {
				urisFromDeltas.add(d.getUri());
			}

			// Step3: Remove the URIs that are part of cycles
			// which don't interset with deltas' URIs
			removeEdgesIntersectingWithDelta(urisFromDeltas, diGraph);
			try {
				diGraph.topoSort();
			} catch (HasCyclesException inner_e) {
				// cycles after removal of urisFromDeltas don't intersect with delta
				result.removeAll(urisFromEdges(diGraph));
			}
			return result;
		}
		return null;
	}

	protected void removeEdgesIntersectingWithDelta(Set<URI> urisFromDeltas, Digraph<IResourceDescription> diGraph) {
		Iterator<Edge<IResourceDescription>> edgesIt = diGraph.edgesIterator();
		List<Edge<IResourceDescription>> toBeRemoved = new ArrayList<Edge<IResourceDescription>>();
		while (edgesIt.hasNext()) {
			Edge<IResourceDescription> edge = edgesIt.next();
			if (urisFromDeltas.contains(edge.from.value.getURI()) || urisFromDeltas.contains(edge.to.value.getURI())) {
				toBeRemoved.add(edge);
			}
		}
		for (Edge<IResourceDescription> edge : toBeRemoved) {
			try {
				diGraph.removeEdge(edge.from.value, edge.to.value);
			} catch (NotExistingEdge e1) {
				// ignore
			}
		}
	}

	protected Set<URI> urisFromEdges(Digraph<IResourceDescription> diGraph) {
		Set<URI> result = new HashSet<URI>();
		Iterator<Edge<IResourceDescription>> edgesIt = diGraph.edgesIterator();
		while (edgesIt.hasNext()) {
			Edge<IResourceDescription> edge = edgesIt.next();
			result.add(edge.from.value.getURI());
			result.add(edge.to.value.getURI());
		}
		return result;
	}

	/**
	 * Adds those Edges to the Digraph that represent the importUris of desc. Lets say we have resource a.fidl specifying <code>import "b.fidl"</code> In this
	 * case, we add an Edge from the IResourceDescription representing a.fidl to the one representing b.fidl.
	 * 
	 * @param g
	 *            The Digraph
	 * @param desc
	 *            description of importing resource. may be <code>null</code>.
	 * @param alreadyVisited
	 *            IResourceDescriptions whose imports are already reflected in the DiGraph
	 * @return Descriptions that have been imported by <code>desc</code>. Never <code>null</code>.
	 */
	protected List<IResourceDescription> addToDiGraph(Digraph<IResourceDescription> g, IResourceDescription desc, Set<IResourceDescription> alreadyVisited) {
		List<IResourceDescription> result = new ArrayList<IResourceDescription>();
		if (desc == null || !alreadyVisited.add(desc)) {
			return result;
		}
		Iterable<IEObjectDescription> fModels = desc.getExportedObjectsByType(FrancaPackage.eINSTANCE.getFModel());
		for (IEObjectDescription ieObjectDescription : fModels) {
			String stringOfUris = ieObjectDescription.getUserData(FrancaCoreEObjectDescriptions.USER_KEY_IMPORT_URIS);
			if (stringOfUris != null) {
				for (String stringUri : stringOfUris.split(FrancaCoreEObjectDescriptions.SEPARATOR_CHAR)) {
					URI createURI = URI.createURI(stringUri);
					if (createURI.isPlatform()) {
						IResourceDescription importedDescription = resourceDescriptions.getResourceDescription(createURI);
						g.addEdge(desc, importedDescription);
						result.add(importedDescription);
					}
				}
			}
		}
		return result;
	}
}
