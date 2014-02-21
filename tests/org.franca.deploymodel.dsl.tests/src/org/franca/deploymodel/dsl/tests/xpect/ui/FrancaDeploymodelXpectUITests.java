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
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.franca.deploymodel.dsl.tests.xpect.FrancaDeploymodelXpectTests;
import org.franca.deploymodel.dsl.ui.internal.FDeployActivator;
import org.junit.BeforeClass;
import org.junit.runner.RunWith;
import org.xpect.Environment;
import org.xpect.expectation.CommaSeparatedValuesExpectation;
import org.xpect.expectation.ICommaSeparatedValuesExpectation;
import org.xpect.parameter.ParameterParser;
import org.xpect.runner.Xpect;
import org.xpect.runner.XpectRunner;
import org.xpect.runner.XpectSuiteClasses;
import org.xpect.runner.XpectTestFiles;
import org.xpect.setup.XpectSetup;
import org.xpect.util.EnvironmentUtil;
import org.xpect.xtext.lib.setup.ThisModel;
import org.xpect.xtext.lib.setup.ThisOffset;
import org.xpect.xtext.lib.setup.ThisResource;
import org.xpect.xtext.lib.setup.XtextWorkspaceSetup;

import com.google.inject.Inject;
import com.google.inject.Injector;
import com.google.inject.Provider;

@SuppressWarnings("restriction")
@XpectSuiteClasses({ FrancaDeploymodelXpectTests.class, //
})
@RunWith(XpectRunner.class)
@XpectTestFiles(fileExtensions = "xt")
@XpectSetup({ XtextWorkspaceSetup.class })
public class FrancaDeploymodelXpectUITests extends AbstractContentAssistProcessorTest {

	@Inject
	protected Provider<XtextResourceSet> resourceSetProvider;

	@Inject
	protected FileExtensionProvider fileExtensionProvider;

	@Inject
	protected Injector injector;

	@BeforeClass
	public static void requirePlugInEnvironment() {
		EnvironmentUtil.requireEnvironment(Environment.PLUGIN_TEST);
	}

	@Override
	protected ISetup doGetSetup() {
		return new ISetup() {
			@Override
			public Injector createInjectorAndDoEMFRegistration() {
				return FDeployActivator.getInstance().getInjector(FDeployActivator.ORG_FRANCA_DEPLOYMODEL_DSL_FDEPLOY);
			}
		};
	}

	@Xpect
	@ParameterParser(syntax = "'at' arg1=OFFSET")
	public void proposals( //
			@CommaSeparatedValuesExpectation ICommaSeparatedValuesExpectation expectation, //
			int arg1, @ThisResource XtextResource resource, @ThisOffset int offset, @ThisModel EObject theModel)
			throws Exception {
		// Since the inherited method setup has a @Before Annotation, I expect the XpectRunner to invoke it.
		// For some reason, this runner does invoke the @BeforeClass - stuff, but not the @Before
		try {
			setUp();
			URI uri = URI.createURI(theModel.eResource().getURI().toString(), false);
			if ("xt".equals(uri.fileExtension())) {
				uri = uri.trimFileExtension();
			}
			String modelString = resource.getSerializer().serialize(theModel);
			ICompletionProposal[] proposals = null;
			try {
				proposals = newBuilder(uri).append(modelString).computeCompletionProposals(arg1);
			} catch (Exception e) {
				e.printStackTrace();
			}
			List<String> actualProposals = new ArrayList<String>();
			if (proposals != null) {
				for (ICompletionProposal iCompletionProposal : proposals) {
					if (iCompletionProposal instanceof ConfigurableCompletionProposal) {
						actualProposals.add(((ConfigurableCompletionProposal) iCompletionProposal)
								.getReplacementString());
					} else {
						actualProposals.add(iCompletionProposal.getDisplayString());
					}
				}
			}
			expectation.assertEquals(actualProposals);
		} finally {
			tearDown();
		}
	}

	protected ContentAssistProcessorTestBuilder newBuilder(final URI uri) throws Exception {
		return new ContentAssistProcessorTestBuilder(this.injector, new ResourceLoadHelper() {
			@Override
			public XtextResource getResourceFor(InputStream stream) {
				try {
					final XtextResourceSet set = FrancaDeploymodelXpectUITests.this.resourceSetProvider.get();
					final Resource result = set.createResource(uri);
					result.load(stream, null);
					return (((XtextResource) result));
				} catch (Throwable _e) {
					throw Exceptions.sneakyThrow(_e);
				}
			}
		});
	}
}