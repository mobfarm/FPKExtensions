
#import <UIKit/UIKit.h>
#import "TextFieldTableViewController.h"
#import "PayPal.h"
#import "ListChoiceViewController.h"
#import "ReceiverViewController.h"

typedef enum PaymentStatuses {
	PAYMENTSTATUS_SUCCESS,
	PAYMENTSTATUS_FAILED,
	PAYMENTSTATUS_CANCELED,
} PaymentStatus;

@interface PaymentViewController : TextFieldTableViewController <PayPalPaymentDelegate, ListChoiceDelegate, ReceiverDelegate, InvoiceDataDelegate> {
@private
	PayPalPayment *payment;
	PayPalAdvancedPayment *advancedPayment;

	UISwitch *shippingSwitch;
	UISwitch *dynamicAmountCalculationSwitch;
	
	NSArray *feePayerStrings;
	NSArray *paymentTypeStrings;
	NSArray *paymentSubTypeStrings;
	
	PayPalButtonType buttonType;
	PayPalButtonText buttonText;
	PayPalFeePayer feePayer;
	
	BOOL isAdvanced;
	PaymentStatus paymentStatus;
}

@property (nonatomic, retain) PayPalPayment *payment;
@property (nonatomic, retain) PayPalAdvancedPayment *advancedPayment;

@property (nonatomic, retain) UISwitch *shippingSwitch;
@property (nonatomic, retain) UISwitch *dynamicAmountCalculationSwitch;

@property (nonatomic, retain) NSArray *feePayerStrings;
@property (nonatomic, retain) NSArray *paymentTypeStrings;
@property (nonatomic, retain) NSArray *paymentSubTypeStrings;

@property (nonatomic, assign) PayPalButtonType buttonType;
@property (nonatomic, assign) PayPalButtonText buttonText;
@property (nonatomic, assign) PayPalFeePayer feePayer;

@property (nonatomic, assign) BOOL isAdvanced;

@end
