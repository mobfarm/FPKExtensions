# FPKMessage

This Extension let you present a text message inside a Popup view like the Twitter login screen.
It uses the **DDSocialDiaolog** from the **Common** framework.

## Usage

* Prefix: **message://**
* Import: **#import <FPKMessage/FPKMessage.h>**
* String: **@"FPKMessage"**

### Prefix

	message://

### Resources and Parameters

* any resource
	* *title* = **STRING** use %20 instead of spaces
	* *message* = **STRING** use %20 instead of spaces
	* *h* = **INT**: popup height
	* *w* = **INT**: popup width

### Sample url

	message://?title=The%20title&message=The%20message&h=400&w=300