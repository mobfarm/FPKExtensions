# FastPdfKit Extensions

In this repository you'll find every annotation supported out of the box by FastPdfKit. You can place a pull request to add your own **extension**.

## Structure

Each Extension is packed in its own **framework**. The framework is a fake framework created with the amazing [iOS-Universal-Framework](https://github.com/kstenerud/iOS-Universal-Framework) created by [Karl Stenerud](https://github.com/kstenerud).

We've chosen this approach to maintain separated the classes, images and xibs of each Extension and let you choose which one add to your app, just dragging the corresponding framework.

## Available Extensions

FPK Prefix identifies an official extension and will be 

* FPKYouTube
* FPKMap
* FPKMovie
* FPKAudio
* FPKWebUdid
* FPKTransitionGallery
* FPKTouchGallery
* FPKSlidingGallery
* FPKMessagePopup
* FPKiCarouselPopup
* FPKWeb
* FPKImagePopup
* FPKVideoPopup
* FPKNavigation
* FPKEmail
* FPKiMessage
* FPKShareKit
* FPKScreenshot
* FPKVerticalImageGallery

## Create an Extension

To create an Extension you can create a copy of the **FPKSampleExtension** folder and open it with Xcode.

Rename the target and the project with a descriptive name.

Add your objects to the projects, classes, xibs and images. Please name the images and the xib document with a prefix, so they doesn't conflict with other extension ones. You can even pack the xibs and images in a bundle.

Add every document to the framework target and build for iOS Device.

A new folder called ExtensionName.embeddedframework will appear in the project root.

You need to set as public just the headers that you need to access from the external project.

If you need to use the same classes for many Extensions you should add them in a separate Framework. For ours we use the FPKShared extension.

## Use an Extensions

To use the Extension in a project that uses FastPdfKit, just drag the .embeddedframework folder in the Xcode Navigation Bar.

Then `#import` the `<ExtensionName/ExtensionName.h>` in your `MFOverlayDataSource` subclass.

Add the ExtensionName as string to the `extensions` array.

The standard `extensions` array should contain every supported Extension like 

    NSArray *extensions = [NSArray arrayWithObjects:@"FPKYouTube",
													@"FPKMap",
											 		@"FPKTransitionGallery", 
											 		@"YourExtensionName",
											 		nil];