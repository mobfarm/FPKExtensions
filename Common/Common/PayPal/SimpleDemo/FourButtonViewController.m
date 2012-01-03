
#import "FourButtonViewController.h"
#import "PayPalPayment.h"
#import "PayPalAdvancedPayment.h"
#import "PayPalAmounts.h"
#import "PayPalReceiverAmounts.h"
#import "PayPalAddress.h"
#import "PayPalInvoiceItem.h"
#import "SuccessViewController.h"

#define SPACING 3.

@implementation FourButtonViewController

@synthesize preapprovalField;


#pragma mark -
#pragma mark Utility methods

- (void)addLabelWithText:(NSString *)text andButtonWithType:(PayPalButtonType)type withAction:(SEL)action {
	UIFont *font = [UIFont boldSystemFontOfSize:14.];
	CGSize size = [text sizeWithFont:font];
	
	//you should call getPayButton to have the library generate a button for you.
	//this button will be disabled if device interrogation fails for any reason.
	//
	//-- required parameters --
	//target is a class which implements the PayPalPaymentDelegate protocol.
	//action is the selector to call when the button is clicked.
	//inButtonType is the button type (desired size).
	//
	//-- optional parameter --
	//inButtonText can be either BUTTON_TEXT_PAY (default, displays "Pay with PayPal"
	//in the button) or BUTTON_TEXT_DONATE (displays "Donate with PayPal" in the
	//button). the inButtonText parameter also affects some of the library behavior
	//and the wording of some messages to the user.
	UIButton *button = [[PayPal getPayPalInst] getPayButtonWithTarget:self andAction:action andButtonType:type];
	CGRect frame = button.frame;
	frame.origin.x = round((self.view.frame.size.width - button.frame.size.width) / 2.);
	frame.origin.y = round(y + size.height);
	button.frame = frame;
	[self.view addSubview:button];
	
	UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(frame.origin.x, y, size.width, size.height)] autorelease];
	label.font = font;
	label.text = text;
	label.backgroundColor = [UIColor clearColor];
	[self.view addSubview:label];
	
	y += size.height + frame.size.height + SPACING;
}

- (UITextField *)addTextFieldWithPlaceholder:(NSString *)placeholder {
	CGFloat width = 294.;
	CGFloat x = round((self.view.frame.size.width - width) / 2.);
	UITextField *textField = [[[UITextField alloc] initWithFrame:CGRectMake(x, y, width, 30.)] autorelease];
	textField.placeholder = placeholder;
	textField.font = [UIFont systemFontOfSize:14.];
	textField.borderStyle = UITextBorderStyleRoundedRect;
	textField.delegate = self;
	textField.keyboardType = UIKeyboardTypeDefault;
	textField.autocorrectionType = UITextAutocorrectionTypeNo;
	textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	[self.view addSubview:textField];
	
	y += 30. + SPACING;
	
	return textField;
}

- (void)addAppInfoLabel {
	NSString *text = [NSString stringWithFormat:@"Library Version: %@\nDemo App Version: %@",
					  [PayPal buildVersion], [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];
	UIFont *font = [UIFont systemFontOfSize:14.];
	CGSize size = [text sizeWithFont:font constrainedToSize:CGSizeMake(self.view.frame.size.width, MAXFLOAT)];
	UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(round((self.view.frame.size.width - size.width) / 2.), y, size.width, size.height)] autorelease];
	label.font = font;
	label.text = text;
	label.textAlignment = UITextAlignmentCenter;
	label.numberOfLines = 0;
	label.backgroundColor = [UIColor clearColor];
	[self.view addSubview:label];
}


#pragma mark -
#pragma mark View lifecycle methods

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	self.view = [[[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame] autorelease];
	self.view.autoresizesSubviews = FALSE;
	UIColor *color = [UIColor groupTableViewBackgroundColor];
	if (CGColorGetPattern(color.CGColor) == NULL) {
		color = [UIColor lightGrayColor];
	}
	self.view.backgroundColor = color;
	self.title = @"Simple Demo";
	
	status = PAYMENTSTATUS_CANCELED;
	
	y = 2.;
	
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	button.frame = CGRectMake((self.view.frame.size.width - 125), 2, 75, 25);

	[button setTitle:@"Retry Init" forState:UIControlStateNormal];
	[button addTarget:self action:@selector(RetryInitialization) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:button];
    
	[self addLabelWithText:@"Simple Payment" andButtonWithType:BUTTON_294x43 withAction:@selector(simplePayment)];
	[self addLabelWithText:@"Parallel Payment" andButtonWithType:BUTTON_294x43 withAction:@selector(parallelPayment)];
	[self addLabelWithText:@"Chained Payment" andButtonWithType:BUTTON_294x43 withAction:@selector(chainedPayment)];
	[self addLabelWithText:@"Preapproval" andButtonWithType:BUTTON_294x43 withAction:@selector(preapproval)];
	
	self.preapprovalField = [self addTextFieldWithPlaceholder:@"Preapproval Key"];
	
	[self addAppInfoLabel];
}

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
	self.preapprovalField = nil;
    [super dealloc];
}


