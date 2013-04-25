package org.franca.core.util.validator.aspect;

import java.io.IOException;
import java.net.URL;
import java.util.HashSet;
import java.util.Set;
import java.util.logging.FileHandler;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.aspectj.lang.Signature;
import org.franca.core.util.validator.TraceElementFormatter;


public aspect TraceAspect {
	
	private Set<String> processed;
	
	public TraceAspect() {
		processed = new HashSet<String>();
	}
	
	pointcut traceMethods() : (call(* *(..)) && !cflow(within(TraceAspect)));
	
	before(): traceMethods() {
		String className = thisJoinPoint.getSourceLocation().getWithinType().getName();
		Logger logger = Logger.getLogger("Trace");
		
		if (!processed.contains(className)) {
			FileHandler handler = null;
			try {
				URL location = thisJoinPoint.getSourceLocation().getWithinType().getProtectionDomain().getCodeSource().getLocation();
				handler = new FileHandler(location.getFile()+className+".trace", 1000, 1, false);
				handler.setFormatter(new TraceElementFormatter());
				logger.addHandler(handler);
				processed.add(className);
			} catch (SecurityException e) {
				e.printStackTrace();
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
		
		Signature sig = thisJoinPoint.getSignature();
        logger.log(Level.INFO, sig.getName());
	}
}
