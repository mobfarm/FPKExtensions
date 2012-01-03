
#import "PaymentViewController.h"
#import "PaymentSuccessViewController.h"
#import "PayPalPayment.h"
#import "PayPalAdvancedPayment.h"
#import "PayPalAmounts.h"
#import "PayPalReceiverAmounts.h"
#import "PayPalAddress.h"

#define PRIMARY_TEXT @"Primary"
#define SECONDARY_TEXT @"Secondary"
#define BUTTON_TAG 345
#define BUTTON_TAG_OFFSET (BUTTON_TAG + 1)

@interface PrimaryToggleSegmentedControl : UISegmentedControl {
}

@property (nonatomic, assign) BOOL isPrimary;

@end

@implementation PrimaryToggleSegmentedControl

@dynamic isPrimary;

- (id)initIsPrimary:(BOOL)primary {
	if ((self = [super initWithItems:[NSArray arrayWithObject:primary ? PRIMARY_TEXT : SECONDARY_TEXT]])) {
		self.segmentedControlStyle = UISegmentedControlStyleBar;
		[self setWidth:80. forSegmentAtIndex:0];
		if (primary) {
			super.selectedSegmentIndex = 0;
		}
	}
	return self;
}

- (void)setSelectedSegmentIndex:(NSInteger)toValue {
	if (self.selectedSegmentIndex == toValue) {
		[super setSelectedSegmentIndex:UISegmentedControlNoSegment];
	} else {
		[super setSelectedSegmentIndex:toValue];     
	}
	[self setTitle:self.selectedSegmentIndex == 0 ? PRIMARY_TEXT : SECONDARY_TEXT forSegmentAtIndex:0];
}

- (BOOL)isPrimary {
	return self.selectedSegmentIndex == 0;
}

- (void)setIsPrimary:(BOOL)primary {
	[self setSelectedSegmentIndex:primary ? 0 : UISegmentedControlNoSegment];
}

@end

typedef enum PaymentFieldTags {
	TAG_PREAPPROVAL = 989,
	TAG_MERCHANTNAME,
	TAG_RECIPIENT,
	TAG_SUBTOTAL,
	TAG_DESCRIPTION,
	TAG_CUSTOMID,
	TAG_MEMO,
	TAG_IPNURL,
} PaymentFieldTag;

typedef enum PaymentRowIds {
	ID_CURRENCY,
	ID_FEEPAYER,
	ID_TYPE,
	ID_SUBTYPE,
} PaymentRowId;

typedef enum PaymentSections {
	SECTION_TOGGLES,
	SECTION_CHOICES,
	SECTION_OTHER,
	SECTION_COUNT,
} PaymentSection;

typedef enum ToggleCells {
	CELL_SHIPPING,
	CELL_DYNAMICAMOUNT,
	CELL_TOGGLECOUNT,
} ToggleCell;

typedef enum ChoiceCells {
	CELL_CURRENCY,
	CELL_FEEPAYER,
	CELL_CHOICECOUNT,
} ChoiceCell;

typedef enum SimpleCells {
	CELL_TYPE,
	CELL_SUBTYPE,
	CELL_INVOICEDATA,
	CELL_SIMPLECOUNT,
} SimpleCell;

#define CELL_ADVANCEDCOUNT (advancedPayment.receiverPaymentDetails.count + 1)

@implementation PaymentViewController
@synthesize payment, advancedPayment, shippingSwitch, dynamicAmountCalculationSwitch;
@synthesize feePayerStrings, paymentTypeStrings, paymentSubTypeStrings;
@synthesize buttonType, buttonText, isAdvanced, feePayer;


#pragma mark -
#pragma mark Utility methods

PaymentRowId rowIdForIndexPath(NSIndexPath *path) {
	switch (path.section) {
		case SECTION_CHOICES:
			switch (path.row) {
				case CELL_CURRENCY:
					return ID_CURRENCY;
				case CELL_FEEPAYER:
					return ID_FEEPAYER;
			}
			break;
		case SECTION_OTHER:
			switch (path.row) {
				case CELL_TYPE:
					return ID_TYPE;
				case CELL_SUBTYPE:
					return ID_SUBTYPE;
			}
			break;
	}
	return -1;
}