#pragma mark -
#pragma mark Actions triggered by Pay with PayPal buttons

- (void)simplePayment {
	//dismiss any native keyboards
	[preapprovalField resignFirstResponder];
	
	//optional, set shippingEnabled to TRUE if you want to display shipping
	//options to the user, default: TRUE
	[PayPal getPayPalInst].shippingEnabled = TRUE;
	
	//optional, set dynamicAmountUpdateEnabled to TRUE if you want to compute
	//shipping and tax based on the user's address choice, default: FALSE
	[PayPal getPayPalInst].dynamicAmountUpdateEnabled = TRUE;
	
	//optional, choose who pays the fee, default: FEEPAYER_EACHRECEIVER
	[PayPal getPayPalInst].feePayer = FEEPAYER_EACHRECEIVER;
	
	//for a payment with a single recipient, use a PayPalPayment object
	PayPalPayment *payment = [[[PayPalPayment alloc] init] autorelease];
	payment.recipient = @"example-merchant-1@paypal.com";
	payment.paymentCurrency = @"USD";
	payment.description = @"Teddy Bear";
	payment.merchantName = @"Joe's Bear Emporium";
	
	//subtotal of all items, without tax and shipping
	payment.subTotal = [NSDecimalNumber decimalNumberWithString:@"10"];
	
	//invoiceData is a PayPalInvoiceData object which contains tax, shipping, and a list of PayPalInvoiceItem objects
	payment.invoiceData = [[[PayPalInvoiceData alloc] init] autorelease];
	payment.invoiceData.totalShipping = [NSDecimalNumber decimalNumberWithString:@"2"];
	payment.invoiceData.totalTax = [NSDecimalNumber decimalNumberWithString:@"0.35"];
	
	//invoiceItems is a list of PayPalInvoiceItem objects
	//NOTE: sum of totalPrice for all items must equal payment.subTotal
	//NOTE: example only shows a single item, but you can have more than one
	payment.invoiceData.invoiceItems = [NSMutableArray array];
	PayPalInvoiceItem *item = [[[PayPalInvoiceItem alloc] init] autorelease];
	item.totalPrice = payment.subTotal;
	item.name = @"Teddy";
	[payment.invoiceData.invoiceItems addObject:item];
	
	[[PayPal getPayPalInst] checkoutWithPayment:payment];
}

