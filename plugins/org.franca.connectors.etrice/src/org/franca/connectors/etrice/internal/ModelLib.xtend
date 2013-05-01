/*******************************************************************************
 * Copyright (c) 2012 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.connectors.etrice.internal

import java.io.IOException
import java.util.Collections
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.etrice.core.room.RoomModel
import org.eclipse.etrice.core.room.Import
import java.util.List

import static extension org.franca.connectors.etrice.internal.RoomModelBuilder.*
import org.eclipse.etrice.core.room.ProtocolClass

/**
 * Representation of eTrice modellib during transformation.
 * 
 * @author: Klaus Birken (itemis)
 */
class ModelLib {
	
	String uriTypes
	RoomModel modelTypes
	
	String uriTimingService
	RoomModel modelTimingService

	def init (String uriModelLib, ResourceSet resourceSet) {
		uriTypes = uriModelLib + "/Types.room"
		uriTimingService = uriModelLib + "/TimingService.room"

		modelTypes = resourceSet.loadRoomModel(uriTypes)
		modelTimingService = resourceSet.loadRoomModel(uriTimingService)
		
		val List<Import> imports = newArrayList
		imports.add(createImport("room.basic.types.*", uriTypes))
		imports.add(createImport("room.basic.service.timing.*", uriTimingService))
		return imports
		
	}

	def getPTimerProtocol() {
		modelTimingService.protocolClasses.findFirst[name.equals("PTimer")] as ProtocolClass
	}

	def getTimingServiceActor() {
		modelTimingService.actorClasses.findFirst[name.equals("ATimingService")]
	}
	
	def getTimerSPPRef() {
		timingServiceActor.ifSPPs.findFirst[name.equals("timer")]
	}

	def private loadRoomModel (ResourceSet resourceSet, String uri) {
		var Resource resource = null
		try {
			resource = resourceSet.getResource(URI::createFileURI(uri), true)
			resource.load(Collections::EMPTY_MAP)
		} catch (IOException e) {
			e.printStackTrace
			return null
		}
		return resource.contents.get(0) as RoomModel
	}


}

