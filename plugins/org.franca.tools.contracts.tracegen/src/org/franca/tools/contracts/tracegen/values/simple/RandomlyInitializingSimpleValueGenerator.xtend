/*******************************************************************************
 * Copyright (c) 2013 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.tools.contracts.tracegen.values.simple

import org.franca.core.franca.FBasicTypeId
import java.util.logging.Logger
import java.util.logging.Level

/**
 * For testing it is more important to test with small values and perhaps the edge cases like Integer::MAX_VALUE
 * if Franca would support constraints for parameters these could be respected here too
 */
class RandomlyInitializingSimpleValueGenerator implements SimpleValueGenerator {
	
	override createInitializedSimpleValue(FBasicTypeId id) {
		// id Franca would support constraints for parameters then these could be respected here too
	val name = id.literal
		switch (id) {
			case FBasicTypeId::INT8:    {
				val limit = randomlyShrink(1l<<7 - 1);
				return randomValue(-limit, limit)
			}
			case FBasicTypeId::UINT8:
				return randomValue(0, randomlyShrink(1l<<8 - 1))
			case FBasicTypeId::INT16: {
				val limit = randomlyShrink(1l<<15 - 1);
				return randomValue(-limit, limit)
			}
			case FBasicTypeId::UINT16:  return randomValue(0, randomlyShrink(1l<<16 - 1))
			case FBasicTypeId::INT32: {
				val limit = randomlyShrink(1l<<31);
				return randomValue(-limit, limit)
			}
			case FBasicTypeId::UINT32:  return randomValue(0, randomlyShrink(1l<<32 - 1))
			case FBasicTypeId::INT64: {
				val limit = randomlyShrink(1l<<63);
				return randomValue(-limit, limit)
			}
			case FBasicTypeId::UINT64:
				return randomValue(0, randomlyShrink(if (Long::SIZE > 64) 1l<<64 - 1 else Long::MAX_VALUE))
			case FBasicTypeId::BOOLEAN:
				return Math::random < 0.5
			case FBasicTypeId::STRING:
				return if (Math::random < 0.5) "" else "TestString"
			case FBasicTypeId::FLOAT:   {
				return randomValue(
					if (doShrink) -5f else Float::MIN_VALUE,
					if (doShrink) 5f else Float::MAX_VALUE
				)
			}
			case FBasicTypeId::DOUBLE: {
				return randomValue(
					if (doShrink) -5f else Double::MIN_VALUE,
					if (doShrink) 5f else Double::MAX_VALUE
				)
			}
			default: {
				Logger::anonymousLogger.log(Level::SEVERE, "Unknown primitive type: '" + name + "'")
				throw new IllegalArgumentException("Unknown primitive type: '" + name + "'\nMaybe the type even was not a primitive one, but a user defined type!")
			}
		}
	}
	
	def private Long randomlyShrink(long originalLimit) {
		if (doShrink) {
			return (if (originalLimit < 0) -1l else 1l) * Math::min(5, Math::abs(originalLimit))
		} else
			return originalLimit
	}
	
	def private Long randomValue(long min, long max) {
		min + Math::round((max-min) * Math::random)
	}
	
	def private Double randomValue(double min, double max) {
		min + (max-min) * Math::random
	}
	
	def private boolean doShrink() {
		Math::random < 0.8
	}
	
}