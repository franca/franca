package org.franca.core.framework

import java.io.PrintStream
import org.apache.log4j.Level
import org.apache.log4j.Logger

abstract class AbstractFrancaConnector implements IFrancaConnector {

	protected PrintStream out = System.out
	protected PrintStream err = System.err

	override void setOutputStreams(PrintStream out, PrintStream err) {
		this.out = out
		this.err = err
	}
	
	override void setLogger(Logger logger) {
		this.out = new PrintStream(new LoggingOutputStream(logger, Level.INFO), false)
		this.err = new PrintStream(new LoggingOutputStream(logger, Level.ERROR), false)
	}

}
