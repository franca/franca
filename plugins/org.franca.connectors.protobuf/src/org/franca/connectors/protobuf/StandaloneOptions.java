package org.franca.connectors.protobuf;

import org.apache.commons.cli.Option;
import org.apache.commons.cli.OptionBuilder;
import org.apache.commons.cli.Options;

public class StandaloneOptions {

	public static final String NORMALIZE_IDS = "n";

	/**
	 * Configure an "normalize ids" option.
	 * 
	 * @param options the target options configuration 
	 */
	@SuppressWarnings("static-access")
	public static void createNormalizeIdsOption(Options options) {
		// optional
		Option optNormalizeIds = OptionBuilder.withArgName("normalize ids")
				.withDescription("Normalize IDs")
				.hasArg(false)
				.isRequired(false)
				.create(NORMALIZE_IDS);
		options.addOption(optNormalizeIds);
	}

}
