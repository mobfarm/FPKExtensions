//  
//  FastPdfKit Extension
//

#import <UIKit/UIKit.h>
#import <FPKShared/FPKView.h>
#import <FPKShared/DDSocialDialog.h>

/**
This Extension let you present a text message inside a Popup view like the Twitter login screen.
It uses the **DDSocialDiaolog** from the **FPKShared** folder.

## Usage

* Prefix: **message://**
* Import: **#import <FPKMessage/FPKMessage.h>**
* String: **@"FPKMessage"**

### Params

* title

### Sample url

	message://?title=The%20title&message=The%20message&h=400&w=300

*/

@interface FPKMessage : UIView <FPKView, DDSocialDialogDelegate>{
    CGRect _rect;
}
@end
