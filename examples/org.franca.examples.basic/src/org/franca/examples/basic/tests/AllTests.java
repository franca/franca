package org.franca.examples.basic.tests;

import org.junit.runner.RunWith;
import org.junit.runners.Suite;

@RunWith(Suite.class)
@Suite.SuiteClasses({
	// plain Franca
	Franca2HtmlTest.class,
	
	// generators
	HppGeneratorTest.class
})


public class AllTests {
}
