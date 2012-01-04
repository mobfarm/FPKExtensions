# FastPdfKit Extensions

In this repository you'll find every official Extension for [FastPdfKit](http://git.io/fpk).

The [complete documentation](http://doc.fastpdfkit.com/Extensions) for **FPKExtensions** is available [here](http://doc.fastpdfkit.com/Extensions), the one for [FastPdfKit](http://doc.fastpdfkit.com) is available [here](http://doc.fastpdfkit.com).

**Xcode docset** are also available: there are feeds for [FPKExtensions](http://doc.fastpdfkit.com/Extensions/docset.atom) and [FastPdfKit](http://doc.fastpdfkit.com/docset.atom).

Visit [fastpdfkit.com](http://fastpdfkit.com) to learn more about **FastPdfKit**.

## Key Concept
**You can place any custom view over a pdf page just using standard pdf hyperlinks and FastPdfKit.** 

Extensions are designed to easily create the custom views.

## Available Extensions
**FPK** as name prefix identifies an official extension

* [FPKPayPal](http://doc.fastpdfkit.com/Extensions/Classes/FPKPayPal.html) to create **catalogs** with **items** that can be **purchased** directly **from the app**;
* [FPKYouTube](http://doc.fastpdfkit.com/Extensions/Classes/FPKYouTube.html) to place **YouTube** video on the page.
* [FPKGallerySlide](http://doc.fastpdfkit.com/Extensions/Classes/FPKGallerySlide.html) interactive **image gallery** with manual or automatic advancement;
* [FPKMap](http://doc.fastpdfkit.com/Extensions/Classes/FPKMap.html) to render an interactive google map;
* [FPKGalleryFade](http://doc.fastpdfkit.com/Extensions/Classes/FPKGalleryFade.html) image gallery useful for the table of contents;
* [FPKGalleryTap](http://doc.fastpdfkit.com/Extensions/Classes/FPKGalleryTap.html) to create a multi interactive image gallery;
* [FPKMessage](http://doc.fastpdfkit.com/Extensions/Classes/FPKMessage.html) to show details or alerts;
* [FPKWebPopup](http://doc.fastpdfkit.com/Extensions/Classes/FPKWebPopup.html) to open a **web page** in a popup view;

**FPKShared** contains some shared classes needed for every official Extension. Probably you'll find useful classes.

**Common** contains some third party shared classes.

## Out of the box overlays
FastPdfKit supports some overlays out of the box like videos, sounds and web pages. If you like the way they works you can use them, otherwise you're free to develop your own solutions.

**Remote** is something on the web.

**Local** is something that resides in the [resourceFolder](http://doc.fastpdfkit.com/Classes/MFDocumentManager.html#//api/name/resourceFolder) defined in the [MFDocumentManager](http://doc.fastpdfkit.com/Classes/MFDocumentManager.html).

<table>
    <tr>
        <td width="100"><b>Type</b></td><td width="60"><b>Local</b></td><td width="60"><b>Remote</b></td>
    </tr>
    <tr>
        <td>Overlay Movie</td><td>fpkv://</td><td>fpky://</td>
    </tr>
    <tr>
        <td>Modal Movie</td><td>fpke://</td><td>fpkz://</td>
    </tr>
    <tr>
        <td>Overlay HTML</td><td>fpkh://</td><td>fpkw://</td>
    </tr>
    <tr>
        <td>Modal HTML</td><td>fpki://</td><td>http://</td>
    </tr>
    <tr>
        <td>Overlay Audio</td><td>fpka://</td><td>fpkb://</td>
    </tr>
</table>

## What is an Extension?

FastPdfKit is starting to be largely used for pdf documents, but many **developers** asked us to give them an easy way to **interact with the pdf pages** and in particular **add overlay views** on the document.

Overlay views can be useful for **magazines, newspapers, catalogs, textbooks, reports** and many other implementations. But any publisher needs an easy way to **customize the content** of the overlays and **create new ones** to fulfill his needs. So we created the Extension concept and the classes behind it.

Extensions are designed to add custom overlay views over a pdf page, but you can also add any other feature to enhance FastPdfKit.

Extension are working out of the box with **PDF hyperlinks**. Any pdf viewer like Apple *Preview* or Adobe *Acrobat Reader* can add hyperlinks on existing pdf documents. Also any PDF authoring tool like Adobe *InDesign* and Apple *Pages* can add them.

The **key concept** is that you define a **custom url** and if FastPdfKit finds a **link of that kind** in the pdf page, automatically creates an instance of the Extension and **places the `UIView` over the page**.

A world of opportunities is now open.

## Sample Project

Open the *SampleProject* folder and you'll find the Sample Xcode Project.

Just launch it for Simulator or Device and you'll get a [sample pdf](https://github.com/mobfarm/FPKExtensions/blob/master/SampleProject/SampleProject/Resources/sample.pdf) (the original InDesign document is also [included](https://github.com/mobfarm/FPKExtensions/blob/master/SampleProject/SampleProject/Resources/sample.indd)) with and example of every official annotation and the relative url.

## Structure

Each Extension is packed in its own **framework**. The framework is a *fake framework* created with the amazing [iOS-Universal-Framework](https://github.com/kstenerud/iOS-Universal-Framework) by [Karl Stenerud](https://github.com/kstenerud).

We've chosen this approach to maintain separated the classes, images and xibs of each Extension and let you choose which one add to your app, just dragging the corresponding framework.

## Activate an Extensions

To use the Extension in a project that uses FastPdfKit, just drag the .embeddedframework folder in the Xcode Navigation Bar.

Then `#import` the `<ExtensionName/ExtensionName.h>` in your `MFOverlayDataSource` subclass.

Add the ExtensionName as string to the `extensions` array.

The standard `extensions` array should contain every supported Extension like 

    NSArray *extensions = [NSArray arrayWithObjects:@"FPKYouTube",
													@"FPKMap",
											 		@"FPKTransitionGallery", 
											 		@"YourExtensionName",
											 		nil];

											
## Support Extensions in your FastPdfKit application

To add an Extension to your application you need create a subclass of [FPKOverlayManager](http://doc.fastpdfkit.com/Extensions/Classes/FPKOverlayManager.html), just like [OverlayManager](https://github.com/mobfarm/FPKExtensions/blob/master/SampleProject/SampleProject/OverlayManager.m) in the sample project.

Add the **FPKShared.embeddedframework** to the Navigation bar.
Then simply drag the desired Extension .embeddedframework folder to the Navigation bar, for example the **FPKYouTube.embeddedframework**. 

In the **FPKOverlayManager** subclass `#import` the framework.

	#import <FPKYouTube/FPKYouTube.h>
	
And add the Extension name as `NSString` to the Extensions array like `@"FPKYouTube"` in the custom init method.

	- (FPKOverlayManager *)init
	{
		self = [super init];
		if (self != nil)
		{
			[self setExtensions:[[NSArray alloc] initWithObjects:@"FPKMap", @"FPKYouTube", nil]];
		}
		return self;
	}


## Create an Extension

To create an Extension you can create a copy of the **FPKSampleExtension** folder and open it with Xcode.

* **Rename the target** and the project with a descriptive name.

* **Add your objects** to the projects, classes, xibs and images. Please name the images and the xib document with a prefix, so they doesn't conflict with other extension ones. You can even pack the xibs and images in a bundle.

* Add every document to the framework target and **build for iOS Device**.

* You need to set as **public** just the headers that you need to access from the external project.

* A new folder called ExtensionName.embeddedframework will appear in the **project root**.

* If you need to use the same classes for many Extensions you should add them in a separate Framework. For ours we use the **FPKShared**.

* For code not developed by us, we've created the **Common** framework to help you get the latest code an avoid conflicts.

## Feedback

If you need or want suggest an Extension you can create a new [Feature Request](https://github.com/mobfarm/FPKExtensions/issues/new). 

There's also the [support](http://support.fastpdfkit.com) website where you can find the [Knowledge Base](http://support.fastpdfkit.com/kb) and some [Discussions](http://support.fastpdfkit.com/discussions).

If you've developed an Extension and want to **share it** with the community, please send a **pull request** on [github](http://git.io/fpke).

If you are using FastPdfKit **let us know**, we will be happy to list your app!

## In development Extensions

* **FPKConfig**
* **FPKGlobalConfig**
* **FPKTextSelection**
* **FPKiCarouselPopup**
* **FPKImagePopup**
* **FPKVideoPopup**
* **FPKEmail**
* **FPKiMessage**
* **FPKShareKit**
* **FPKScreenshot**
* **FPKGalleryVertical**
