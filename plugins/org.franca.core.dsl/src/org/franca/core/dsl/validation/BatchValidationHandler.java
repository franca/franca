package org.franca.core.dsl.validation;

import org.eclipse.core.commands.AbstractHandler;
import org.eclipse.core.commands.ExecutionEvent;
import org.eclipse.core.commands.ExecutionException;
import org.eclipse.xtext.ui.editor.XtextEditor;
import org.eclipse.xtext.ui.editor.utils.EditorUtils;
import org.eclipse.xtext.ui.editor.validation.MarkerCreator;
import org.eclipse.xtext.ui.editor.validation.MarkerIssueProcessor;
import org.eclipse.xtext.ui.editor.validation.ValidationJob;
import org.eclipse.xtext.ui.validation.MarkerTypeProvider;
import org.eclipse.xtext.validation.CheckMode;

import com.google.inject.Inject;

public class BatchValidationHandler extends AbstractHandler {

	@Inject
	private FrancaIDLJavaValidator resourceValidator;

	@Inject
	private MarkerCreator markerCreator;

	@Inject
	private MarkerTypeProvider markerTypeProvider;

	@Override
	public Object execute(ExecutionEvent event) throws ExecutionException {
		XtextEditor editor = EditorUtils.getActiveXtextEditor();
		MarkerIssueProcessor markerIssueProcessor = new MarkerIssueProcessor(
				editor.getResource(), markerCreator, markerTypeProvider);
		ValidationJob validationJob = new ValidationJob(resourceValidator,
				editor.getDocument(), markerIssueProcessor,
				CheckMode.EXPENSIVE_ONLY);
		validationJob.schedule();
		return null;
	}

}
