
#import "InvoiceDataViewController.h"
#import "PayPalInvoiceItem.h"


typedef enum EditInvoiceFields {
	INVOICEFIELD_TAX = 164,
	INVOICEFIELD_SHIPPING,
} EditInvoiceField;

@implementation InvoiceDataViewController

@synthesize invoiceData, delegate;

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

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	self.title = @"Edit Invoice";
	
	CGRect appFrame = [UIScreen mainScreen].applicationFrame;
	UIView *header = [[[UIView alloc] initWithFrame:CGRectMake(0., 0., appFrame.size.width, 1000.)] autorelease];
	
	UITextField *field;
	field = [self addTextFieldWithLabel:@"Total Tax" tag:INVOICEFIELD_TAX toView:header required:FALSE type:UIKeyboardTypeNumbersAndPunctuation];
	field.text = invoiceData.totalTax == nil ? nil : [self.formatter stringFromNumber:invoiceData.totalTax];
	field = [self addTextFieldWithLabel:@"Total Shipping" tag:INVOICEFIELD_SHIPPING toView:header required:FALSE type:UIKeyboardTypeNumbersAndPunctuation];
	field.text = invoiceData.totalShipping == nil ? nil : [self.formatter stringFromNumber:invoiceData.totalShipping];
	
	CGRect frame = header.frame;
	frame.size.height = field.frame.origin.y + field.frame.size.height + 10.;
	header.frame = frame;
	self.tableView.tableHeaderView = header;
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
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return invoiceData.invoiceItems.count + 1;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
	if (indexPath.row < invoiceData.invoiceItems.count) {
		PayPalInvoiceItem *item = (PayPalInvoiceItem *)[invoiceData.invoiceItems objectAtIndex:indexPath.row];
		
		NSMutableString *buf = [NSMutableString string];
		if (item.name.length > 0) {
			[buf appendString:item.name];
		} else {
			[buf appendFormat:@"Item %d", indexPath.row + 1];
		}
		if (item.itemId.length > 0) {
			[buf appendFormat:@" (%@)", item.itemId];
		}
		cell.textLabel.text = buf;
		
		buf = [NSMutableString string];
		if (item.itemCount != nil) {
			[buf appendFormat:@"%@ @ ", item.itemCount];
		}
		if (item.itemPrice != nil) {
			[buf appendString:[self.formatter stringFromNumber:item.itemPrice]];
		}
		if (item.totalPrice != nil) {
			if (buf.length > 0) {
				[buf appendString:@" = "];
			}
			[buf appendString:[self.formatter stringFromNumber:item.totalPrice]];
		}
		cell.detailTextLabel.text = buf;
		
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	} else {
		cell.textLabel.text = @"Add Item";
		cell.detailTextLabel.text = nil;
		cell.accessoryView = UITableViewCellAccessoryNone;
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

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	return indexPath.row == invoiceData.invoiceItems.count ? UITableViewCellEditingStyleInsert : UITableViewCellEditingStyleDelete;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
		[invoiceData.invoiceItems removeObjectAtIndex:indexPath.row];
		if (invoiceData.invoiceItems.count == 0) {
			invoiceData.invoiceItems = nil;
		}
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
		if (invoiceData.invoiceItems == nil) {
			invoiceData.invoiceItems = [NSMutableArray array];
		}
		[invoiceData.invoiceItems addObject:[[[PayPalInvoiceItem alloc] init] autorelease]];
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
    // Navigation logic may go here. Create and push another view controller.
	if (indexPath.row < invoiceData.invoiceItems.count) {
		InvoiceItemViewController *eiivc = [[[InvoiceItemViewController alloc] init] autorelease];
		eiivc.invoiceItem = (PayPalInvoiceItem *)[invoiceData.invoiceItems objectAtIndex:indexPath.row];
		eiivc.delegate = self;
		[self.navigationController pushViewController:eiivc animated:TRUE];
	} else {
		[tableView deselectRowAtIndexPath:indexPath animated:TRUE];
		if (invoiceData.invoiceItems == nil) {
			invoiceData.invoiceItems = [NSMutableArray array];
		}
		[invoiceData.invoiceItems addObject:[[[PayPalInvoiceItem alloc] init] autorelease]];
		[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
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
	[delegate doneEditingInvoiceData];
	self.invoiceData = nil;
	self.delegate = nil;
    [super dealloc];
}


#pragma mark -
#pragma mark UITextFieldDelegate Methods

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	switch(textField.tag){
		case INVOICEFIELD_TAX:
			invoiceData.totalTax = [self decimalNumberForField:textField range:range string:string];
			break;
		case INVOICEFIELD_SHIPPING:
			invoiceData.totalShipping = [self decimalNumberForField:textField range:range string:string];
			break;
	}
	return FALSE;
}


#pragma mark -
#pragma mark EditInvoiceItemDelegate Methods

- (void)doneEditingInvoiceItem:(PayPalInvoiceItem *)item {
	NSUInteger index = [invoiceData.invoiceItems indexOfObject:item];
	if (index != NSNotFound) {
		[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
	}
}

@end

