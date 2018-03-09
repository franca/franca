package org.franca.core.ui.addons.contractviewer

import com.google.common.collect.ImmutableList
import org.eclipse.elk.core.options.Direction
import org.eclipse.elk.core.options.CoreOptions
import de.cau.cs.kieler.klighd.krendering.extensions.KColorExtensions
import de.cau.cs.kieler.klighd.krendering.extensions.KContainerRenderingExtensions
import de.cau.cs.kieler.klighd.krendering.extensions.KEdgeExtensions
import de.cau.cs.kieler.klighd.krendering.extensions.KLabelExtensions
import de.cau.cs.kieler.klighd.krendering.extensions.KNodeExtensions
import de.cau.cs.kieler.klighd.krendering.extensions.KPolylineExtensions
import de.cau.cs.kieler.klighd.krendering.extensions.KRenderingExtensions
import de.cau.cs.kieler.klighd.kgraph.KNode
import de.cau.cs.kieler.klighd.KlighdConstants
import de.cau.cs.kieler.klighd.SynthesisOption
import de.cau.cs.kieler.klighd.syntheses.AbstractDiagramSynthesis
import de.cau.cs.kieler.klighd.syntheses.DiagramLayoutOptions
import javax.inject.Inject
import org.franca.core.franca.FModel
import org.franca.core.franca.FState
import org.franca.core.franca.FTransition

import static extension org.franca.core.contracts.FEventUtils.*

class FrancaPSMDiagramSynthesis extends AbstractDiagramSynthesis<FModel> {

	@Inject extension KNodeExtensions
	@Inject extension KEdgeExtensions
//	@Inject extension KPortExtensions
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
			specifyLayoutOption(CoreOptions.DIRECTION, ImmutableList.of(Direction.RIGHT, Direction.DOWN)),
			specifyLayoutOption(DiagramLayoutOptions.SPACING, ImmutableList.of(5.0, 80.0))
		)
	}
//			specifyLayoutOption(CoreOptions.EDGE_ROUTING, EdgeRouting.values.sortBy[name]),
//			specifyLayoutOption(CoreOptions.ALGORITHM, null),
    
    
    override KNode transform(FModel model) {
    	val root = model.createNode
    	root.setLayoutOption(CoreOptions.DIRECTION, Direction.RIGHT)
    	
    	root.associateWith(model) => [
    		// check if model contains interfaces
    		if (model.interfaces.empty) {
    			children += createWarningNode(model, "Model without interfaces!")
    		} else {
    			// we display only the first one
		    	val first = model.interfaces.get(0)
		    	
		    	// check if the interface has a contract
	        	val psm = first.contract?.stateGraph
	    		if (psm !== null) {
		        	children += psm.states.map[createStateNode]
		        	children += psm.initial.createInitialStateNode
		        	psm.states.forEach[s |
		        		s.transitions.forEach[createTransitionEdge]
		        	]
	    		} else {
	    			// this interface does not have a PSM
	    			children += createWarningNode(model, "Interface without contract!")
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

	/**
	 * Create a diagram node which represents a warning.</p>
	 * 
	 * This is used if there is no graph which can be rendered.
	 */
	def private createWarningNode(KNode it, Object loc, String text) {
		val bg = "lightgray".color
		return createNode.associateWith(loc) => [
			setNodeSize(80, 20)
			addRoundedRectangle(4, 4) => [
				foreground = "black".color
				background = bg
					addText(text).associateWith(loc) => [
						setSurroundingSpace(2, 0.05f)
						background = bg
					]
			]
		]
	} 
	

}