NSIndexPath *indexPathForRowId(PaymentRowId rowId) {
	switch (rowId) {
		case ID_CURRENCY:
			return [NSIndexPath indexPathForRow:CELL_CURRENCY inSection:SECTION_CHOICES];
		case ID_FEEPAYER:
			return [NSIndexPath indexPathForRow:CELL_FEEPAYER inSection:SECTION_CHOICES];
		case ID_TYPE:
			return [NSIndexPath indexPathForRow:CELL_TYPE inSection:SECTION_OTHER];
		case ID_SUBTYPE:
			return [NSIndexPath indexPathForRow:CELL_SUBTYPE inSection:SECTION_OTHER];
	}
	return nil;
}

- (void)guaranteeSinglePrimary:(NSUInteger)index { //only allow one primary receiver
	for (int i = 0; i < advancedPayment.receiverPaymentDetails.count; i++) {
		PayPalReceiverPaymentDetails *rec = [advancedPayment.receiverPaymentDetails objectAtIndex:i];
		if (rec.isPrimary && i != index) {
			rec.isPrimary = ((PrimaryToggleSegmentedControl *)[[self.tableView viewWithTag:BUTTON_TAG_OFFSET + i] viewWithTag:BUTTON_TAG]).isPrimary = FALSE;
		}
	}
}

