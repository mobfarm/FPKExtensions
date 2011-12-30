For the **FastPdfKit Reference** look at [doc.fastpdfkit.com](http://doc.fastpdfkit.com).

## Overview

Please read the [README](./docs/README.html) document that contains a brief introduction to the Extensions.

To get started with Extensions launch the **SampleProject** with Xcode.
Just Build and Run on the Simulator.

A very simple application will open with just one pdf with one set of annotations per page. Each set corresponds to one Extension.

If you are interested in **using existing extension** simply take a look at these classes and at the **SampleProject**:

* MainViewController and the actionOpenPlainDocument: method;
* OverlayManager with an example of `#import`ing frameworks.

If you want to **create your own extension** start dig into these classes:

* FPKExtension with the list of methods you need to implement;
* FPKYouTube the simplest Extension ever made;
* FPKOverlayManager to learn how the Extensions are managed.

## Classes