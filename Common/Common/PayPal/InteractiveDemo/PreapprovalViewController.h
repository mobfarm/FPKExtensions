
#import <UIKit/UIKit.h>
#import "TextFieldTableViewController.h"
#import "PayPal.h"

typedef enum PreapprovalStatuses {
	PREAPPROVALSTATUS_SUCCESS,
	PREAPPROVALSTATUS_FAILED,
	PREAPPROVALSTATUS_CANCELED,
} PreapprovalStatus;

@interface PreapprovalViewController : TextFieldTableViewController <PayPalPaymentDelegate> {
@private
	PayPalButtonType buttonType;
	PayPalButtonText buttonText;
	
	PreapprovalStatus preapprovalStatus;
}

@property (nonatomic, retain) NSString *preapprovalKey;
@property (nonatomic, retain) NSString *merchantName;

@property (nonatomic, assign) PayPalButtonType buttonType;
@property (nonatomic, assign) PayPalButtonText buttonText;

@end
