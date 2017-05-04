package org.franca.core.framework;

import java.io.IOException;
import java.io.OutputStream;

import org.apache.log4j.Level;
import org.apache.log4j.Logger;

/*
 * An OutputStream which logs to a log4j logger.
 */
public class LoggingOutputStream extends OutputStream {

	/** The target logger. */
    private Logger targetLogger;

    /** Current log level (will be used for subsequent flush() calls). */
    private Level currentLogLevel;

    /**
     * Constructor.
     *
     * @param logger the target logger
     * @param level the initial log level
     */
    public LoggingOutputStream(Logger logger, Level level) {
        this.targetLogger = logger;
        this.currentLogLevel = level;
    }

    /**
     * Change current logging level.
     */
    public void setLevel(Level level) {
        this.currentLogLevel = level;
    }

    /** Buffer which is written on next flush() call. */
    private String buffer = "";
    
    /**
     * Accumulate bytes for writing them to the logger.
     */
    @Override
    public void write(int b) throws IOException {
    	// convert integer to byte to character
        byte[] singleByte = new byte[1];
        singleByte[0] = (byte) (b & 0xff);
        String c = new String(singleByte);
        
        // do not check for property "line.separator" here, because c will be just one character
        // (will not match "\r\n" on Windows)
        if (c.equals("\n")) {
            // automatically flush if end-of-line is detected
            flush();
        } else {
        	if (! c.equals("\r"))
        		buffer += c;
        }
    }

    /**
     * Ensure that current buffer is written to logger.
     */
    @Override
    public void flush() {
    	// skip empty lines
    	if (! buffer.isEmpty()) {
            targetLogger.log(currentLogLevel, buffer);
            buffer = "";
    	}
    }
}
