
#import <UIKit/UIKit.h>
#import "PayPal.h"

typedef enum PaymentStatuses {
	PAYMENTSTATUS_SUCCESS,
	PAYMENTSTATUS_FAILED,
	PAYMENTSTATUS_CANCELED,
} PaymentStatus;

@interface FourButtonViewController : UIViewController <PayPalPaymentDelegate, UITextFieldDelegate> {
	@private
	UITextField *preapprovalField;
	CGFloat y;
	BOOL resetScrollView;
	PaymentStatus status;
}

@property (nonatomic, retain) UITextField *preapprovalField;

@end
