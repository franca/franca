package org.franca.connectors.omgidl;

import org.apache.commons.cli.Option;
import org.apache.commons.cli.OptionBuilder;
import org.apache.commons.cli.Options;

public class StandaloneOptions {

	public static final String BASETYPES = "b";

	/**
	 * Configure an "basetypes fidl" option.
	 * 
	 * @param options the target options configuration 
	 */
	@SuppressWarnings("static-access")
	public static void createBasetypesOption(Options options) {
		// optional
		Option opt = OptionBuilder.withArgName("basetypes fidl")
				.withDescription("Franca IDL file which defines aliases for OMG IDL basetypes")
				.hasArg().withValueSeparator(' ').create(BASETYPES);
		options.addOption(opt);
	}

}
