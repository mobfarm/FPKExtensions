
#import <UIKit/UIKit.h>
#import "TextFieldTableViewController.h"
#import "PayPalReceiverPaymentDetails.h"
#import "InvoiceDataViewController.h"
#import "ListChoiceViewController.h"


@protocol ReceiverDelegate <NSObject>

@optional
- (void)didFinishEditingReceiver:(PayPalReceiverPaymentDetails*)theReceiver;

@end


@interface ReceiverViewController : TextFieldTableViewController <InvoiceDataDelegate, ListChoiceDelegate> {
@private
	PayPalReceiverPaymentDetails *receiver;
	id<ReceiverDelegate> delegate;
}

@property (nonatomic, assign) PayPalReceiverPaymentDetails *receiver;
@property (nonatomic, assign) id<ReceiverDelegate> delegate;

@end
