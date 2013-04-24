package org.franca.util.search;

import org.franca.core.franca.FState;
import org.franca.core.franca.FTransition;

/**
 * Represents a trace element in the Franca contract. 
 * A trace element has a start and an end {@link FState} and an associated {@link FTransition} between these states. 
 * 
 * @author Tamas Szabo
 *
 */
public interface TraceElement {

	public String getName();
}
