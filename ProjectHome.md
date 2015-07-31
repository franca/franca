# Welcome to Franca! #

Franca is a powerful framework for definition and transformation of software interfaces.
It is used for integrating software components from different suppliers, which are built based on various runtime frameworks, platforms and IPC mechanisms. The core of it is _Franca IDL_ (Interface Definition Language), which is a textual language for specification of APIs.

## Franca goes Eclipse ##

Franca will be established as an official Eclipse project. The proposal is available online: http://eclipse.org/proposals/modeling.franca/

## Franca features ##

As Franca is based on Eclipse, there are some powerful tools which can be used to work with Franca. Most important, Franca offers a user-friendly editor for reviewing and editing Franca IDL files.

The following diagram shows the major benefits of using Franca.

![http://franca.eclipselabs.org.codespot.com/git/docs/web/images/FrancaBenefits.png](http://franca.eclipselabs.org.codespot.com/git/docs/web/images/FrancaBenefits.png)

### Transformations and generation ###
Franca offers a framework for building transformations from/to other IDLs (e.g., D-Bus, Thrift or others) and code generation. We recommend using [Xtend](http://xtend-lang.org) for building the generators, but it is generally possible to use other tools and languages which are based on EMF models or Java APIs for the task.

Support for the D-Bus Introspection format is available as installable feature of Franca.

### Specification of dynamic behavior ###
With Franca, the dynamic behavior of client/server interactions can be specified using _protocol state machines_.
Tools are available to use these specifications for validating implementations, e.g., checking runtime traces against the expected order of events on the interface. A graphical viewer for protocol state machines is part of Franca.

### Flexible deployment models ###
In specific application domains, it may be necessary to extend interface specifications by platform- or target-specific information. This is supported by Franca's deployment models, which allow these kind of extensions in a type-safe way.
Thus, role-based development workflows can be established: Platform architects own the deployment specifications, whereas project architects and developers are responsible for providing the platform-specific data for their actual interfaces.

### Rapid interface prototyping ###
Generate a test environment for your interface instantly and see your interface in action! This is accomplished by generating [eTrice](http://eclipse.org/etrice) models from Franca interfaces and generate executable Java code from these models. The test environment will consist of a client component (acting as dynamic test case executor) and a server component (acting as an intelligent mock object).

## Franca and CommonAPI ##

If you want to generate C++ code directly from Franca interface specifications,
[CommonAPI C++](http://projects.genivi.org/commonapi) might be the proper solution.
It is designed to decouple generated API from the actual IPC stack and cooperates seamlessly with Franca.
CommonAPI was created in the context of the [GENIVI](http://genivi.org) initiative.

## Forum ##

For feedback and discussions around Franca there is a
Franca forum at Google Groups, see http://groups.google.com/group/franca-framework.

## Misc ##

There is an [online Franca presentation](http://ftp.itemis.de/presentations/franca_std/) available.
This can also be used nicely from smartphones and tablets.

The Franca framework has been built using the open source projects [EMF](http://www.eclipse.org/emf), [Xtext](http://www.xtext.org) and [Xtend](http://xtend-lang.org). Thanks to all committers of those projects for their great and helpful contributions!

![http://web-static-cloudfront.s3.amazonaws.com/images/badges/BuiltOnDEV.png](http://web-static-cloudfront.s3.amazonaws.com/images/badges/BuiltOnDEV.png)