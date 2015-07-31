# Franca Source Install Guide #

## Overview ##

Franca comes as a set of Eclipse plugins, which are based on several features from Eclipse Modeling project. This guide gives a step-by-step procedure to install Franca sources. This might be necessary if you like to review them, make local changes or contribute to the Franca project.

_For Franca users_: We don't recommend using the source installation. Please install Franca from the latest update site instead, which is much easier. See the [Franca Quick Install Guide](http://code.google.com/a/eclipselabs.org/p/franca/wiki/FrancaQuickInstallGuide) for detailed instructions.


## How to install Franca sources ##

Remark: As a complex setup is involved (Eclipse, maven, ...), the instructions might depend on your local configuration (proxy setting, etc.). Pls report issues for these instructions, if you run into problems during the installation.

  1. Download the distribution _Eclipse IDE for Java and DSL Developers_ for _Eclipse Luna_ from [here](https://eclipse.org/downloads/packages/eclipse-ide-java-and-dsl-developers/lunar) and install it.
    * Note: Franca is using Java 6. Please ensure that Eclipse is both running with a JDK1.6.x installation and uses the appropriate compiler compliance level ( select _Window > Preferences... > Java > Compiler_)
  1. Install support for Xtext-related unit tests from [this update site](http://xtext-utils.eclipselabs.org.codespot.com/git.distribution/releases/unittesting-0.9.x) via _Help > Install new software..._.
  1. Install the Xpect framework (current version 0.1.0) from [this update site](http://www.xpect-tests.org/updatesite/nightly/) via _Help > Install new software..._.
  1. Franca depends on some additional Eclipse plugin packages. Install them now.
    * _D-Bus Introspection_ support: There is an update site on the [dbus-emf-model homepage](https://github.com/kbirken/dbus-emf-model). Install the model.emf.dbusxml plugin via _Help > Install new software..._.
    * For the _Franca UI Add-ons_: Install the _Graphical Editing Framework Zest Visualization Toolkit_ feature of the _GEF4 Zest_ open-source project. Select _Help > Install new software..._ and choose the following update site: [GEF4 Zest](http://download.eclipse.org/tools/gef/gef4/updates/integration).
  1. Get a local copy of the _Franca git repository_ from here: https://code.google.com/a/eclipselabs.org/p/franca/source/checkout
  1. Import the Eclipse projects from your local repository into your Eclipse workspace via _File > Import..._, _General > Existing Projects into Workspace..._
    * Ensure that _Copy projects into workspace_ is not checked.
    * You don't have to import the example project _org.franca.examples.basic_ and all other projects with prefix _org.franca.examples_
  1. If you want to use _Maven Integration for Eclipse_ (M2E) on a _Windows_ system:
    * On a _Windows_ system, you might have to reconfigure the location of your local Maven repository. By default, it will be located in the user's home directory, which usually contains a path segment like _Documents and Settings_. The whitespaces in the repository path will spoil the Maven build due to some limitations in the toolchain. Thus, you should provide a _settings.xml_ file with an entry similar to the following:
```
<localRepository>C:/maven_repository</localRepository>
```
  1. Locate the target file _franca-luna.target_ in the _releng/org.franca.targetplatform_ project and open it. The target platform should be resolved now (this will take a while). After resolving is done, select _Set as target platform_ in the target platform editor window.
  1. Trigger maven build of all Franca plugins (starting from _org.franca.parent/pom.xml_, _Run As..._ from context menu).
    * Enter _clean install_ in the _Goals_ field.
    * If you’re located behind a proxy, ensure to have the Maven proxy configuration properly set as described in http://maven.apache.org/guides/mini/guide-proxies.html
    * If you get an out of memory error during build, jump to the _JRE_ tab and add _-Xmx256m_ in the _VM arguments_ field.
    * If you get a PermGen space  error during build, jump to the _JRE_ tab and add _-XX:MaxPermSize=256m_ in the _VM arguments_ field.
  1. Start an _Eclipse Runtime Instance_ and import the _org.franca.examples.basic_ project to its workspace.
    * In order to do this, use one of the launch configurations in the _launch_ folder of the _plugins/org.franca.dsl.ui_ plug-in.
    * Be sure you’ve updated your package explorer view. In order to do that, select all _org.franca.`*`_ projects and update them via F5
    * Right click on _org.franca.core_ to get the context menu and then call _1 Eclipse Application_ from _Run As..._
  1. The Franca IDL editor should be available now, the generators from the example project should run properly.


## Where to go from here ##

See the _Getting Started_ in the Franca User Guide for more information and where to go from here. You now will be able to do changes on the Franca sources and run/debug them using the Eclipse Runtime Instance. You should be familiar with _git_ in order to manage your changes and finally trigger a _pull_ proposal.