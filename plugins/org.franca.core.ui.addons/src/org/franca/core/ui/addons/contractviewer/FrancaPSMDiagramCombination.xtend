package org.franca.core.ui.addons.contractviewer

import de.cau.cs.kieler.klighd.xtext.UpdateXtextModelKLighDCombination
import de.cau.cs.kieler.core.kivi.triggers.PartTrigger
import de.cau.cs.kieler.core.kivi.triggers.SelectionTrigger

class FrancaPSMDiagramCombination extends UpdateXtextModelKLighDCombination {

	def execute(PartTrigger.PartState es, SelectionTrigger.SelectionState selectionState) {
        // do not react on partStates as well as on selectionStates in case
        //  a view part has been deactivated recently, as an potentially out-dated selection
        //  is currently about to be processed
        // most certainly a "part activated" event will follow and subsequently a further
        //  selection event if the selection of the newly active part is changed, too!
        if (this.latestState==es || es.eventType == PartTrigger.EventType.VIEW_DEACTIVATED) {
           return;
        }		
	}

}
