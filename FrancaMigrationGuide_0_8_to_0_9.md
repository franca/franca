# Franca Migration Guide: 0.8 to 0.9 #

## Introduction ##

This document gives instructions about migrating from Franca 0.8 to Franca 0.9. There are different sections for users of Franca IDL and clients of the Franca model API. The former are using Franca tools to create, edit and review interface definitions, the latter are writing backend tools, e.g., code generators or model transformations. We also provide a section about the changes in how to install Franca.

This page explicitly mentions aspects which are not backward compatible in 0.9 and require actions in adapting existing interface definitions (see section _For users..._) or code generators and other downstream tools (see section _For developers..._). Franca 0.9.0 provides a lot of new features and tools, which are not mentioned here. For those, please refer to [Franca Release History](https://drive.google.com/folderview?id=0B7JseVbR6jvhYlMweTRZUjFpVXc),

**Note:** This document might not be complete yet. If you find additional issues which should be mentioned on this page, please contact klaus.birken@gmail.com.


## For users of Franca IDL ##

We tried hard to maintain backward compatibility for the IDL in order to avoid changing of existing interface definitions. However, some restrictions have been applied explicitly to improve the language semantics. See the following items for instructions of how to adapt your interface definitions to 0.9.

### New validation rules on types: struct, union, enumeration ###

Some additional restrictions have been applied for struct, union and enumeration type definitions:
  * unions without elements and enumerations without enumerators are disallowed now
  * the duplicate element name check for unions and structs now respects base unions or structs, respectively (inherited elements must not anymore have the same name as derived elements)
  * the duplicate type check for unions respects base unions now
  * the duplicate name check for enumerations respects base enumerations now

For details, see issues [70](https://code.google.com/a/eclipselabs.org/p/franca/issues/detail?id=70) and [89](https://code.google.com/a/eclipselabs.org/p/franca/issues/detail?id=89).


### Names of interfaces and type collections ###

The names of interfaces and type collections have to be simple identifiers starting with Franca 0.9.0. Previously, fully qualified names could be used. In order to adapt your interface definitions to this new restriction, put the first part of the former fully qualified name into the package declaration at the beginning of the Franca IDL file. Thus, the interface or type collection name as seen from the outside will not be changed.

For details, see issue [73](https://code.google.com/a/eclipselabs.org/p/franca/issues/detail?id=73).


### Default values for enumerators ###

In former Franca versions, the default values for enumerators could only be specified by string values. Starting with Franca 0.9.0, the default values should be specified by integer numbers. In order to avoid breaking backward compatibility, using string values is still allowed, but will be marked with a _Deprecated_-warning.

We plan to remove the string value option in a later Franca version, so you should replace the default values by integer values while using 0.9.0.

For details, see issue [52](https://code.google.com/a/eclipselabs.org/p/franca/issues/detail?id=52).


## For developers of back-end tools ##

This section gives information about how to adapt existing code generators or model transformations for migrating from Franca 0.8 to 0.9.

### Boolean flags instead of string attributes ###

In the model API, boolean flags have been implemented as nullable string attributes, which leads to clumsy code for retrieving the boolean value of the flag. This has been improved now for the following attributes:
  * FAttribute.readonly
  * FAttribute.noSubscriptions
  * FAttribute.array (implicit array)
  * FMethod.fireAndForget
  * FBroadcast.selective
  * FArgument.array (implicit array)
  * FField.array (implicit array)
  * FDeclaration.array (implicit array)

### New model elements which should be handled ###

For Franca 0.9.0, many backward-compatible IDL extensions have been introduced. Although the interface designers do not have to adapt their models, they might use those new features. Thus, code generators or transformations should take those new IDL features into account. Here is the list of these features:
  * constants can now be defined, including initializer expressions (see issue [74](https://code.google.com/a/eclipselabs.org/p/franca/issues/detail?id=74)): new attribute `FTypeCollection.constants` and `FInterface.constants`
  * extended way of defining default values for enumerators (see issue [52](https://code.google.com/a/eclipselabs.org/p/franca/issues/detail?id=52)): `FEnumerator.value` is an `AdditiveExpression` now (with an underlying typesystem). Use `ExpressionEvaluator.evaluateIntegerOrParseString` as a helper for computing the actual value.
  * several extensions to Franca's contract syntax, especially the action language (see issue [55](https://code.google.com/a/eclipselabs.org/p/franca/issues/detail?id=55))
  * new range-based integer types (see issue [18](https://code.google.com/a/eclipselabs.org/p/franca/issues/detail?id=18)): new attribute `FTypeRef.interval`. Check out `IntegerTypeConverter` as a preprocessor for existing backend tools, it will help converting range-based integer into existing predefined integer types.


## And how did the installation procedure of Franca change? ##

For Franca 0.9.0, we did a major redesign of the Franca feature structure. The overall goal was a more fine-grain feature structure, which allows selecting Franca parts in a more modular way. During installation of the update site, you will recognize that there are many more features now:

  * _Runtime_ and _UI_ features are separated now for the various aspects, e.g., Franca Core or D-Bus Connector. This will help to provide standalone generators or transformations which do not need the UI parts.
  * The dependency structure of features is now modeled explicitly. This should avoid problems when selecting a proper subset of features for installation.
  * JDT dependencies are optional now (this is for our CDT users). On startup, Franca will detect if JDT is available. If not, classpath-imports will not be resolved (because they depend on a proper JDT), but all other features of Franca should still be available.