/*******************************************************************************
 * Copyright (c) 2013 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.core.utils;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;

import org.eclipse.emf.common.util.URI;

public class FileHelper {

	/**
	 * Helper for saving a text to file
	 *
	 * @param targetDir   the target directory
	 * @param filename    the target filename
	 * @param textToSave  the content for the file
	 * @return true if ok
	 */
	public static boolean save (String targetDir, String filename, String textToSave) {
		// ensure that directory is available
		File dir = new File(targetDir);
		if (! (dir.exists() || dir.mkdirs())) {
			System.err.println("Error: couldn't create directory " + targetDir + "!");
			return false;
		}
		
		// delete file prior to saving
		File file = new File(targetDir + "/" + filename);
		file.delete();
		
		// save contents to file
	    try {
	        BufferedWriter out = new BufferedWriter(new FileWriter(file));
	        out.write(textToSave);
	        out.close();
	        System.out.println("Created file " + file.getAbsolutePath());
	    } catch (IOException e) {
	    	return false;
	    }
	    
	    return true;
	}

	/**
	 * Platform-independent helper to create URIs from file names.
	 * 
	 * Rationale: createFileURI is platform-dependent and doesn't work
	 * for absolute paths on Unix and MacOS. This function provides 
	 * createURI from file paths for Unix, MacOS and Windows.
	 */
	public static URI createURI(String filename) {
		String os = System.getProperty("os.name");
		boolean isWindows = os.startsWith("Windows");
		boolean isUnix = !isWindows; // e.g., MacOS or Linux

		String fname = filename;
		URI uri = URI.createURI(fname);

		// relative paths are interpreted as file paths relative to the current working dir 
		boolean isUnixAbsolutePath = isUnix && fname.startsWith("/");
		if (uri.isRelative() && !isUnixAbsolutePath) {
	    	String cwd = System.getProperty("user.dir");
	    	fname = cwd + File.separator + fname;
	    	uri = URI.createURI(fname);
		}

		if (uri.scheme() != null) {
			// if we are under Windows and s starts with x: it is an absolute path
			if (isWindows && uri.scheme().length() == 1) {
				return URI.createFileURI(fname);
			}
			// otherwise it is a proper URI
			else {
				return uri;
			}
		}
		else if (isUnix && fname.startsWith("/")) { 
			// handle paths that start with / under Unix e.g. /local/foo.txt
			return URI.createFileURI(fname);
		}
		else {
			// otherwise it is a proper URI
			return uri;
		}
	}

}
