package org.franca.core.buildutil;

import java.io.File;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.eclipse.emf.mwe.core.WorkflowContext;
import org.eclipse.emf.mwe.core.issues.Issues;
import org.eclipse.emf.mwe.core.lib.AbstractWorkflowComponent2;
import org.eclipse.emf.mwe.core.monitor.ProgressMonitor;

public class FileRemover extends AbstractWorkflowComponent2 {

	private static final Log LOG = LogFactory.getLog(FileRemover.class);
	
	private String filename = null;

	/**
	 * Sets the file to be deleted.
	 *
	 * @param file
	 *            name of file
	 */
	public void setFile(final String file) {
		this.filename = file;
	}

	/**
	 * @see org.eclipse.emf.mwe.core.lib.AbstractWorkflowComponent#getLogMessage()
	 */
	@Override
	public String getLogMessage() {
		return "deleting file '" + filename + "'";
	}
	
	@Override
	protected void invokeInternal(WorkflowContext ctx, ProgressMonitor monitor, Issues issues) {
		if (filename!=null) {
			final File f = new File(filename);
			if (f.exists() && f.isFile()) {
				LOG.info("Deleting " + f.getAbsolutePath());
				if (! f.delete()) {
					issues.addError("Error during deletion of file " + f.getAbsolutePath());
				}
			} else {
				LOG.info("File " + f.getAbsolutePath() + " doesn't exist, deleting it is not needed");
			}
		}
	}
	
	@Override
	protected void checkConfigurationInternal(final Issues issues) {
		if (filename == null) {
			issues.addWarning("No file specified!");
		}
	}


}