- (void)parallelPayment {
	//dismiss any native keyboards
	[preapprovalField resignFirstResponder];
	
	//optional, set shippingEnabled to TRUE if you want to display shipping
	//options to the user, default: TRUE
	[PayPal getPayPalInst].shippingEnabled = TRUE;
	
	//optional, set dynamicAmountUpdateEnabled to TRUE if you want to compute
	//shipping and tax based on the user's address choice, default: FALSE
	[PayPal getPayPalInst].dynamicAmountUpdateEnabled = TRUE;
	
	//optional, choose who pays the fee, default: FEEPAYER_EACHRECEIVER
	[PayPal getPayPalInst].feePayer = FEEPAYER_EACHRECEIVER;
	
	//for a payment with multiple recipients, use a PayPalAdvancedPayment object
	PayPalAdvancedPayment *payment = [[[PayPalAdvancedPayment alloc] init] autorelease];
	payment.paymentCurrency = @"USD";
	
    // A payment note applied to all recipients.
    payment.memo = @"A Note applied to all recipients";
    
	//receiverPaymentDetails is a list of PPReceiverPaymentDetails objects
	payment.receiverPaymentDetails = [NSMutableArray array];
	
	//Frank's Robert's Julie's Bear Parts;
	NSArray *nameArray = [NSArray arrayWithObjects:@"Frank's", @"Robert's", @"Julie's",nil];
	
	for (int i = 1; i <= 3; i++) {
		PayPalReceiverPaymentDetails *details = [[[PayPalReceiverPaymentDetails alloc] init] autorelease];
		
        // Customize the payment notes for one of the three recipient.
        if (i == 2) {
            details.description = [NSString stringWithFormat:@"Bear Component %d", i];
        }

        details.recipient = [NSString stringWithFormat:@"example-merchant-%d@paypal.com", 4 - i];
		details.merchantName = [NSString stringWithFormat:@"%@ Bear Parts",[nameArray objectAtIndex:i-1]];

		unsigned long long order, tax, shipping;
		order = i * 100;
		tax = i * 7;
		shipping = i * 14;
		
		//subtotal of all items for this recipient, without tax and shipping
		details.subTotal = [NSDecimalNumber decimalNumberWithMantissa:order exponent:-2 isNegative:FALSE];
		
		//invoiceData is a PayPalInvoiceData object which contains tax, shipping, and a list of PayPalInvoiceItem objects
		details.invoiceData = [[[PayPalInvoiceData alloc] init] autorelease];
		details.invoiceData.totalShipping = [NSDecimalNumber decimalNumberWithMantissa:shipping exponent:-2 isNegative:FALSE];
		details.invoiceData.totalTax = [NSDecimalNumber decimalNumberWithMantissa:tax exponent:-2 isNegative:FALSE];
		
		//invoiceItems is a list of PayPalInvoiceItem objects
		//NOTE: sum of totalPrice for all items must equal details.subTotal
		//NOTE: example only shows a single item, but you can have more than one
		details.invoiceData.invoiceItems = [NSMutableArray array];
		PayPalInvoiceItem *item = [[[PayPalInvoiceItem alloc] init] autorelease];
		item.totalPrice = details.subTotal;
		item.name = @"Bear Stuffing";
		[details.invoiceData.invoiceItems addObject:item];
		
		[payment.receiverPaymentDetails addObject:details];
	}
	
	[[PayPal getPayPalInst] advancedCheckoutWithPayment:payment];
}

- (void)chainedPayment {
	//dismiss any native keyboards
	[preapprovalField resignFirstResponder];
	
	//optional, set shippingEnabled to TRUE if you want to display shipping
	//options to the user, default: TRUE
	[PayPal getPayPalInst].shippingEnabled = TRUE;
	
	//optional, set dynamicAmountUpdateEnabled to TRUE if you want to compute
	//shipping and tax based on the user's address choice, default: FALSE
	[PayPal getPayPalInst].dynamicAmountUpdateEnabled = TRUE;
	
	//optional, choose who pays the fee, default: FEEPAYER_EACHRECEIVER
	[PayPal getPayPalInst].feePayer = FEEPAYER_EACHRECEIVER;
	
	//for a payment with multiple recipients, use a PayPalAdvancedPayment object
	PayPalAdvancedPayment *payment = [[[PayPalAdvancedPayment alloc] init] autorelease];
	payment.paymentCurrency = @"USD";
	
	//receiverPaymentDetails is a list of PPReceiverPaymentDetails objects
	payment.receiverPaymentDetails = [NSMutableArray array];
	
	NSArray *nameArray = [NSArray arrayWithObjects:@"Frank's", @"Robert's", @"Julie's",nil];
	
	for (int i = 1; i <= 3; i++) {
		PayPalReceiverPaymentDetails *details = [[[PayPalReceiverPaymentDetails alloc] init] autorelease];
		
		details.description = @"Bear Components";
		details.recipient = [NSString stringWithFormat:@"example-merchant-%d@paypal.com", 4 - i];
		details.merchantName = [NSString stringWithFormat:@"%@ Bear Parts",[nameArray objectAtIndex:i-1]];
		
		unsigned long long order, tax, shipping;
		order = i * 100;
		tax = i * 7;
		shipping = i * 14;
		
		//subtotal of all items for this recipient, without tax and shipping
		details.subTotal = [NSDecimalNumber decimalNumberWithMantissa:order exponent:-2 isNegative:FALSE];
		
		//invoiceData is a PayPalInvoiceData object which contains tax, shipping, and a list of PayPalInvoiceItem objects
		details.invoiceData = [[[PayPalInvoiceData alloc] init] autorelease];
		details.invoiceData.totalShipping = [NSDecimalNumber decimalNumberWithMantissa:shipping exponent:-2 isNegative:FALSE];
		details.invoiceData.totalTax = [NSDecimalNumber decimalNumberWithMantissa:tax exponent:-2 isNegative:FALSE];
		
		//invoiceItems is a list of PayPalInvoiceItem objects
		//NOTE: sum of totalPrice for all items must equal details.subTotal
		//NOTE: example only shows a single item, but you can have more than one
		details.invoiceData.invoiceItems = [NSMutableArray array];
		PayPalInvoiceItem *item = [[[PayPalInvoiceItem alloc] init] autorelease];
		item.totalPrice = details.subTotal;
		item.name = @"Bear Stuffing";
		[details.invoiceData.invoiceItems addObject:item];
		
		//the only difference between setting up a chained payment and setting
		//up a parallel payment is that the chained payment must have a single
		//primary receiver.  the subTotal + totalTax + totalShipping of the
		//primary receiver must be greater than or equal to the sum of
		//payments being made to all other receivers, because the payment is
		//being made to the primary receiver, then the secondary receivers are
		//paid by the primary receiver.
		if (i == 3) {
			details.isPrimary = TRUE;
		}
		
		[payment.receiverPaymentDetails addObject:details];
	}
	
	[[PayPal getPayPalInst] advancedCheckoutWithPayment:payment];
}

