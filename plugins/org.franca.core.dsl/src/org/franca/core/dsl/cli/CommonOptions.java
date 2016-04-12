/*******************************************************************************
 * Copyright (c) 2016 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.core.dsl.cli;

import org.apache.commons.cli.Option;
import org.apache.commons.cli.OptionBuilder;
import org.apache.commons.cli.Options;

/**
 * Configurator for command line options used by typical Franca-related command line tools.
 * 
 * @author Klaus Birken (itemis AG)
 */
public class CommonOptions {

	public static final String HELP = "h";
	public static final String VERBOSE = "v";

	/**
	 * Configure options which are provided by all Franca-related command line tools.
	 * 
	 * @param options the target options configuration 
	 */
	@SuppressWarnings("static-access")
	public static void createCommonOptions(Options options) {
		// create and add a generic "help" option
		Option optHelp = OptionBuilder.withArgName("help")
				.withDescription("Print usage information")
				.hasArg(false)
				.isRequired(false)
				.create(HELP);
		options.addOption(optHelp);

		// optional verbose switch
		Option optVerbose = OptionBuilder.withArgName("verbose")
				.withDescription("Activate verbose mode")
				.hasArg(false)
				.isRequired(false)
				.create(VERBOSE);
		options.addOption(optVerbose);

	}

	
	public static final String OUTDIR = "o";

	/**
	 * Configure an "output directory" option for all command line tools which need this.
	 * 
	 * @param options the target options configuration 
	 */
	@SuppressWarnings("static-access")
	public static void createOutdirOption(Options options) {
		// optional
		Option optOutputDir = OptionBuilder.withArgName("output directory")
				.withDescription("Directory where the generated files will be stored")
				.hasArg().withValueSeparator(' ').create(OUTDIR);
		options.addOption(optOutputDir);
	}
}
