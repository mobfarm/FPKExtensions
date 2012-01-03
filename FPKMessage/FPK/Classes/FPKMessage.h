//  
//  FastPdfKit Extension
//

#import <UIKit/UIKit.h>
#import <FPKShared/FPKView.h>
#import <Common/DDSocialDialog.h>

/**
This Extension let you present a text message inside a Popup view like the Twitter login screen.
It uses the **DDSocialDiaolog** from the **FPKShared** folder.

## Params

*/

@interface FPKMessage : UIView <FPKView, DDSocialDialogDelegate>{
    CGRect _rect;
}
@end
