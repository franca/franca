package org.franca.deploymodel.dsl;

import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.generator.JavaIoFileSystemAccess;
import org.eclipse.xtext.service.AbstractGenericModule;

/**
 * Test-related configuration for Guice injector. 
 * 
 * @author Klaus Birken
 */
public class FDeployTestsModule extends AbstractGenericModule {
    public Class<? extends IFileSystemAccess> bindIFileSystemAccess() {
        return JavaIoFileSystemAccess.class;
    }

}
