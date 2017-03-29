/*******************************************************************************
 * Copyright (c) 2016 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.connectors.omgidl

import java.io.File
import org.apache.commons.cli.CommandLine
import org.apache.commons.cli.Options
import org.apache.log4j.Logger
import org.franca.core.dsl.FrancaPersistenceManager
import org.franca.core.dsl.cli.AbstractCommandLineTool
import org.franca.core.dsl.cli.CommonOptions
import org.franca.core.franca.FModel

/**
 * The command-line tool for running the OMG IDL to Franca transformation.</p>
 * 
 * @author Klaus Birken (itemis AG)
 */
class OMGIDL2FrancaStandalone extends AbstractCommandLineTool {
	
	static final Logger logger = Logger.getLogger(typeof(OMGIDL2FrancaStandalone))

	private static final String TOOL_VERSION = "0.4.3";

	/**
	 * The main function for this standalone tool.</p>
	 * 
	 * It directly hands over control to the CommandLineTool framework.
	 * 
	 * @param args the collection of command line arguments
	 */
	def static void main(String[] args) {
		// hand over control to CommandLineTool framework
		execute(TOOL_VERSION, typeof(OMGIDL2FrancaStandalone), args)
	}

	override protected addOptions(Options options) {
		// provide option for configuration of an output directory 
		CommonOptions.createOutdirOption(options)
		
		// provide option for providing a basetype fidl file
		StandaloneOptions.createBasetypesOption(options)
	}

	override protected boolean checkCommandLineValues(CommandLine line) {
		// we need at least one argument
		line.argList.size > 0
	}
	
	override protected int run(CommandLine line) {
		var nInputs = 0
		for(arg : line.argList) {
			val filename = (arg as String).trim
			if (! filename.endsWith(".idl")) {
				logger.error("Input file must have suffix 'idl' (filename is '" + filename + "')!")
				return -1
			} else {
				if (verbose)
					logger.info("Processing input file " + filename)
				
				// load basetypes model on demand
				var FModel baseModel = null
				if (line.hasOption(StandaloneOptions.BASETYPES)) {
					// prepare the Franca base model with basic typedefs
					val basetypeFidl = line.getOptionValue(StandaloneOptions.BASETYPES)
					baseModel = persistenceManager.loadModel(basetypeFidl)
				}
				
				val conn = new OMGIDLConnector(baseModel)
				val omgidl = conn.loadModel(filename) as OMGIDLModelContainer
				if (omgidl==null) {
					logger.error("Couldn't load input model from file!")
					return -2
				} else {
					if (verbose)
						logger.info("Input model consists of " + omgidl.models.size + " files")
					
					// do validation of input model(s)
					val nErrors = validateModel(omgidl.model, true)
					if (nErrors>0) {
						logger.error("Transformation aborted due to validation errors in input model!")
						return -3
					} else {
						nInputs++
						
						// transform to Franca 
						val fmodelGen = conn.toFranca(omgidl)
						val rootModelName = fmodelGen.modelName
	
						// determine output folder for generated Franca files
						val outputDir =
							if (line.hasOption(CommonOptions.OUTDIR)) {
								line.getOptionValue(CommonOptions.OUTDIR)
							} else {
								// no outdir specified, write to current working directory
								System.getProperty("user.dir")
							}
						
		    			// save all models resulting from transformation to file
	    	    		val outfile = rootModelName +
	    	    				"." + FrancaPersistenceManager.FRANCA_FILE_EXTENSION;
	    	    		val outpath = outputDir + File.separator + outfile;
		    			if (persistenceManager.saveModel(fmodelGen.model, outpath, fmodelGen)) {
	    	    			logger.info("Saved Franca IDL file '" + outpath + "'.");
	    	    		} else {
	    	    			logger.error("Franca IDL model couldn't be written to file '" + outpath + "'.");
	    	    			return -4
		    			}
					}
				}
			}
		}

		if (verbose)
			logger.info("Processed " + nInputs + " input models, done.")

		0
	}
	
	override protected logError(String message) {
		logger.error(message)
	}
	
	override protected logInfo(String message) {
		logger.info(message)
	}
	
}
