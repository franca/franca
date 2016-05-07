package org.franca.core.framework

import java.io.PrintStream

abstract class AbstractFrancaConnector implements IFrancaConnector {

	protected PrintStream out = System.out
	protected PrintStream err = System.err

	override void setOutputStreams(PrintStream out, PrintStream err) {
		this.out = out
		this.err = err
	}
	
}