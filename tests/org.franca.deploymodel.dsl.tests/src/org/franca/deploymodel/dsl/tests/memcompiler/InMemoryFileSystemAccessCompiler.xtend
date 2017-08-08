/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.deploymodel.dsl.tests.memcompiler

import java.io.PrintWriter
import java.util.ArrayList
import java.util.List
import javax.tools.DiagnosticCollector
import javax.tools.JavaFileManager
import javax.tools.JavaFileObject
import javax.tools.ToolProvider
import org.apache.commons.lang.StringUtils
import org.eclipse.xtext.generator.InMemoryFileSystemAccess
import org.franca.deploymodel.dsl.tests.memcompiler.CharSequenceJavaFileObject
import org.franca.deploymodel.dsl.tests.memcompiler.ClassFileManager

/** 
 * This class tries to compile the files residing in an InMemoryFileSystemAccess by means of the ToolProvider::getSystemJavaCompiler().
 * The resulting class "files" reside in memory, one can access them by getJavaClass(String name).
 */
class InMemoryFileSystemAccessCompiler {

	val systemJavaCompiler = ToolProvider::getSystemJavaCompiler()
	var InMemoryFileSystemAccess fsa;
	var boolean needToCompile;
	var List<String> expectedJavaClasses
	var JavaFileManager javaFileManager

	new(InMemoryFileSystemAccess fsa) {
		this.fsa = fsa;
		needToCompile = true;
		println(fsa.textFiles)
		expectedJavaClasses = fsa.textFiles.entrySet().map[key].filter[endsWith(".java")].map[asJavaClassName].toList
	}

	def Class<?> getJavaClass(String name) {
		lazyCompile()
		val isFqn = StringUtils::indexOf(name, '.') > -1;
		val fqnName = if(isFqn) name else expectedJavaClasses.findFirst[endsWith(name)]

		if (expectedJavaClasses.contains(fqnName)) {
			return javaFileManager.getClassLoader(null).loadClass(name)
		}
		throw new RuntimeException('''Cannot find «name» within names of expected JavaClasses «expectedJavaClasses»''')
	}

	def protected asJavaClassName(String fsaFileName) {
		var result = StringUtils::removeEnd(fsaFileName, ".java")
		StringUtils::removeStart(result, "DEFAULT_OUTPUT/")
	}

	/** returns all .java-Files residing in the fsa (this does not include inner/anonymous classes). */
	def getExpectedJavaClasses() {
		expectedJavaClasses
	}

	def protected void lazyCompile() {
		if (needToCompile) {
			needToCompile = false;
			val fsaTextFiles = fsa.getTextFiles();
			val diagnosticListener = new DiagnosticCollector<JavaFileObject>();
			val compilationUnits = new ArrayList<JavaFileObject>();
			for (entry : fsaTextFiles.entrySet().filter[key.endsWith(".java")]) {
				compilationUnits.add(
					new CharSequenceJavaFileObject(entry.key.asJavaClassName, entry.getValue().toString()));
			}
			javaFileManager = new ClassFileManager(systemJavaCompiler.getStandardFileManager(null, null, null));
			val compilerOptions = newArrayList("-classpath", System::getProperty("java.class.path"), "-verbose");
			val compilationTask = systemJavaCompiler.getTask(new PrintWriter(System::out), javaFileManager,
				diagnosticListener, compilerOptions, null, compilationUnits);
			val success = compilationTask.call();
			if (! success) {
				var errMsg = ''''''
				for (d : diagnosticListener.diagnostics) {
					errMsg = errMsg + '''
						«d.code» «d.kind»
						«d.getPosition» «d.getStartPosition» «d.getEndPosition»
						«d.source»
						«d.getMessage(null)»
						
					'''
				}
				throw new RuntimeException("Compilation not successful. Error-Message from compiler is " + errMsg);
			}
		}

	}
}
