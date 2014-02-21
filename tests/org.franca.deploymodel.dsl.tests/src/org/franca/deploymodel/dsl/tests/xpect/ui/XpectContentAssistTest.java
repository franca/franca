package org.franca.deploymodel.dsl.tests.xpect.ui;

import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;

import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.jface.text.contentassist.ICompletionProposal;
import org.eclipse.xtext.ISetup;
import org.eclipse.xtext.junit4.ui.AbstractContentAssistProcessorTest;
import org.eclipse.xtext.junit4.ui.ContentAssistProcessorTestBuilder;
import org.eclipse.xtext.junit4.util.ResourceLoadHelper;
import org.eclipse.xtext.resource.FileExtensionProvider;
import org.eclipse.xtext.resource.XtextResource;
import org.eclipse.xtext.resource.XtextResourceSet;
import org.eclipse.xtext.ui.editor.contentassist.ConfigurableCompletionProposal;
import org.eclipse.xtext.xbase.junit.ui.AbstractContentAssistTest;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.franca.deploymodel.dsl.ui.internal.FDeployActivator;
import org.junit.Before;
import org.junit.runner.RunWith;
import org.xpect.expectation.CommaSeparatedValuesExpectation;
import org.xpect.expectation.ICommaSeparatedValuesExpectation;
import org.xpect.parameter.ParameterParser;
import org.xpect.runner.Xpect;
import org.xpect.runner.XpectRunner;
import org.xpect.setup.XpectSetup;
import org.xpect.xtext.lib.setup.ThisModel;
import org.xpect.xtext.lib.setup.ThisOffset;
import org.xpect.xtext.lib.setup.ThisResource;
import org.xpect.xtext.lib.setup.XtextWorkspaceSetup;

import com.google.inject.Inject;
import com.google.inject.Injector;
import com.google.inject.Provider;

@SuppressWarnings("restriction")
@RunWith(XpectRunner.class)
@XpectSetup({ XtextWorkspaceSetup.class })
public class XpectContentAssistTest extends AbstractContentAssistProcessorTest {
	@Inject
	protected Provider<XtextResourceSet> resourceSetProvider;

	@Inject
	protected FileExtensionProvider fileExtensionProvider;

	@Inject
	protected Injector injector;

	@Xpect
	@ParameterParser(syntax = "'at' arg1=OFFSET")
	public void proposals( //
			@CommaSeparatedValuesExpectation ICommaSeparatedValuesExpectation expectation, //
			int arg1, @ThisResource XtextResource resource, @ThisOffset int offset, @ThisModel EObject theModel) {
		try {
			setUp();
		} catch (Exception e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}
		URI uri = URI.createURI(theModel.eResource().getURI().toString(), false);
		if ("xt".equals(uri.fileExtension())) {
			uri = uri.trimFileExtension();
		}
		String modelString = resource.getSerializer().serialize(theModel);
		ICompletionProposal[] proposals = null;
		try {
			proposals = newBuilder(uri).append(modelString.replace("org.example.spec.MySpec", "org.example.spec.MySpec"))
					.computeCompletionProposals(arg1);
		} catch (Exception e) {
			e.printStackTrace();
		}
		List<String> actualProposals = new ArrayList<String>();
		for (ICompletionProposal iCompletionProposal : proposals) {
			if (iCompletionProposal instanceof ConfigurableCompletionProposal) {
				actualProposals.add(((ConfigurableCompletionProposal) iCompletionProposal).getReplacementString());
			} else {
				actualProposals.add(iCompletionProposal.getDisplayString());
			}
		}

		expectation.assertEquals(actualProposals);
	}

	protected ContentAssistProcessorTestBuilder newBuilder(final URI uri) throws Exception {
		return new ContentAssistProcessorTestBuilder(this.injector, new ResourceLoadHelper() {
			@Override
			public XtextResource getResourceFor(InputStream stream) {
				try {
					XtextResource _xblockexpression = null;
					{
						final XtextResourceSet set = XpectContentAssistTest.this.resourceSetProvider.get();
						final Resource result = set.createResource(uri);
						result.load(stream, null);
						_xblockexpression = (((XtextResource) result));
					}
					return _xblockexpression;
				} catch (Throwable _e) {
					throw Exceptions.sneakyThrow(_e);
				}
			}
		});
	}

	@Override
	protected ISetup doGetSetup() {
		return new ISetup() {
			@Override
			public Injector createInjectorAndDoEMFRegistration() {
				return FDeployActivator.getInstance().getInjector(FDeployActivator.ORG_FRANCA_DEPLOYMODEL_DSL_FDEPLOY);
			}

			public void register(Injector injector) {
			}
		};
	}

}
