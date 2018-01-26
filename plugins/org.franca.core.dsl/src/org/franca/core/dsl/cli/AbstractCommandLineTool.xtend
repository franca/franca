/*******************************************************************************
 * Copyright (c) 2016 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.core.dsl.cli

import com.google.inject.Inject
import com.google.inject.Injector
import java.util.List
import org.apache.commons.cli.CommandLine
import org.apache.commons.cli.CommandLineParser
import org.apache.commons.cli.GnuParser
import org.apache.commons.cli.HelpFormatter
import org.apache.commons.cli.Options
import org.apache.commons.cli.ParseException
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.diagnostics.Severity
import org.eclipse.xtext.validation.CheckMode
import org.eclipse.xtext.validation.IResourceValidator
import org.eclipse.xtext.validation.Issue
import org.franca.core.dsl.FrancaIDLStandaloneSetup
import org.franca.core.dsl.FrancaIDLVersion
import org.franca.core.dsl.FrancaPersistenceManager

/**
 * Abstract base class for all command-line tools related to Franca.
 * 
 * @author Klaus Birken (itemis AG)
 */
abstract class AbstractCommandLineTool {

	/**
	 * A Franca-aware injector which is used for initialization of the command-line tool.
	 */
	protected static Injector injector

	def protected static <T extends AbstractCommandLineTool> void execute(
		String toolVersion,
		Class<T> concreteClass,
		String[] args
	) {
		injector = new FrancaIDLStandaloneSetup().createInjectorAndDoEMFRegistration()
		
		// create instance using injector and call its executeInstance method
		val instance = injector.getInstance(concreteClass)
		val retval = (instance as AbstractCommandLineTool).executeInstance(toolVersion, concreteClass.simpleName, args)
		exit(retval)
	}

	/**
	 * For testing a command-line tool in unit tests, set testModel to true.
	 * We will avoid calling System.exit(), then.
	 */
	var static testMode = false
	
	/**
	 * Switch to unit-test mode. In test mode, we will not call System.exit() anymore.
	 */
	def static setTestMode() {
		testMode = true
	}

	/**
	 * Exit code of last execution, in case testMode is set to true.
	 */
	var static exitCode = 0
	
	/**
	 * Get exit code while in testing mode.</p>
	 * 
	 * Do not use this in production mode.
	 */
	def static getExitCode() {
		exitCode
	}

	def private static exit(int retval) {
		if (retval != 0) {
			if (testMode)
				exitCode = retval
			else
				System.exit(retval)
		}
	}

	/**
	 * The version of the specific tool.
	 */
	protected String toolVersion = "X.X.X"

	@Inject
	protected FrancaPersistenceManager persistenceManager

	@Inject
	protected IResourceValidator validator
	
	/**
	 * Verbose flag which can be set via command line option -v.
	 */
	protected boolean verbose = false
	
	/**
	 * The actual functionality of this command line tool.</p>
	 * 
	 * This method will run on an instance of a class which is derived
	 * from AbstractCommandLineTool. As the instance is created using 
	 * Guice injection, all injected fields will be properly initialized.
	 */
	def private int executeInstance(String toolVersion, String classname, String[] args) {
		this.toolVersion = toolVersion
		
		val options = new Options
		CommonOptions.createCommonOptions(options)
		addOptions(options)

		val helpstr = '''java -jar «classname».jar [OPTIONS]'''

		// create the parser
		val CommandLineParser parser = new GnuParser
		var CommandLine line = null
		val formatter = new HelpFormatter
		try {
			line = parser.parse(options, args)
		} catch (ParseException exp) {
			logError(exp.getMessage)
			formatter.printHelp(helpstr, options);
			return -1
		}

		if (line.hasOption(CommonOptions.VERBOSE)) {
			verbose = true
		}
				
		if (line.hasOption(CommonOptions.HELP)) {
			logInfo(getVersionString)
			formatter.printHelp(helpstr, options);
			return 0
		}
		
		if (checkCommandLineValues(line) == false) {
			formatter.printHelp(helpstr, options);
			return -1
		}
		
		return run(line)
	}

	def protected String getVersionString() {
		val fidlVersion = '''«FrancaIDLVersion.getMajor».«FrancaIDLVersion.getMinor»'''
		'''Tool version «toolVersion», Franca IDL language version «fidlVersion»'''
	}

	/**
	 * An interface for logging an error.
	 */	
	abstract def protected void logError(String message)

	/**
	 * An interface for logging an information.
	 */	
	abstract def protected void logInfo(String message)

	/**
	 * Provide a proper Options configuration for parsing the command line.
	 */	
	abstract def protected void addOptions(Options options)
	
	/**
	 * Do validation on command line arguments.
	 */
	abstract def protected boolean checkCommandLineValues(CommandLine line)

	/**
	 * Execute the actual functionality of the command line tool.
	 */
	abstract def protected int run(CommandLine line)
	
	/**
	 * Validate a model before processing it.</p>
	 * 
	 * The validation can be done for the model only or for all models in its resource set.
	 * 
	 * @param model the model which should be validated
	 * @param recursively if true, all models in the resource set will be validated
	 * @return number of errors (only continue processing if no error occurred) 
	 */
	def protected int validateModel(EObject model, boolean recursively) {
		var nErrors = 0
		val mainResource = model.eResource

		val toBeValidated = newArrayList
		if (recursively) {
			val resources = mainResource.getResourceSet.getResources
			toBeValidated.addAll(resources)
		} else {
			toBeValidated.add(mainResource)
		}

		for(Resource res : toBeValidated) {
			val List<Issue> validationErrors = validator.validate(res, CheckMode.ALL, null)
			for (Issue issue : validationErrors) {
				val msg = '''«issue.severity» at «res.URI.path» #«issue.lineNumber»: «issue.message»'''
				logError(msg)
				if (issue.severity==Severity.ERROR)
					nErrors++;
			}
		}
		
		nErrors
	}
}
