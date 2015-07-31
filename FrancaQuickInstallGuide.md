# Franca Quick Install Guide #

## Overview ##

Franca comes as a set of Eclipse plugins, which are based on several features from Eclipse Modeling project. You may fork the sources or download the latest update site from the **Download** section.


## How to install from update site ##

Install Franca from scratch by following these steps:
  1. Download the distribution _Eclipse IDE for Java and DSL Developers_ for _Eclipse Luna_ from [here](https://eclipse.org/downloads/packages/eclipse-ide-java-and-dsl-developers/lunar) and install it.
    * Note: Franca is using Java 6. Please ensure that Eclipse is running with a JDK1.6.x installation.
    * Note: Franca 0.9.1 or later needs Xtend/Xtext with minimum version 2.5. However, We recommend using Xtend/Xtext 2.7.
    * This installation will also work with different Eclipse distributions, e.g. the _Eclipse Modeling Tools_ distribution or some proprietary IDE compilation. In some cases, it might be needed to add _http://download.itemis.com/updates/releases_ to the list of available sites (select _Window > Preferences... > Install/Update > Available Software Sites_). Afterwards you might have to install "Eclipse Xtend" (latest 2.7.x release) from Eclipse Marketplace.
  1. Start _eclipse.exe_ and create a new workspace.
  1. Some Franca extensions depend on additional Eclipse plugin packages. Install them now, if you plan to install the extension.
    * For _D-Bus Introspection_ support: There is an update site on the [dbus-emf-model homepage](https://github.com/kbirken/dbus-emf-model). Install the model.emf.dbusxml plugin via _Help > Install new software..._ using the following update site link: _http://kbirken.github.io/dbus-emf-model/releases/_ (this won't work in the browser). Use Franca 0.9.2 together with dbus-emf-model 0.8.0.
    * For the _Franca UI Add-ons_: Install the _KIELER Lightweight Diagrams - Developer Resources & Examples_ feature of the _KIELER_ open-source framework. Select _Help > Install new software..._ and choose the following update  site: [KIELER Nightly](http://rtsys.informatik.uni-kiel.de/~kieler/updatesite/nightly). Note: Installing the Add-ons feature of older Franca versions (0.9.1 or earlier) requires a different installation, see section _Installing older versions_ below.
  1. [Download](https://googledrive.com/host/0B7JseVbR6jvhazEtRDVsSk9mX1k) the latest Franca update site archive from the _Releases_ folder on Google Drive.
  1. Select _Help > Install New Software ..._, click _Add_ and select _Archive..._. Open the zipped update site downloaded before and complete the installation process.
    * For Franca 0.8.x and earlier: Install the feature _Franca Feature_.
    * For Franca 0.9.x and later: Install the features _Franca Runtime_ and _Franca UI_.
    * Optionally install the features _Franca D-Bus support_ and _Franca D-Bus support UI_. Refer to the Franca User Guide for more information on this feature.
    * Optionally install the _Franca User Interface Add-ons_. This will provide a graphical view for Franca interface contracts.
    * For all features, you may install the SDK version instead the non-SDK version in order to additionally get the source code (useful for debugging and diving deeper into the Franca implementation).
  1. Ready! Now you may create a new empty project in your workspace, add some files with extension **.fidl** and edit them with Franca's IDL editor.

If you have an old Franca User Guide, it might contain installation instructions in its _Getting Started_ chapter. These are outdated.


## Installing older versions ##

### Franca 0.9.1 ###

Due to dependency issues, the Add-ons feature cannot be installed for Franca 0.9.1, see [issue 142](https://code.google.com/a/eclipselabs.org/p/franca/issues/detail?id=142) for more information.

### Franca 0.9.0 and earlier ###

The Add-ons feature of Franca 0.9.0 and earlier versions depends on GEF4/Zest (instead of the KIELER framework). Therefore, the following instructions apply for installation of Add-ons for 0.9.0 and earlier:
  * Install the _Graphical Editing Framework Zest Visualization Toolkit_ feature of the _GEF4 Zest_ open-source project. Select _Help > Install new software..._ and choose the following update  site: [GEF4 Zest](http://franca.eclipselabs.org.codespot.com/git/update_site/thirdparty/gef4/0.1.0.201312280305). Note: Franca 0.9.x or earlier will not install with GEF4 Zest versions 0.1.0.201312280305 or later; hence select 0.1.0.201312280305 or earlier (deselect checkbox "Show only the latest versions of available software").

Note that this will only install with Eclipse version Kepler and earlier.


## Troubleshooting ##

If you experience downloads getting stuck due to server/network traffic, try to increase the download timeouts by adding the following lines to the _eclipse.ini_ file of your Eclipse installation (put them right after the -vmargs line) and restarting Eclipse afterwards:
```
-Dorg.eclipse.ecf.provider.filetransfer.retrieve.closeTimeout=9000
-Dorg.eclipse.ecf.provider.filetransfer.retrieve.readTimeout=9000
```


## Where to go from here ##

You may download the source snapshot of the _org.franca.examples.basic_ project now (see Download area) and import it into your workspace. See the _Getting Started_ in the Franca User Guide for more information and where to go from here.