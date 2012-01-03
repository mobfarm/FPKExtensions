
#import "InvoiceItemViewController.h"
#import "TextFieldTableViewController.h"

#define fieldWithTag(tag) ((UITextField *)[self.view viewWithTag:tag])

typedef enum EditInvoiceItemFields {
	INVOICEFIELD_NAME = 610,
	INVOICEFIELD_ITEMID,
	INVOICEFIELD_ITEMCOUNT,
	INVOICEFIELD_ITEMPRICE,
	INVOICEFIELD_TOTALPRICE,
} EditInvoiceItemField;


@implementation InvoiceItemViewController

@synthesize invoiceItem, delegate;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	self.view = [[[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame] autorelease];
	self.view.autoresizesSubviews = FALSE;
	UIColor *color = [UIColor groupTableViewBackgroundColor];
	if (CGColorGetPattern(color.CGColor) == NULL) {
		color = [UIColor lightGrayColor];
	}
	self.view.backgroundColor = color;
	self.title = @"Edit Item";
	
	UITextField *field;
	field = [TextFieldTableInstance addTextFieldWithLabel:@"Name" tag:INVOICEFIELD_NAME toView:self.view required:FALSE type:UIKeyboardTypeDefault delegate:self];
	field.text = invoiceItem.name;
	field = [TextFieldTableInstance addTextFieldWithLabel:@"Item ID" tag:INVOICEFIELD_ITEMID toView:self.view required:FALSE type:UIKeyboardTypeDefault delegate:self];
	field.text = invoiceItem.itemId;
	field = [TextFieldTableInstance addTextFieldWithLabel:@"Item Count" tag:INVOICEFIELD_ITEMCOUNT toView:self.view required:FALSE type:UIKeyboardTypeNumbersAndPunctuation delegate:self];
	field.text = invoiceItem.itemCount == nil ? nil : [invoiceItem.itemCount stringValue];
	field = [TextFieldTableInstance addTextFieldWithLabel:@"Item Price" tag:INVOICEFIELD_ITEMPRICE toView:self.view required:FALSE type:UIKeyboardTypeNumbersAndPunctuation delegate:self];
	field.text = invoiceItem.itemPrice == nil ? nil : [TextFieldTableInstance.formatter stringFromNumber:invoiceItem.itemPrice];
	field = [TextFieldTableInstance addTextFieldWithLabel:@"Total Price" tag:INVOICEFIELD_TOTALPRICE toView:self.view required:FALSE type:UIKeyboardTypeNumbersAndPunctuation delegate:self];
	field.text = invoiceItem.totalPrice == nil ? nil : [TextFieldTableInstance.formatter stringFromNumber:invoiceItem.totalPrice];
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[delegate doneEditingInvoiceItem:invoiceItem];
	self.invoiceItem = nil;
	self.delegate = nil;
    [super dealloc];
}


#pragma mark -
#pragma mark UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return TRUE;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
	if (text.length == 0) {
		text = nil;
	}
	switch(textField.tag){
		case INVOICEFIELD_NAME:
			invoiceItem.name = text;
			break;
		case INVOICEFIELD_ITEMID:
			invoiceItem.itemId = text;
			break;
		case INVOICEFIELD_ITEMCOUNT:
			invoiceItem.itemCount = text == nil ? nil : [NSNumber numberWithInt:[text intValue]];
			break;
		case INVOICEFIELD_ITEMPRICE:
			invoiceItem.itemPrice = [TextFieldTableInstance decimalNumberForField:textField range:range string:string];
			return FALSE;
		case INVOICEFIELD_TOTALPRICE:
			invoiceItem.totalPrice = [TextFieldTableInstance decimalNumberForField:textField range:range string:string];
			return FALSE;
	}
	return TRUE;
}


@end
