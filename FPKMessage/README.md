# FPKMessage Extension

This extension let you present a message as popup if the user taps on an annotation.

## Uri

### Prefix

	message://

### Resources and Parameters

* any resource
	* *title* = **STRING** use %20 instead of spaces
	* *message* = **STRING** use %20 instead of spaces
	* *h* = **FLOAT**: popup height
	* *w* = **FLOAT**: popup width

`message://?title=Complete%20title&w=300.0&h=200.0&message=This%20is%20the%20message!`