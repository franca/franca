/*******************************************************************************
* Copyright (c) 2016 itemis AG (http://www.itemis.de).
* All rights reserved. This program and the accompanying materials
* are made available under the terms of the Eclipse Public License v1.0
* which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/epl-v10.html
*******************************************************************************/
package org.franca.core.framework;

import java.io.PrintStream;

import org.apache.log4j.Logger;
import org.franca.core.franca.FModel;

/**
 * Interface for Franca connector components.<p/>
 * 
 * A <em>Franca connector</em> is an add-on for Franca which allows
 * transformation of models of another interface definition language
 * from/to Franca IDL models.<p/> 
 *  
 * @author Klaus Birken (itemis AG)
 */
public interface IFrancaConnector extends IModelPersistenceManager {

	/**
	 * Convert from non-Franca model to Franca model.<p/>
	 * 
	 * @param model the non-Franca input model
	 * @return the Franca output model
	 */
	public FrancaModelContainer toFranca(IModelContainer model);

	/**
	 * Convert from Franca model to non-Franca model.<p/>
	 * 
	 * @param model the Franca input model
	 * @return the non-Franca output model
	 */
	public IModelContainer fromFranca(FModel fmodel);
	
	/**
	 * Use specific output streams instead of System.out and System.err.<p/>
	 *  
	 * @param out the output stream which should be used by the connector
	 * @param err the error output stream which should be used by the connector 
	 */
	public void setOutputStreams(PrintStream out, PrintStream err);

	/**
	 * Use log4j logger instead of System.out and System.err.<p/>
	 *  
	 * @param logger the log4j logger which should be used by the connector
	 */
	public void setLogger(Logger logger);

}
