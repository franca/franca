package org.franca.core.validation.aspect;

import java.util.logging.Formatter;
import java.util.logging.LogRecord;

public class TraceElementFormatter extends Formatter {

	@Override
	public String format(LogRecord record) {
		return record.getMessage();
	}

}
