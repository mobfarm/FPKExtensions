//  
//  FastPdfKit Extension
//

#import <UIKit/UIKit.h>
#import <FPKShared/FPKView.h>
#import <FPKShared/DDSocialDialog.h>

@interface FPKWebPopup : UIView <FPKView, DDSocialDialogDelegate>{
    CGRect _rect;
}
@end
