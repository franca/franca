package org.franca.core.ui.addons.contractviewer

import com.google.common.collect.ImmutableList
import de.cau.cs.kieler.core.kgraph.KNode
import de.cau.cs.kieler.core.krendering.extensions.KColorExtensions
import de.cau.cs.kieler.core.krendering.extensions.KContainerRenderingExtensions
import de.cau.cs.kieler.core.krendering.extensions.KEdgeExtensions
import de.cau.cs.kieler.core.krendering.extensions.KLabelExtensions
import de.cau.cs.kieler.core.krendering.extensions.KNodeExtensions
import de.cau.cs.kieler.core.krendering.extensions.KPolylineExtensions
import de.cau.cs.kieler.core.krendering.extensions.KRenderingExtensions
import de.cau.cs.kieler.kiml.options.Direction
import de.cau.cs.kieler.kiml.options.EdgeRouting
import de.cau.cs.kieler.kiml.options.LayoutOptions
import de.cau.cs.kieler.klighd.KlighdConstants
import de.cau.cs.kieler.klighd.SynthesisOption
import de.cau.cs.kieler.klighd.syntheses.AbstractDiagramSynthesis
import javax.inject.Inject
import org.franca.core.franca.FModel
import org.franca.core.franca.FState
import org.franca.core.franca.FTransition

import static extension org.franca.core.contracts.FEventUtils.*

class FrancaPSMDiagramSynthesis extends AbstractDiagramSynthesis<FModel> {
    
    @Inject extension KNodeExtensions
    @Inject extension KEdgeExtensions
//    @Inject extension KPortExtensions
    @Inject extension KLabelExtensions
    @Inject extension KRenderingExtensions
    @Inject extension KContainerRenderingExtensions
    @Inject extension KPolylineExtensions
    @Inject extension KColorExtensions
//    extension KRenderingFactory = KRenderingFactory.eINSTANCE
    
	// styling
	val COLOR_NODE = "yellow"
	
	// synthesis options
	val static OPT_SHOW_TRIGGERS = SynthesisOption.createCheckOption("Show triggers", true)
	
 	override getDisplayedSynthesisOptions() {
		ImmutableList.of(OPT_SHOW_TRIGGERS)
	}

 	override getDisplayedLayoutOptions() {
		ImmutableList.of(
			specifyLayoutOption(LayoutOptions.DIRECTION, ImmutableList.of(Direction.RIGHT, Direction.DOWN)),
//			specifyLayoutOption(LayoutOptions.EDGE_ROUTING, EdgeRouting.values.sortBy[name]),
//			specifyLayoutOption(LayoutOptions.ALGORITHM, null),
			specifyLayoutOption(LayoutOptions.SPACING, ImmutableList.of(5, 80))
		)
	}
    
    
    override KNode transform(FModel model) {
    	val root = model.createNode
    	root.associateWith(model) => [
    		// check if model contains interfaces
    		if (! model.interfaces.empty) {
    			// we display only the first one
		    	val first = model.interfaces.get(0)
		    	
		    	// check if the interface has a contract
	    		if (first.contract!=null) {
		        	val psm = first.contract.stateGraph
		        	children += psm.states.map[createStateNode]
		        	children += psm.initial.createInitialStateNode
		        	psm.states.forEach[s |
		        		s.transitions.forEach[createTransitionEdge]
		        	]
	    		}
    		}
    	]
    }

	def private createInitialStateNode(FState s) {
		return createNode => [
			setNodeSize(5, 5)
			
			addEllipse => [
				foreground = "black".color
				background = "black".color
			]
			createEdge => [e |
				e.source = it
				e.target = s.node 
				e.addRoundedBendsPolyline(3).addHeadArrowDecorator
			]
		]
	}
	
	def private createStateNode(FState s) {
		return s.createNode.associateWith(s) => [
			setNodeSize(40, 20)
			addRoundedRectangle(4, 4) => [
				foreground = "black".color
				background = COLOR_NODE.color
				addText(s.name).associateWith(s) => [
					setSurroundingSpace(2, 0.05f)
					background = COLOR_NODE.color
				]
			]
		]
	} 
	
	def private createTransitionEdge(FTransition tr) {
		return tr.createEdge.associateWith(tr) => [
			val from = tr.eContainer as FState
			source = from.node
			target = tr.to.node
			addRoundedBendsPolyline(3).addHeadArrowDecorator
			
			if (OPT_SHOW_TRIGGERS.booleanValue) {
				val n = tr.trigger.event.eventID
//				addCenterEdgeLabel(n, 8, KlighdConstants::DEFAULT_FONT_NAME).associateWith(tr)
				tr.createLabel(it).associateWith(tr).configureCenterEdgeLabel(n, 8, KlighdConstants::DEFAULT_FONT_NAME)
			}
		]
	}   
}

