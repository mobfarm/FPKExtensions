
#import <UIKit/UIKit.h>
#import "PayPalInvoiceItem.h"

@protocol InvoiceItemDelegate <NSObject>

@required
- (void)doneEditingInvoiceItem:(PayPalInvoiceItem *)item;

@end



@interface InvoiceItemViewController : UIViewController <UITextFieldDelegate> {
@private
	PayPalInvoiceItem *invoiceItem;
	id<InvoiceItemDelegate> delegate;
}

@property (nonatomic, assign) PayPalInvoiceItem *invoiceItem;
@property (nonatomic, assign) id<InvoiceItemDelegate> delegate;

@end
