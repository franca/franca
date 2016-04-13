package org.franca.core.dsl.ui.contentassist;

import com.google.common.base.Joiner;
import com.google.common.base.Objects;
import com.google.inject.Inject;
import java.util.ArrayList;
import java.util.List;
import java.util.function.Consumer;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.jdt.internal.core.JavaProject;
import org.eclipse.jface.text.contentassist.ICompletionProposal;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.Assignment;
import org.eclipse.xtext.resource.IContainer;
import org.eclipse.xtext.resource.IResourceDescription;
import org.eclipse.xtext.resource.IResourceDescriptions;
import org.eclipse.xtext.resource.XtextResourceSet;
import org.eclipse.xtext.resource.impl.ResourceDescriptionsProvider;
import org.eclipse.xtext.ui.editor.contentassist.ConfigurableCompletionProposal;
import org.eclipse.xtext.ui.editor.contentassist.ContentAssistContext;
import org.eclipse.xtext.ui.editor.contentassist.ICompletionProposalAcceptor;
import org.eclipse.xtext.ui.editor.contentassist.ReplacementTextApplier;
import org.eclipse.xtext.xbase.lib.CollectionLiterals;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.franca.core.dsl.ui.contentassist.AbstractFrancaIDLProposalProvider;

@SuppressWarnings("all")
public class FrancaIDLProposalProvider extends AbstractFrancaIDLProposalProvider {
  @Inject
  private IResourceDescription.Manager descriptionManager;
  
  @Inject
  private IContainer.Manager containerManager;
  
  @Inject
  private ResourceDescriptionsProvider provider;
  
  public void completeImport_ImportURI(final EObject model, final Assignment assignment, final ContentAssistContext context, final ICompletionProposalAcceptor acceptor) {
    final ArrayList<String> platformResources = CollectionLiterals.<String>newArrayList();
    final ArrayList<String> classpathResources = CollectionLiterals.<String>newArrayList();
    Resource _eResource = model.eResource();
    ResourceSet _resourceSet = _eResource.getResourceSet();
    XtextResourceSet xtextresourceSet = ((XtextResourceSet) _resourceSet);
    Resource _eResource_1 = model.eResource();
    IResourceDescription _resourceDescription = this.descriptionManager.getResourceDescription(_eResource_1);
    Resource _eResource_2 = model.eResource();
    IResourceDescriptions _resourceDescriptions = this.provider.getResourceDescriptions(_eResource_2);
    List<IContainer> containers = this.containerManager.getVisibleContainers(_resourceDescription, _resourceDescriptions);
    Object classPathContext = xtextresourceSet.getClasspathURIContext();
    if ((classPathContext instanceof JavaProject)) {
      final Consumer<IContainer> _function = new Consumer<IContainer>() {
        public void accept(final IContainer it) {
          Iterable<IResourceDescription> _resourceDescriptions = it.getResourceDescriptions();
          final Function1<IResourceDescription, Boolean> _function = new Function1<IResourceDescription, Boolean>() {
            public Boolean apply(final IResourceDescription it) {
              URI _uRI = it.getURI();
              String _string = _uRI.toString();
              Resource _eResource = model.eResource();
              URI _uRI_1 = _eResource.getURI();
              String _string_1 = _uRI_1.toString();
              return Boolean.valueOf((!Objects.equal(_string, _string_1)));
            }
          };
          Iterable<IResourceDescription> _filter = IterableExtensions.<IResourceDescription>filter(_resourceDescriptions, _function);
          final Consumer<IResourceDescription> _function_1 = new Consumer<IResourceDescription>() {
            public void accept(final IResourceDescription it) {
              URI _uRI = it.getURI();
              String _classPathString = FrancaIDLProposalProvider.this.toClassPathString(_uRI);
              classpathResources.add(_classPathString);
            }
          };
          _filter.forEach(_function_1);
        }
      };
      containers.forEach(_function);
    }
    final Consumer<IContainer> _function_1 = new Consumer<IContainer>() {
      public void accept(final IContainer it) {
        Iterable<IResourceDescription> _resourceDescriptions = it.getResourceDescriptions();
        final Function1<IResourceDescription, Boolean> _function = new Function1<IResourceDescription, Boolean>() {
          public Boolean apply(final IResourceDescription it) {
            URI _uRI = it.getURI();
            String _string = _uRI.toString();
            Resource _eResource = model.eResource();
            URI _uRI_1 = _eResource.getURI();
            String _string_1 = _uRI_1.toString();
            return Boolean.valueOf((!Objects.equal(_string, _string_1)));
          }
        };
        Iterable<IResourceDescription> _filter = IterableExtensions.<IResourceDescription>filter(_resourceDescriptions, _function);
        final Consumer<IResourceDescription> _function_1 = new Consumer<IResourceDescription>() {
          public void accept(final IResourceDescription it) {
            URI _uRI = it.getURI();
            String _string = _uRI.toString();
            platformResources.add(_string);
          }
        };
        _filter.forEach(_function_1);
      }
    };
    containers.forEach(_function_1);
    String _prefix = context.getPrefix();
    boolean _equals = Objects.equal(_prefix, "\"classpath:");
    if (_equals) {
      final Consumer<String> _function_2 = new Consumer<String>() {
        public void accept(final String it) {
          FrancaIDLProposalProvider.this.createProposal(it, context, acceptor);
        }
      };
      classpathResources.forEach(_function_2);
    } else {
      String _prefix_1 = context.getPrefix();
      boolean _equals_1 = Objects.equal(_prefix_1, "\"platform:");
      if (_equals_1) {
        final Consumer<String> _function_3 = new Consumer<String>() {
          public void accept(final String it) {
            FrancaIDLProposalProvider.this.createProposal(it, context, acceptor);
          }
        };
        platformResources.forEach(_function_3);
      } else {
        final Consumer<String> _function_4 = new Consumer<String>() {
          public void accept(final String it) {
            FrancaIDLProposalProvider.this.createProposal(it, context, acceptor);
          }
        };
        platformResources.forEach(_function_4);
        final Consumer<String> _function_5 = new Consumer<String>() {
          public void accept(final String it) {
            FrancaIDLProposalProvider.this.createProposal(it, context, acceptor);
          }
        };
        classpathResources.forEach(_function_5);
      }
    }
    super.completeImport_ImportURI(model, assignment, context, acceptor);
  }
  
