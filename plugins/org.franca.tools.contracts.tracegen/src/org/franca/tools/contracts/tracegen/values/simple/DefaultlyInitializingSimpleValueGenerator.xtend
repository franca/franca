/*******************************************************************************
 * Copyright (c) 2013 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.tools.contracts.tracegen.values.simple

import org.franca.core.franca.FBasicTypeId
import java.util.logging.Level
import java.util.logging.Logger

class DefaultlyInitializingSimpleValueGenerator implements SimpleValueGenerator {
	
	override public Object createInitializedSimpleValue(FBasicTypeId id) {
		val name = id.literal
		switch (id) {
			case FBasicTypeId::INT8:    (0 /*as Byte*/)
			case FBasicTypeId::UINT8:   (0 /*as Short*/)
			case FBasicTypeId::INT16:   (0 as Integer)
			case FBasicTypeId::UINT16:  (0 as Integer)
			case FBasicTypeId::INT32:   (0 as Integer)
			case FBasicTypeId::UINT32:  (0 as Integer)
			case FBasicTypeId::INT64:   (0l)
			case FBasicTypeId::UINT64:  (0l)
			case FBasicTypeId::BOOLEAN: (false)
			case FBasicTypeId::STRING:  ("")
			case FBasicTypeId::FLOAT:   (0.0f)
			case FBasicTypeId::DOUBLE:  (0.0d)
			default: {
				Logger::anonymousLogger.log(Level::SEVERE, "Unknown primitive type: '" + name + "'")
				throw new IllegalArgumentException("Unknown primitive type: '" + name + "'\nMaybe the type even was not a primitive one, but a user defined type!")
//				return (0 as Integer)
			}  
		}
	}
}