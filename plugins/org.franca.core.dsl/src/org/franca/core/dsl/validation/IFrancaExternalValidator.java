package org.franca.core.dsl.validation;

import org.eclipse.xtext.validation.ValidationMessageAcceptor;
import org.franca.core.franca.FModel;

/**
 * The external validator is used to extend the set of validators used by Franca. 
 * It is possible to define custom validation rules and those will be called 
 * either after the Franca file is saved (FAST and NORMAL mode) or when it is 
 * manually triggered from the context menu of Franca (EXPENSIVE mode).
 * 
 * @author Tamas Szabo (itemis AG)
 *
 */
public interface IFrancaExternalValidator {

	/**
	 * This method is used to perform external validation logic on a given Franca IDL file. 
	 * 
	 * @param model the Franca model created from the IDL file
	 * @param messageAcceptor the message acceptor to log the validation messages
	 */
	public void validateModel(FModel model, ValidationMessageAcceptor messageAcceptor);
	
}