- (void)togglePrimary:(id)sender {
	PrimaryToggleSegmentedControl *button = (PrimaryToggleSegmentedControl *)sender;
	NSUInteger index = button.superview.tag - BUTTON_TAG_OFFSET;
	PayPalReceiverPaymentDetails *receiver = (PayPalReceiverPaymentDetails *)[advancedPayment.receiverPaymentDetails objectAtIndex:index];
	receiver.isPrimary = button.isPrimary;
	
	if (receiver.isPrimary) {
		[self guaranteeSinglePrimary:index];
	}
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.feePayer = FEEPAYER_EACHRECEIVER;
	
	paymentStatus = PAYMENTSTATUS_CANCELED;
	if (isAdvanced) {
		self.title = @"Advanced Payment";
		self.navigationItem.rightBarButtonItem = self.editButtonItem;
	} else {
		self.title = @"Simple Payment";
	}
	
	self.payment = [[[PayPalPayment alloc] init] autorelease];
	self.advancedPayment = [[[PayPalAdvancedPayment alloc] init] autorelease];
	payment.paymentCurrency = advancedPayment.paymentCurrency = DEFAULT_CURRENCY;
	[self setCurrencyCode:DEFAULT_CURRENCY];
	
	CGRect appFrame = [UIScreen mainScreen].applicationFrame;
	UIView *header = [[[UIView alloc] initWithFrame:CGRectMake(0., 0., appFrame.size.width, 1000.)] autorelease];
	
	UITextField *field = nil;
	
	if (!isAdvanced) {
		field = [self addTextFieldWithLabel:@"Recipient" tag:TAG_RECIPIENT toView:header required:TRUE type:UIKeyboardTypeEmailAddress];
		field.text = payment.recipient;
		field = [self addTextFieldWithLabel:@"Subtotal" tag:TAG_SUBTOTAL toView:header required:TRUE type:UIKeyboardTypeNumbersAndPunctuation];
		field.text = payment.subTotal == nil ? nil : [self.formatter stringFromNumber:payment.subTotal];
	}
	
	field = [self addTextFieldWithLabel:@"Merchant Name" tag:TAG_MERCHANTNAME toView:header];
	field.text = isAdvanced ? advancedPayment.merchantName : payment.merchantName;
	
	if (!isAdvanced) {
		field = [self addTextFieldWithLabel:@"Description" tag:TAG_DESCRIPTION toView:header];
		field.text = payment.description;
		field = [self addTextFieldWithLabel:@"Custom ID" tag:TAG_CUSTOMID toView:header];
		field.text = payment.customId;
	}
	
	field = [self addTextFieldWithLabel:@"Memo" tag:TAG_MEMO toView:header];
	field.text = isAdvanced ? advancedPayment.memo : payment.memo;
	field = [self addTextFieldWithLabel:@"IPN URL" tag:TAG_IPNURL toView:header];
	field.text = isAdvanced ? advancedPayment.ipnUrl : payment.ipnUrl;
	
	CGRect frame = header.frame;
	frame.size.height = field.frame.origin.y + field.frame.size.height + 10.;
	header.frame = frame;
	self.tableView.tableHeaderView = header;
	
	UIButton *button = [[PayPal getPayPalInst] getPayButtonWithTarget:self andAction:@selector(payButtonClicked) andButtonType:buttonType andButtonText:buttonText];
	frame = button.frame;
	frame.origin.x = round((appFrame.size.width - frame.size.width) / 2.);
	frame.origin.y = 10.;
	button.frame = frame;
	
	UILabel *label = self.appInfo;
	frame = label.frame;
	frame.origin.y = button.frame.origin.y + button.frame.size.height + 10.;
	label.frame = frame;
	
	UIView *footer = [[[UIView alloc] initWithFrame:CGRectMake(0., 0., appFrame.size.width, label.frame.origin.y + label.frame.size.height + 10.)] autorelease];
	[footer addSubview:label];
	[footer addSubview:button];
	
	self.tableView.tableFooterView = footer;
	
	//this must match the PayPalFeePayer enum
	self.feePayerStrings = [NSArray arrayWithObjects:@"Sender", @"Primary Receiver", @"Each Receiver", @"Secondary Only", nil];
	
	//this must match the PayPalPaymentType enum (Not Set = -1)
	self.paymentTypeStrings = [NSArray arrayWithObjects:@"Not Set", @"Goods", @"Service", @"Personal", nil];
	
	//this must match the PayPalPaymentSubType enum (Not Set = -1)
	self.paymentSubTypeStrings = [NSArray arrayWithObjects:@"Not Set", @"Affiliate Payments", @"B2B", @"Payroll", @"Rebates", @"Refunds",
								  @"Reimbursements", @"Donations", @"Utilities", @"Tuition", @"Government", @"Insurance", @"Remittances",
								  @"Rent", @"Mortgage", @"Medical", @"Child Care", @"Event Planning", @"General Contractors",
								  @"Entertainment", @"Tourism", @"Invoice", @"Transfer", nil];
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return SECTION_COUNT;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	switch (section) {
		case SECTION_TOGGLES:
			return CELL_TOGGLECOUNT;
		case SECTION_CHOICES:
			return CELL_CHOICECOUNT;
		default:
			return isAdvanced ? CELL_ADVANCEDCOUNT : CELL_SIMPLECOUNT;
	}
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
	cell.detailTextLabel.text = nil; //clear detail text, not all cells have one
	cell.tag = 0; //reset cell tag - only used by advanced payment receiver cells
	switch (indexPath.section) {
		case SECTION_TOGGLES:
			cell.accessoryType = UITableViewCellAccessoryNone;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			switch (indexPath.row) {
				case CELL_SHIPPING:
					cell.textLabel.text = @"Shipping:";
					if (shippingSwitch == nil) {
						self.shippingSwitch = [[[UISwitch alloc] initWithFrame:CGRectZero] autorelease];
						shippingSwitch.on = [PayPal getPayPalInst].shippingEnabled;
					}
					cell.accessoryView = shippingSwitch;
					break;
				case CELL_DYNAMICAMOUNT:
					cell.textLabel.text = @"Dynamic Amt. Calc.:";
					if (dynamicAmountCalculationSwitch == nil) {
						self.dynamicAmountCalculationSwitch = [[[UISwitch alloc] initWithFrame:CGRectZero] autorelease];
						dynamicAmountCalculationSwitch.on = [PayPal getPayPalInst].dynamicAmountUpdateEnabled;
					}
					cell.accessoryView = dynamicAmountCalculationSwitch;
					break;
			}
			break;
		case SECTION_CHOICES:
			cell.accessoryView = nil;
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.selectionStyle = UITableViewCellSelectionStyleBlue;
			switch (indexPath.row) {
				case CELL_CURRENCY: {
					NSString *currency = isAdvanced ? advancedPayment.paymentCurrency : payment.paymentCurrency;
					cell.textLabel.text = [NSString stringWithFormat:@"Currency: %@", [self currencyInfoForCurrency:currency fromString:kCurrencyNames]];
				} break;
				case CELL_FEEPAYER:
					cell.textLabel.text = [NSString stringWithFormat:@"Fee Payer: %@", [feePayerStrings objectAtIndex:feePayer]];
					break;
			}
			break;
		case SECTION_OTHER:
			cell.accessoryView = nil;
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.selectionStyle = UITableViewCellSelectionStyleBlue;
			if (isAdvanced) {
				if (indexPath.row < advancedPayment.receiverPaymentDetails.count) {
					PayPalReceiverPaymentDetails *details = (PayPalReceiverPaymentDetails *)[advancedPayment.receiverPaymentDetails objectAtIndex:indexPath.row];
					
					if (details.merchantName.length > 0) {
						cell.textLabel.text = details.merchantName;
					} else if (details.recipient.length > 0) {
						cell.textLabel.text = details.recipient;
					} else {
						cell.textLabel.text = [NSString stringWithFormat:@"Receiver %d", indexPath.row + 1];
					}
					cell.detailTextLabel.text = details.subTotal == nil ? nil : [NSString stringWithFormat:@"Subtotal: %@", [self.formatter stringFromNumber:details.subTotal]];
					
					PrimaryToggleSegmentedControl *control = [[[PrimaryToggleSegmentedControl alloc] initIsPrimary:details.isPrimary] autorelease];
					control.tag = BUTTON_TAG;
					[control addTarget:self action:@selector(togglePrimary:) forControlEvents:UIControlEventValueChanged];
					cell.accessoryView = control;
					cell.tag = indexPath.row + BUTTON_TAG_OFFSET; //set tag on cell because accessory view vanishes in editing mode
				} else {
					cell.textLabel.text = @"Add Receiver";
					cell.detailTextLabel.text = nil;
					cell.accessoryView = nil;
					cell.accessoryType = UITableViewCellAccessoryNone;
				}
			} else {
				switch (indexPath.row) {
					case CELL_TYPE:
						cell.textLabel.text = [NSString stringWithFormat:@"Payment Type: %@", [paymentTypeStrings objectAtIndex:payment.paymentType + 1]];
						break;
					case CELL_SUBTYPE:
						cell.textLabel.text = [NSString stringWithFormat:@"Payment Subtype: %@",
											   payment.paymentType == TYPE_SERVICE ? [paymentSubTypeStrings objectAtIndex:payment.paymentSubType + 1] : @"Not Used"];
						break;
					case CELL_INVOICEDATA:
						if (payment.invoiceData != nil) {
							cell.textLabel.text = [NSString stringWithFormat:@"Invoice Data: %d Item%@",
												   payment.invoiceData.invoiceItems.count,
												   payment.invoiceData.invoiceItems.count == 1 ? @"" : @"s"];
							NSMutableString *buf = [NSMutableString string];
							if (payment.invoiceData.totalTax != nil) {
								[buf appendString:@"Tax: "];
								[buf appendString:[self.formatter stringFromNumber:payment.invoiceData.totalTax]];
							}
							if (payment.invoiceData.totalShipping != nil) {
								if (buf.length > 0) {
									[buf appendString:@", "];
								}
								[buf appendString:@"Shipping: "];
								[buf appendString:[self.formatter stringFromNumber:payment.invoiceData.totalShipping]];
							}
							cell.detailTextLabel.text = buf;
						} else {
							cell.textLabel.text = @"Invoice Data: Not Present";
							cell.detailTextLabel.text = nil;
						}
						break;
				}
			}
			break;
	}

    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return isAdvanced && indexPath.section == SECTION_OTHER;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	return indexPath.row == advancedPayment.receiverPaymentDetails.count ? UITableViewCellEditingStyleInsert : UITableViewCellEditingStyleDelete;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		// Subtract 1 from the tag of each primary toggle button after the row being removed.
		for (int i = indexPath.row + 1; i < advancedPayment.receiverPaymentDetails.count; i++) {
			[tableView viewWithTag:BUTTON_TAG_OFFSET + i].tag--;
		}
		
        // Delete the row from the data source
		[advancedPayment.receiverPaymentDetails removeObjectAtIndex:indexPath.row];
		if (advancedPayment.receiverPaymentDetails.count == 0) {
			advancedPayment.receiverPaymentDetails = nil;
		}
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
		if (advancedPayment.receiverPaymentDetails == nil) {
			advancedPayment.receiverPaymentDetails = [NSMutableArray array];
		}
		[advancedPayment.receiverPaymentDetails addObject:[[[PayPalReceiverPaymentDetails alloc] init] autorelease]];
		[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	switch (indexPath.section) {
		case SECTION_TOGGLES:
			break; //do nothing for toggles
		case SECTION_OTHER:
			if (isAdvanced) {
				if (indexPath.row < advancedPayment.receiverPaymentDetails.count) {
					ReceiverViewController *ervc = [[[ReceiverViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
					ervc.receiver = (PayPalReceiverPaymentDetails *)[advancedPayment.receiverPaymentDetails objectAtIndex:indexPath.row];
					ervc.delegate = self;
					[self.navigationController pushViewController:ervc animated:TRUE];
				} else {
					[tableView deselectRowAtIndexPath:indexPath animated:TRUE];
					if (advancedPayment.receiverPaymentDetails == nil) {
						advancedPayment.receiverPaymentDetails = [NSMutableArray array];
					}
					[advancedPayment.receiverPaymentDetails addObject:[[[PayPalReceiverPaymentDetails alloc] init] autorelease]];
					[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
				}
				break; //we're done
			}
			if (indexPath.row == CELL_INVOICEDATA) {
				//present view controller to edit invoice data
				InvoiceDataViewController *eidvc = [[[InvoiceDataViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
				if (payment.invoiceData == nil) {
					payment.invoiceData = [[[PayPalInvoiceData alloc] init] autorelease];
				}
				eidvc.invoiceData = payment.invoiceData;
				eidvc.delegate = self;
				[self.navigationController pushViewController:eidvc animated:TRUE];
				break; //we're done
			}
			//no break here, fall through
		case SECTION_CHOICES: {
			ListChoiceViewController *lcvc = [[[ListChoiceViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
			lcvc.choiceDelegate = self;
			lcvc.groupId = rowIdForIndexPath(indexPath);
			
			switch (lcvc.groupId) {
				case ID_CURRENCY: {
					NSString *currency = isAdvanced ? advancedPayment.paymentCurrency : payment.paymentCurrency;
					lcvc.title = @"Currency";
					lcvc.items = self.currencyStrings;
					lcvc.selectedIndex = [self.currencyStrings indexOfObject:[self currencyInfoForCurrency:currency fromString:kCurrencyNames]];
				} break;
				case ID_FEEPAYER:
					lcvc.title = @"Fee Payer";
					lcvc.items = feePayerStrings;
					lcvc.selectedIndex = feePayer;
					break;
				case ID_TYPE:
					lcvc.title = @"Payment Type";
					lcvc.items = paymentTypeStrings;
					lcvc.selectedIndex = payment.paymentType + 1;
					break;
				case ID_SUBTYPE:
					lcvc.title = @"Payment Subtype";
					lcvc.items = paymentSubTypeStrings;
					lcvc.selectedIndex = payment.paymentSubType + 1;
					break;
			}
			
			[self.navigationController pushViewController:lcvc animated:TRUE];
		} break;
	}
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
	self.payment = nil;
	self.advancedPayment = nil;
	self.shippingSwitch = nil;
	self.dynamicAmountCalculationSwitch = nil;
	self.feePayerStrings = nil;
	self.paymentTypeStrings = nil;
	self.paymentSubTypeStrings = nil;
    [super dealloc];
}


#pragma mark -
#pragma mark Pay Button event

- (void)payButtonClicked {
	//dismiss any keyboards
	for (UIView *v in self.tableView.tableHeaderView.subviews) {
		if ([v isKindOfClass:[UITextField class]] && [(UITextField *)v isFirstResponder]) {
			[(UITextField *)v resignFirstResponder];
		}
	}
	
	//Set the PayPal payment properties to whatever was chosen
	[PayPal getPayPalInst].feePayer = feePayer;
	[PayPal getPayPalInst].shippingEnabled = shippingSwitch.on;
	[PayPal getPayPalInst].dynamicAmountUpdateEnabled = dynamicAmountCalculationSwitch.on;
	if (isAdvanced) {
		[[PayPal getPayPalInst] advancedCheckoutWithPayment:advancedPayment];
	} else {
		[[PayPal getPayPalInst] checkoutWithPayment:payment];
	}
}


#pragma mark -
#pragma mark PayPalPaymentDelegate methods

-(void)paymentSuccessWithKey:(NSString *)payKey andStatus:(PayPalPaymentStatus)status; {
	paymentStatus = PAYMENTSTATUS_SUCCESS;
}

-(void)paymentFailedWithCorrelationID:(NSString *)correlationID {
	paymentStatus = PAYMENTSTATUS_FAILED;
}

-(void)paymentCanceled {
	paymentStatus = PAYMENTSTATUS_CANCELED;
}

-(void)paymentLibraryExit {
	UIAlertView *alert = nil;
	switch (paymentStatus) {
		case PAYMENTSTATUS_SUCCESS:
			[self.navigationController pushViewController:[[[PaymentSuccessViewController alloc] init] autorelease] animated:TRUE];
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
	//*outErrorCode = AMOUNT_ERROR_OTHER;
	
	return newAmounts;
}

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
	//*outErrorCode = AMOUNT_ERROR_OTHER;
	
	return returnArray;
}


#pragma mark -
#pragma mark ListChoiceDelegate methods

- (void)itemChosenInListChoiceViewController:(ListChoiceViewController *)lcvc {
	NSMutableArray *indexPaths = [NSMutableArray arrayWithObject:indexPathForRowId(lcvc.groupId)];
	
	switch (lcvc.groupId) {
		case ID_CURRENCY: {
			short power = (short)[self.formatter maximumFractionDigits];
			NSString *currency = [[kCurrencyCodes componentsSeparatedByString:@"|"] objectAtIndex:
								  [[kCurrencyNames componentsSeparatedByString:@"|"] indexOfObject:
								   [self.currencyStrings objectAtIndex:lcvc.selectedIndex]]];
			[self setCurrencyCode:currency];
			power -= (short)[self.formatter maximumFractionDigits];
			
			if (isAdvanced) {
				advancedPayment.paymentCurrency = currency;
				
				//account for currencies with no decimal places: $1.25 becomes JPY125, and vice versa
				if (power != 0) {
					for (PayPalReceiverPaymentDetails *receiver in advancedPayment.receiverPaymentDetails) {
						if (receiver.subTotal != nil) {
							receiver.subTotal = [receiver.subTotal decimalNumberByMultiplyingByPowerOf10:power];
						}
						if (receiver.invoiceData != nil) {
							if (receiver.invoiceData.totalTax != nil) {
								receiver.invoiceData.totalTax = [receiver.invoiceData.totalTax decimalNumberByMultiplyingByPowerOf10:power];
							}
							if (receiver.invoiceData.totalShipping != nil) {
								receiver.invoiceData.totalShipping = [receiver.invoiceData.totalShipping decimalNumberByMultiplyingByPowerOf10:power];
							}
						}
					}
				}
				
				//refresh receiver cells
				for (int i = 0; i < advancedPayment.receiverPaymentDetails.count; i++) {
					[indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:SECTION_OTHER]];
				}
			} else {
				payment.paymentCurrency = currency;
				
				//refresh subtotal field
				payment.subTotal = [self decimalNumberForField:(UITextField *)[self.tableView.tableHeaderView viewWithTag:TAG_SUBTOTAL] range:NSMakeRange(0, 0) string:@""];
				
				if (payment.invoiceData != nil) {
					//account for currencies with no decimal places: $1.25 becomes JPY125, and vice versa
					if (power != 0) {
						if (payment.invoiceData.totalTax != nil) {
							payment.invoiceData.totalTax = [payment.invoiceData.totalTax decimalNumberByMultiplyingByPowerOf10:power];
						}
						if (payment.invoiceData.totalShipping != nil) {
							payment.invoiceData.totalShipping = [payment.invoiceData.totalShipping decimalNumberByMultiplyingByPowerOf10:power];
						}
					}
					
					//refresh invoice data cell
					[indexPaths addObject:[NSIndexPath indexPathForRow:CELL_INVOICEDATA inSection:SECTION_OTHER]];
				}
			}
		} break;
		case ID_FEEPAYER:
			self.feePayer = lcvc.selectedIndex;
			break;
		case ID_TYPE:
			payment.paymentType = lcvc.selectedIndex - 1;
			//refresh subtype cell too
			[indexPaths addObject:indexPathForRowId(ID_SUBTYPE)];
			break;
		case ID_SUBTYPE:
			payment.paymentSubType = lcvc.selectedIndex - 1;
			break;
	}
	
	[self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
}


#pragma mark -
#pragma mark ReceiverDelegate methods

- (void)didFinishEditingReceiver:(PayPalReceiverPaymentDetails*)theReceiver {
	NSUInteger row = [advancedPayment.receiverPaymentDetails indexOfObject:theReceiver];
	if (row != NSNotFound) {
		[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:row inSection:SECTION_OTHER]] withRowAnimation:UITableViewRowAnimationNone];
		if (theReceiver.isPrimary) {
			[self guaranteeSinglePrimary:row];
		}
	}
}


#pragma mark -
#pragma mark EditInvoiceDataDelegate methods

- (void)doneEditingInvoiceData {
	if (payment.invoiceData.totalTax == nil && payment.invoiceData.totalShipping == nil && payment.invoiceData.invoiceItems == nil) {
		payment.invoiceData = nil;
	}
	[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:CELL_INVOICEDATA inSection:SECTION_OTHER]] withRowAnimation:UITableViewRowAnimationNone];
}


#pragma mark -
#pragma mark UITextFieldDelegate methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
	switch(textField.tag){
		case TAG_SUBTOTAL:
			payment.subTotal = [self decimalNumberForField:textField range:range string:string];
			return FALSE; //we already edited the text field, so return FALSE
		case TAG_RECIPIENT:
			payment.recipient = text;
			break;
		case TAG_DESCRIPTION:
			payment.description = text;
			break;
		case TAG_CUSTOMID:
			payment.customId = text;
			break;
		case TAG_MERCHANTNAME:
			if (isAdvanced) {
				advancedPayment.merchantName = text;
			} else {
				payment.merchantName = text;
			}
			break;
		case TAG_MEMO:
			if (isAdvanced) {
				advancedPayment.memo = text;
			} else {
				payment.memo = text;
			}
			break;
		case TAG_IPNURL:
			if (isAdvanced) {
				advancedPayment.ipnUrl = text;
			} else {
				payment.ipnUrl = text;
			}
			break;
	}
	return TRUE;
}


@end