  public String toClassPathString(final URI uri) {
    String _xblockexpression = null;
    {
      List<String> _segmentsList = uri.segmentsList();
      final List<String> segments = this.classPathSegments(_segmentsList);
      StringConcatenation _builder = new StringConcatenation();
      _builder.append("classpath:/");
      Joiner _on = Joiner.on("/");
      String _join = _on.join(segments);
      _builder.append(_join, "");
      _xblockexpression = _builder.toString();
    }
    return _xblockexpression;
  }
  
  public List<String> classPathSegments(final List<String> list) {
    List<String> _xblockexpression = null;
    {
      int _size = list.size();
      List<String> sublist = list.subList(3, _size);
      _xblockexpression = sublist;
    }
    return _xblockexpression;
  }
  
  public void createProposal(final String name, final ContentAssistContext context, final ICompletionProposalAcceptor acceptor) {
    StringConcatenation _builder = new StringConcatenation();
    String _string = name.toString();
    _builder.append(_string, "");
    ICompletionProposal proposal = this.createCompletionProposal(_builder.toString(), context);
    if ((proposal instanceof ConfigurableCompletionProposal)) {
      ConfigurableCompletionProposal c = ((ConfigurableCompletionProposal) proposal);
      c.setTextApplier(new ReplacementTextApplier() {
        public String getActualReplacementString(final ConfigurableCompletionProposal proposal) {
          String _xblockexpression = null;
          {
            int _replaceContextLength = proposal.getReplaceContextLength();
            proposal.setReplacementLength(_replaceContextLength);
            StringConcatenation _builder = new StringConcatenation();
            _builder.append("\"");
            String _string = name.toString();
            _builder.append(_string, "");
            _builder.append("\"");
            _xblockexpression = _builder.toString();
          }
          return _xblockexpression;
        }
      });
    }
    acceptor.accept(proposal);
  }
}
