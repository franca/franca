package org.franca.connectors.idl;

import java.io.File;
import java.util.List;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.GnuParser;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.Option;
import org.apache.commons.cli.OptionBuilder;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.ParseException;
import org.apache.log4j.Logger;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.xtext.diagnostics.Severity;
import org.eclipse.xtext.validation.CheckMode;
import org.eclipse.xtext.validation.IResourceValidator;
import org.eclipse.xtext.validation.Issue;
import org.franca.core.dsl.FrancaIDLStandaloneSetup;
import org.franca.core.dsl.FrancaIDLVersion;
import org.franca.core.dsl.FrancaPersistenceManager;
import org.franca.core.franca.FModel;
import org.franca.core.utils.FileHelper;

import com.google.common.collect.Lists;
import com.google.inject.Inject;
import com.google.inject.Injector;

/**
 * Runner for standalone Franca2Idl transformation from Franca files.
 *  
 * @author Klaus Birken (itemis)
 */
public class Franca2IdlStandalone {

	// prepare class for logging....
	private static final Logger logger = Logger.getLogger(Franca2IdlStandalone.class);

	private static final String TOOL_VERSION = "0.1.0";
	private static final String FIDL_VERSION = 
			FrancaIDLVersion.getMajor() + "." + FrancaIDLVersion.getMinor();
	
	private static final String HELP = "h";
	private static final String FIDLFILE = "f";
	private static final String OUTDIR = "o";
	private static final String RECURSIVE_VALIDATION = "r";
	
	private static final String VERSIONSTR =
			"Franca2IdlStandalone " + TOOL_VERSION + " (Franca IDL version " + FIDL_VERSION + ").";
	
	private static final String HELPSTR =
			"java -jar Franca2IdlStandalone.jar [OPTIONS]";

	private static Injector injector;
	
	/**
	 * @param args
	 */
	public static void main(String[] args) throws Exception {
		injector = new FrancaIDLStandaloneSetup().createInjectorAndDoEMFRegistration();
		int retval = injector.getInstance(Franca2IdlStandalone.class).run(args);
		if (retval != 0)
			System.exit(retval);
	}


	// injected fragments
	@Inject	FrancaPersistenceManager fidlLoader;

	@Inject IResourceValidator validator;
	@Inject	Franca2IdlConverter generator;

	public int run(String[] args) throws Exception {
		Options options = getOptions();

		// print version string
//		System.out.println(VERSIONSTR);
		
		// create the parser
		CommandLineParser parser = new GnuParser();
		CommandLine line = null;
		final HelpFormatter formatter = new HelpFormatter();
		try {
			line = parser.parse(options, args);
		} catch (final ParseException exp) {
			logger.error(exp.getMessage());
			formatter.printHelp(HELPSTR, options);
			return -1;
		}

		if (line.hasOption(HELP) || checkCommandLineValues(line) == false) {
			formatter.printHelp(HELPSTR, options);
			return -1;
		}

		// TODO configure Logger depends on given verbose value
//		boolean verbose = line.hasOption(VERBOSE);
		
		// load Franca IDL file
		String fidlFile = line.getOptionValue(FIDLFILE);
		FModel fmodel = fidlLoader.loadModel(fidlFile);
		if (fmodel==null) {
			logger.error("Couldn't load Franca IDL file '" + fidlFile + "'.");
			return -1;
		}
//		logger.info("Franca IDL: package '" + fmodel.getName() + "'");

		// call validator
		int nErrors = 0;
		Resource mainResource = fmodel.eResource();
		List<Resource> toBeValidated = Lists.newArrayList();
		if (line.hasOption(RECURSIVE_VALIDATION)) {
			toBeValidated.addAll(mainResource.getResourceSet().getResources());
		} else {
			toBeValidated.add(mainResource);
		}
		for(Resource res : toBeValidated) {
			List<Issue> validationErrors = validator.validate(res, CheckMode.ALL, null);
			for (Issue issue : validationErrors) {
				String msg = issue.getSeverity() +
						" at " + res.getURI().path() +
						" #" + issue.getLineNumber() + ": " +
						issue.getMessage();
				System.err.println(msg);
				if (issue.getSeverity()==Severity.ERROR)
					nErrors++;
			}
		}
		
		if (nErrors>0) {
			System.err.println("Validation of Franca model: " + nErrors + " errors, aborting.");
			return -1;
		}
		
		// call generator and save files
		String output = generator.generateAll(fmodel).toString();
		if (line.hasOption(OUTDIR)) {
			String outputFolder = line.getOptionValue(OUTDIR);
			String outPath = outputFolder + "/" + fmodel.getName().replaceAll("[.]", "/");
			String filename = getBasename(mainResource.getURI()) + ".idl";
			FileHelper.save(outPath, filename, output);
		} else {
			// no outdir specified, write to stdout
			System.out.println(output);
		}

//		logger.info("FrancaStandaloneGen done.");
		return 0;
	}
	
	@SuppressWarnings("static-access")
	private Options getOptions() {
		// String[] set = LogFactory.getLog(getClass()).
		final Options options = new Options();

		// optional
//		Option optVerbose = OptionBuilder.withArgName("verbose")
//				.withDescription("Print Out Verbose Information").hasArg(false)
//				.isRequired(false).create(VERBOSE);
//		options.addOption(optVerbose);
		Option optHelp = OptionBuilder.withArgName("help").withDescription("Print Usage Information")
				.hasArg(false).isRequired(false)
				.create(HELP);
		options.addOption(optHelp);

		// required
		Option optInputFidl = OptionBuilder.withArgName("Franca IDL file")
				.withDescription("Input file in Franca IDL (fidl) format.").hasArg().isRequired()
				.withValueSeparator(' ').create(FIDLFILE);
		//optInputFidl.setType(File.class);
		options.addOption(optInputFidl);

		// optional
		Option optOutputDir = OptionBuilder.withArgName("output directory")
				.withDescription("Directory where the generated files will be stored")
				.hasArg().withValueSeparator(' ').create(OUTDIR);
		options.addOption(optOutputDir);

		Option optRecursiveValidation = OptionBuilder.withArgName("recval")
		.withDescription("Recursive validation").hasArg(false)
		.isRequired(false).create(RECURSIVE_VALIDATION);
		options.addOption(optRecursiveValidation);

		return options;
	}

	
	private boolean checkCommandLineValues(CommandLine line) {
		if (line.hasOption(FIDLFILE)) {
			String fidlFile = line.getOptionValue(FIDLFILE);
			File fidl = new File(fidlFile);
			if (fidl.exists()) {
				return true;
			} else {
				logger.error("Cannot open Franca IDL file '" + fidlFile + "'.");
			}
		}
		return false;
	}

	private String getBasename(URI uri) {
		String filename = uri.lastSegment();
		int dot = filename.lastIndexOf('.');
		if (dot>0) {
			return filename.substring(0, dot);
		} else {
			// didn't find dot as extension separator, return full string
			return filename;
		}
	}
}
