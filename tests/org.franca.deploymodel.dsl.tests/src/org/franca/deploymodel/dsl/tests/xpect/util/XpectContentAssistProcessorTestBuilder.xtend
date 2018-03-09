package org.franca.deploymodel.dsl.tests.xpect.util

import org.eclipse.jface.text.BadLocationException
import org.eclipse.jface.text.contentassist.ICompletionProposal
import org.eclipse.jface.text.contentassist.IContentAssistProcessor
import org.eclipse.jface.text.contentassist.IContentAssistant
import org.eclipse.jface.text.source.ISourceViewer
import org.eclipse.swt.widgets.Shell
import org.eclipse.xtext.ui.editor.XtextSourceViewer
import org.eclipse.xtext.ui.editor.XtextSourceViewerConfiguration
import org.eclipse.xtext.ui.editor.model.IXtextDocument
import org.eclipse.xtext.ui.editor.model.XtextDocument
import com.google.inject.Inject
import com.google.inject.Injector

class XpectContentAssistProcessorTestBuilder implements Cloneable {
	final Injector injector
	@Inject(optional=true) final XtextDocument document

	static class Factory {
		final Injector injector

		@Inject new(Injector injector) {
			this.injector = injector
		}

		def XpectContentAssistProcessorTestBuilder create(XtextDocument d) throws Exception {
			return new XpectContentAssistProcessorTestBuilder(this.injector, d)
		}
	}

	new(Injector injector, XtextDocument document) throws Exception {
		this.injector = injector
		this.injector.injectMembers(this)
		this.document = document
	}

	def ICompletionProposal[] computeCompletionProposals(int cursorPosition) throws Exception {
		return computeCompletionProposals(document, cursorPosition)
	}

	def private ICompletionProposal[] computeCompletionProposals(IXtextDocument xtextDocument,
		int cursorPosition) throws BadLocationException {
		var Shell shell = new Shell()
		try {
			return computeCompletionProposals(xtextDocument, cursorPosition, shell)
		} finally {
			shell.dispose()
		}
	}

	def private ICompletionProposal[] computeCompletionProposals(IXtextDocument xtextDocument, int cursorPosition,
		Shell shell) throws BadLocationException {
		var XtextSourceViewerConfiguration configuration = get(XtextSourceViewerConfiguration)
		var ISourceViewer sourceViewer = getSourceViewer(shell, xtextDocument, configuration)
		return computeCompletionProposals(xtextDocument, cursorPosition, configuration, sourceViewer)
	}

	def private static ICompletionProposal[] computeCompletionProposals(IXtextDocument xtextDocument,
		int cursorPosition, XtextSourceViewerConfiguration configuration,
		ISourceViewer sourceViewer) throws BadLocationException {
			var IContentAssistant contentAssistant = configuration.getContentAssistant(sourceViewer)
			var String contentType = xtextDocument.getContentType(cursorPosition)
			var IContentAssistProcessor processor = contentAssistant.getContentAssistProcessor(contentType)
			if (processor !== null) {
				return processor.computeCompletionProposals(sourceViewer, cursorPosition)
			}
			return newArrayOfSize(0)
		}

		def private ISourceViewer getSourceViewer(Shell shell, IXtextDocument xtextDocument,
			XtextSourceViewerConfiguration configuration) {
			var XtextSourceViewer.Factory factory = get(XtextSourceViewer.Factory)
			var ISourceViewer sourceViewer = factory.createSourceViewer(shell, null, null, false, 0)
			sourceViewer.configure(configuration)
			sourceViewer.setDocument(xtextDocument)
			return sourceViewer
		}

		def private <T> T get(Class<T> clazz) {
			return injector.getInstance(clazz)
		}
	}
	