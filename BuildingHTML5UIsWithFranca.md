# Building HTML5 UIs with Franca #

_By Klaus Birken, itemis AG_


# Introduction #

HTML5 UIs are en vogue, for applications on smartphones and tablets as well as for embedded devices like in-vehicle infotainment systems. How do HTML5 applications access the underlying data model? A well-known solution is to use the WebSocket standard (RFC 6455, standardized by IETF in 2011). This text shows how Franca helps building these applications by providing a code generator for JavaScript from Franca interfaces.

# Generate JavaScript from Franca interfaces #

Franca's _org.franca.generators_ project offers JavaScript generators for the client and server side. For the client side, a proxy is generated from each Franca interface. On the server side, a stub is generated. The generated stub will create a WebSocket on a configurable port and listen for client connections. The generated proxy will connect to a WebSocket on a configurable port and will listen for notifications of broadcasts. The implementation is using the standard WAMP protocol on top of the WebSocket layer.

The server side implementation is based on the _node.js_ framework. In an embedded product, one would likely not use a JavaScript server side, but a C++ implementation instead. See below (section _Next steps_) for some details on this solution.

You can find the JS generators for client-side and server-side in the [Franca git repo](http://code.google.com/a/eclipselabs.org/p/franca/source/browse/#git%2Fplugins%2Forg.franca.generators%2Fsrc%2Forg%2Ffranca%2Fgenerators%2Fwebsocket/). This is not part of a Franca release yet, but is planned to be part of Franca 0.9.0.

The generators currently support attributes, methods and broadcasts (and enumerations...).
The generated code does not care about data types, because both parts (client and server) are in JS and thus we can use JSON without any further marshalling/demarshalling.


# HTML5 UI Example projects #

## Simple example project ##

Franca provides an example project which can be used to quickly set up a showcase, test the generators, and contribute to the project by extending the generators or provide new ones. The example project contains the _SimpleUI.fidl_ sample interface, which basically consists of one method and one broadcast.

Here is a screenshot of the example project:

![http://franca.eclipselabs.org.codespot.com/git/docs/resources/WebsocketExample.png](http://franca.eclipselabs.org.codespot.com/git/docs/resources/WebsocketExample.png)

The "server" folder contains the server-side and a README. You have to run the _WebsocketGenTest_ JUnit test in order to generate the JS code for server and client side from _SimpleUI.fidl_. The example server starts a poor-man's HTTP server on port 8080 (hosting the static parts for the client) and a WebSocket server on port 9000.

The example project sources are located in examples/[org.franca.examples.websockets](http://code.google.com/a/eclipselabs.org/p/franca/source/browse/#git%2Fexamples%2Forg.franca.examples.websockets/).

## Extended example project ##

There is an extended example project with additional functionality (multi-page app,
using jQuery Mobile, etc). This example project can be found on github:
https://github.com/kbirken/franca-html5-showcase.


# Next steps #

It would be the ultimate goal to provide a [CommonAPI C++](http://projects.genivi.org/commonapi/) middleware implementation for the websocket server side. I.e., use libwebsocket or onion on the server side and a C++ JSON parser for serialization. A CommonAPI C++ generator for this environment would have to be implemented. With this solution, any C++ component could provide services (modeled by Franca) with a transparent CommonAPI server-side.

Currently we are not planning to implement this kind of code generator, but if you are interested to contribute, please contact me. We maybe could set up an interest group and push it forward.