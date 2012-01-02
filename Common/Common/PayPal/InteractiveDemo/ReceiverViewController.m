
#import "ReceiverViewController.h"
#import "PaymentViewController.h"

typedef enum EditReceiverFields {
	RECEIVERFIELD_RECIPIENT = 274,
	RECEIVERFIELD_SUBTOTAL,
	RECEIVERFIELD_MERCHANT,
	RECEIVERFIELD_DESCRIPTION,
	RECEIVERFIELD_CUSTOMID,
} EditReceiverField;

typedef enum EditReceiverCells {
	RECEIVERCELL_PAYMENTTYPE,
	RECEIVERCELL_PAYMENTSUBTYPE,
	RECEIVERCELL_INVOICEDATA,
	RECEIVERCELL_TOGGLEPRIMARY,
	RECEIVERCELL_COUNT
} EditReceiverCell;


@implementation ReceiverViewController

@synthesize receiver, delegate;

#pragma mark -
#pragma mark Initialization

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if ((self = [super initWithStyle:style])) {
    }
    return self;
}
*/


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

	self.title = @"Edit Receiver";
	
	CGRect appFrame = [UIScreen mainScreen].applicationFrame;
	UIView *header = [[[UIView alloc] initWithFrame:CGRectMake(0., 0., appFrame.size.width, 1000.)] autorelease];
	
	UITextField *field;
	field = [self addTextFieldWithLabel:@"Recipient" tag:RECEIVERFIELD_RECIPIENT toView:header required:TRUE type:UIKeyboardTypeEmailAddress];
	field.text = receiver.recipient;
	field = [self addTextFieldWithLabel:@"Subtotal" tag:RECEIVERFIELD_SUBTOTAL toView:header required:TRUE type:UIKeyboardTypeNumbersAndPunctuation];
	field.text = receiver.subTotal == nil ? nil : [self.formatter stringFromNumber:receiver.subTotal];
	field = [self addTextFieldWithLabel:@"Merchant Name" tag:RECEIVERFIELD_MERCHANT toView:header];
	field.text = receiver.merchantName;
	field = [self addTextFieldWithLabel:@"Description" tag:RECEIVERFIELD_DESCRIPTION toView:header];
	field.text = receiver.description;
	field = [self addTextFieldWithLabel:@"Custom ID" tag:RECEIVERFIELD_CUSTOMID toView:header];
	field.text = receiver.customId;
	
	CGRect frame = header.frame;
	frame.size.height = field.frame.origin.y + field.frame.size.height + 10.;
	header.frame = frame;
	self.tableView.tableHeaderView = header;
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return RECEIVERCELL_COUNT;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
	
	cell.accessoryView = nil;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	cell.detailTextLabel.text = nil;
    
    // Configure the cell...
	switch (indexPath.row) {
		case RECEIVERCELL_PAYMENTTYPE:
			cell.textLabel.text = [NSString stringWithFormat:@"Payment Type: %@", [((PaymentViewController *)delegate).paymentTypeStrings objectAtIndex:receiver.paymentType + 1]];
			break;
		case RECEIVERCELL_PAYMENTSUBTYPE:
			cell.textLabel.text = [NSString stringWithFormat:@"Payment Subtype: %@",
								   receiver.paymentType == TYPE_SERVICE ? [((PaymentViewController *)delegate).paymentSubTypeStrings objectAtIndex:receiver.paymentSubType + 1] : @"Not Used"];
			break;
		case RECEIVERCELL_INVOICEDATA:
			if (receiver.invoiceData != nil) {
				cell.textLabel.text = [NSString stringWithFormat:@"Invoice Data: %d Item%@",
									   receiver.invoiceData.invoiceItems.count,
									   receiver.invoiceData.invoiceItems.count == 1 ? @"" : @"s"];
				NSMutableString *buf = [NSMutableString string];
				if (receiver.invoiceData.totalTax != nil) {
					[buf appendString:@"Tax: "];
					[buf appendString:[self.formatter stringFromNumber:receiver.invoiceData.totalTax]];
				}
				if (receiver.invoiceData.totalShipping != nil) {
					if (buf.length > 0) {
						[buf appendString:@", "];
					}
					[buf appendString:@"Shipping: "];
					[buf appendString:[self.formatter stringFromNumber:receiver.invoiceData.totalShipping]];
				}
				cell.detailTextLabel.text = buf;
			} else {
				cell.textLabel.text = @"Invoice Data: Not Present";
				cell.detailTextLabel.text = nil;
			}
			break;
		case RECEIVERCELL_TOGGLEPRIMARY:
			cell.accessoryType = UITableViewCellAccessoryNone;
			UISwitch *s = [[[UISwitch alloc] init] autorelease];
			[s setOn:receiver.isPrimary animated:FALSE];
			[s addTarget:self action:@selector(togglePrimary:) forControlEvents:UIControlEventValueChanged];
			cell.accessoryView = s;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			cell.textLabel.text = @"Primary:";
			cell.detailTextLabel.text = nil;
			break;
	}
	
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


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
    // Navigation logic may go here. Create and push another view controller.
	if (indexPath.row == RECEIVERCELL_INVOICEDATA) {
		//present view controller to edit invoice data
		InvoiceDataViewController *eidvc = [[[InvoiceDataViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
		if (receiver.invoiceData == nil) {
			receiver.invoiceData = [[[PayPalInvoiceData alloc] init] autorelease];
		}
		eidvc.invoiceData = receiver.invoiceData;
		eidvc.delegate = self;
		[self.navigationController pushViewController:eidvc animated:TRUE];
		return;
	}
	if (indexPath.row == RECEIVERCELL_TOGGLEPRIMARY) {
		return; //this cell just contains a toggle switch
	}
	
	ListChoiceViewController *lcvc = [[[ListChoiceViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
	lcvc.choiceDelegate = self;
	lcvc.groupId = indexPath.row;
	
	switch (indexPath.row) {
		case RECEIVERCELL_PAYMENTTYPE:
			lcvc.title = @"Payment Type";
			lcvc.items = ((PaymentViewController *)delegate).paymentTypeStrings;
			lcvc.selectedIndex = receiver.paymentType + 1;
			break;
		case RECEIVERCELL_PAYMENTSUBTYPE:
			lcvc.title = @"Payment Subtype";
			lcvc.items = ((PaymentViewController *)delegate).paymentSubTypeStrings;
			lcvc.selectedIndex = receiver.paymentSubType + 1;
			break;
	}
	
	[self.navigationController pushViewController:lcvc animated:TRUE];
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
	if ([delegate respondsToSelector:@selector(didFinishEditingReceiver:)]) {
		[delegate didFinishEditingReceiver:receiver];
	}
	self.receiver = nil;
	self.delegate = nil;
    [super dealloc];
}


#pragma mark -
#pragma mark UITextFieldDelegate Methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
	switch(textField.tag){
		case RECEIVERFIELD_SUBTOTAL:
			receiver.subTotal = [self decimalNumberForField:textField range:range string:string];
			return FALSE;
		case RECEIVERFIELD_RECIPIENT:
			receiver.recipient = text;
			break;
		case RECEIVERFIELD_DESCRIPTION:
			receiver.description = text;
			break;
		case RECEIVERFIELD_CUSTOMID:
			receiver.customId = text;
			break;
		case RECEIVERFIELD_MERCHANT:
			receiver.merchantName = text;
			break;
	}
	return TRUE;
}


#pragma mark -
#pragma mark UISwitch Events

- (void)togglePrimary:(id)sender {
	receiver.isPrimary = ((UISwitch *)sender).on;
}


#pragma mark -
#pragma mark EditInvoiceDataDelegate methods

- (void)doneEditingInvoiceData {
	if (receiver.invoiceData.totalTax == nil && receiver.invoiceData.totalShipping == nil && receiver.invoiceData.invoiceItems == nil) {
		receiver.invoiceData = nil;
	}
	[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:RECEIVERCELL_INVOICEDATA inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}


#pragma mark -
#pragma mark ListChoiceDelegate methods

- (void)itemChosenInListChoiceViewController:(ListChoiceViewController *)lcvc {
	NSMutableArray *indexPaths = [NSMutableArray arrayWithObject:[NSIndexPath indexPathForRow:lcvc.groupId inSection:0]];
	
	switch (lcvc.groupId) {
		case RECEIVERCELL_PAYMENTTYPE:
			receiver.paymentType = lcvc.selectedIndex - 1;
			[indexPaths addObject:[NSIndexPath indexPathForRow:RECEIVERCELL_PAYMENTSUBTYPE inSection:0]]; //refresh subtype cell too
			break;
		case RECEIVERCELL_PAYMENTSUBTYPE:
			receiver.paymentSubType = lcvc.selectedIndex - 1;
			break;
	}
	
	[self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
}

@end