- (void)preapproval {
	//dismiss any native keyboards
	[preapprovalField resignFirstResponder];
	
	//the preapproval flow is kicked off by a single line of code which takes
	//the preapproval key and merchant name as parameters.
	[[PayPal getPayPalInst] preapprovalWithKey:preapprovalField.text andMerchantName:@"Joe's Bear Emporium"];
}


#pragma mark -
#pragma mark PayPalPaymentDelegate methods

-(void)RetryInitialization
{
    [PayPal initializeWithAppID:@"APP-80W284485P519543T" forEnvironment:ENV_SANDBOX];

    //DEVPACKAGE	
    //	[PayPal initializeWithAppID:@"your live app id" forEnvironment:ENV_LIVE];
    //	[PayPal initializeWithAppID:@"anything" forEnvironment:ENV_NONE];
}

//paymentSuccessWithKey:andStatus: is a required method. in it, you should record that the payment
//was successful and perform any desired bookkeeping. you should not do any user interface updates.
//payKey is a string which uniquely identifies the transaction.
//paymentStatus is an enum value which can be STATUS_COMPLETED, STATUS_CREATED, or STATUS_OTHER
- (void)paymentSuccessWithKey:(NSString *)payKey andStatus:(PayPalPaymentStatus)paymentStatus {
    NSString *severity = [[PayPal getPayPalInst].responseMessage objectForKey:@"severity"];
	NSLog(@"severity: %@", severity);
	NSString *category = [[PayPal getPayPalInst].responseMessage objectForKey:@"category"];
	NSLog(@"category: %@", category);
	NSString *errorId = [[PayPal getPayPalInst].responseMessage objectForKey:@"errorId"];
	NSLog(@"errorId: %@", errorId);
	NSString *message = [[PayPal getPayPalInst].responseMessage objectForKey:@"message"];
	NSLog(@"message: %@", message);
    
	status = PAYMENTSTATUS_SUCCESS;
}

//paymentFailedWithCorrelationID is a required method. in it, you should
//record that the payment failed and perform any desired bookkeeping. you should not do any user interface updates.
//correlationID is a string which uniquely identifies the failed transaction, should you need to contact PayPal.
//errorCode is generally (but not always) a numerical code associated with the error.
//errorMessage is a human-readable string describing the error that occurred.
- (void)paymentFailedWithCorrelationID:(NSString *)correlationID {
    
    NSString *severity = [[PayPal getPayPalInst].responseMessage objectForKey:@"severity"];
	NSLog(@"severity: %@", severity);
	NSString *category = [[PayPal getPayPalInst].responseMessage objectForKey:@"category"];
	NSLog(@"category: %@", category);
	NSString *errorId = [[PayPal getPayPalInst].responseMessage objectForKey:@"errorId"];
	NSLog(@"errorId: %@", errorId);
	NSString *message = [[PayPal getPayPalInst].responseMessage objectForKey:@"message"];
	NSLog(@"message: %@", message);
    
	status = PAYMENTSTATUS_FAILED;
}

//paymentCanceled is a required method. in it, you should record that the payment was canceled by
//the user and perform any desired bookkeeping. you should not do any user interface updates.
- (void)paymentCanceled {
	status = PAYMENTSTATUS_CANCELED;
}

