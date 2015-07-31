# Introduction #

This page is an informal collection of various scenarios of using Franca. It will be extended in future.


# Franca for persistency #

As Franca IDL supports detailed specification of data structures, it could also be used to specify data structures to be persisted on file or in a database. The attributes of a Franca interface could be interpreted as the data members which should be persisted.

Franca IDL doesn't specify serialization details like encoding, alignment or little/big endian. As with communication over an IPC channel, these details have to be specified by the underlying middleware, either by convention or by using a deployment model. A similar requirement arises when using Franca for persistency.

Thus, it might be interested to transfer the idea of "Common API" to this domain, leading to a "Common Serialization" or a "Common Persistency". The actual back-end (database, file, or a dedicated persistency component) doesn't have to be defined in the first place and can be added separately.