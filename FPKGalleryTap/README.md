# FPKGalleryTap Extension

This extension let you add some annotations on the pdf page to control an image in the same page. Tapping on each overlay you can set the main image.

## Uri

### Prefix

	gallerytap://

### Resources and Parameters

* **IMAGE_PATH**
	* *id* = **INT**

`gallerytap://img1.png?id=1`


* **button**
	* *target_id* = **INT**
	* *src* = **STRING**
	* *animate* = **BOOL**
	* *time* = **FLOAT**
	* *self* = **STRING**
	* *id* = **INT**
	* *r* = **INT**
	* *g* = **INT**
	* *b* = **INT**
	* *others* = **ARRAY** of **INT** (comma separated)


`gallerytap://button?target_id=1&src=img4.png&animate=YES&time=1.0&self=img4.png&id=4&r=255&g=0&b=0&others=3,4`