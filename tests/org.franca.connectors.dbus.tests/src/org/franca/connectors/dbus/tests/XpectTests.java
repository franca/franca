package org.franca.connectors.dbus.tests;

import org.franca.connectors.dbus.validators.DBusCompatibilityValidator;
import org.franca.core.dsl.validation.ExternalValidatorRegistry;
import org.junit.BeforeClass;
import org.junit.runner.RunWith;
import org.xpect.runner.XpectRunner;
import org.xpect.runner.XpectTestFiles;
import org.xpect.xtext.lib.tests.XtextTests;
 

@RunWith(XpectRunner.class)
@XpectTestFiles(fileExtensions = "xt")
public class XpectTests extends XtextTests  {

	@BeforeClass
	public static void init() {
		ExternalValidatorRegistry.addValidator(new DBusCompatibilityValidator());
	}
}
