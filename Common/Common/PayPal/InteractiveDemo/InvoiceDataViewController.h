
#import <UIKit/UIKit.h>
#import "TextFieldTableViewController.h"
#import "PayPalInvoiceData.h"
#import "InvoiceItemViewController.h"


@protocol InvoiceDataDelegate <NSObject>

@required
- (void)doneEditingInvoiceData;

@end


@interface InvoiceDataViewController : TextFieldTableViewController <InvoiceItemDelegate> {
@private
	PayPalInvoiceData *invoiceData;
	id<InvoiceDataDelegate> delegate;
}

@property (nonatomic, assign) PayPalInvoiceData *invoiceData;
@property (nonatomic, assign) id<InvoiceDataDelegate> delegate;

@end