//paymentLibraryExit is a required method. this is called when the library is finished with the display
//and is returning control back to your app. you should now do any user interface updates such as
//displaying a success/failure/canceled message.
- (void)paymentLibraryExit {
	UIAlertView *alert = nil;
	switch (status) {
		case PAYMENTSTATUS_SUCCESS:
			[self.navigationController pushViewController:[[[SuccessViewController alloc] init] autorelease] animated:TRUE];
			break;
		case PAYMENTSTATUS_FAILED:
			alert = [[UIAlertView alloc] initWithTitle:@"Order failed" 
											   message:@"Your order failed. Touch \"Pay with PayPal\" to try again." 
											  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			break;
		case PAYMENTSTATUS_CANCELED:
			alert = [[UIAlertView alloc] initWithTitle:@"Order canceled" 
											   message:@"You canceled your order. Touch \"Pay with PayPal\" to try again." 
											  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			break;
	}
	[alert show];
	[alert release];
}

//adjustAmountsForAddress:andCurrency:andAmount:andTax:andShipping:andErrorCode: is optional. you only need to
//provide this method if you wish to recompute tax or shipping when the user changes his/her shipping address.
//for this method to be called, you must enable shipping and dynamic amount calculation on the PayPal object.
//the library will try to use the advanced version first, but will use this one if that one is not implemented.
- (PayPalAmounts *)adjustAmountsForAddress:(PayPalAddress const *)inAddress andCurrency:(NSString const *)inCurrency andAmount:(NSDecimalNumber const *)inAmount
									andTax:(NSDecimalNumber const *)inTax andShipping:(NSDecimalNumber const *)inShipping andErrorCode:(PayPalAmountErrorCode *)outErrorCode {
	//do any logic here that would adjust the amount based on the shipping address
	PayPalAmounts *newAmounts = [[[PayPalAmounts alloc] init] autorelease];
	newAmounts.currency = @"USD";
	newAmounts.payment_amount = (NSDecimalNumber *)inAmount;
	
	//change tax based on the address
	if ([inAddress.state isEqualToString:@"CA"]) {
		newAmounts.tax = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%.2f",[inAmount floatValue] * .1]];
	} else {
		newAmounts.tax = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%.2f",[inAmount floatValue] * .08]];
	}
	newAmounts.shipping = (NSDecimalNumber *)inShipping;
	
	//if you need to notify the library of an error condition, do one of the following
	//*outErrorCode = AMOUNT_ERROR_SERVER;
	//*outErrorCode = AMOUNT_CANCEL_TXN;
	//*outErrorCode = AMOUNT_ERROR_OTHER;
    
	return newAmounts;
}

//adjustAmountsAdvancedForAddress:andCurrency:andReceiverAmounts:andErrorCode: is optional. you only need to
//provide this method if you wish to recompute tax or shipping when the user changes his/her shipping address.
//for this method to be called, you must enable shipping and dynamic amount calculation on the PayPal object.
//the library will try to use this version first, but will use the simple one if this one is not implemented.
- (NSMutableArray *)adjustAmountsAdvancedForAddress:(PayPalAddress const *)inAddress andCurrency:(NSString const *)inCurrency
								 andReceiverAmounts:(NSMutableArray *)receiverAmounts andErrorCode:(PayPalAmountErrorCode *)outErrorCode {
	NSMutableArray *returnArray = [NSMutableArray arrayWithCapacity:[receiverAmounts count]];
	for (PayPalReceiverAmounts *amounts in receiverAmounts) {
		//leave the shipping the same, change the tax based on the state 
		if ([inAddress.state isEqualToString:@"CA"]) {
			amounts.amounts.tax = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%.2f",[amounts.amounts.payment_amount floatValue] * .1]];
		} else {
			amounts.amounts.tax = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%.2f",[amounts.amounts.payment_amount floatValue] * .08]];
		}
		[returnArray addObject:amounts];
	}
	
	//if you need to notify the library of an error condition, do one of the following
	//*outErrorCode = AMOUNT_ERROR_SERVER;
	//*outErrorCode = AMOUNT_CANCEL_TXN;
	//*outErrorCode = AMOUNT_ERROR_OTHER;
	
	return returnArray;
}


#pragma mark -
#pragma mark UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return TRUE;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	resetScrollView = FALSE;
	return TRUE;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	resetScrollView = TRUE;
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:.3];
	[UIView setAnimationBeginsFromCurrentState:TRUE];
	self.view.frame = CGRectMake(0., -216., self.view.frame.size.width, self.view.frame.size.height);
	[UIView commitAnimations];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	if (resetScrollView) {
		resetScrollView = FALSE;
		
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:.3];
		[UIView setAnimationBeginsFromCurrentState:TRUE];
		self.view.frame = CGRectMake(0., 0., self.view.frame.size.width, self.view.frame.size.height);
		[UIView commitAnimations];
	}
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	return TRUE;
}


@end
