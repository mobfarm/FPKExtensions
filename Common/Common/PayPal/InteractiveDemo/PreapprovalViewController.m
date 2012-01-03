
#import "PreapprovalViewController.h"
#import "PaymentSuccessViewController.h"

typedef enum PreapprovalFieldTags {
	TAG_PREAPPROVAL = 989,
	TAG_MERCHANTNAME,
} PreapprovalFieldTag;

@implementation PreapprovalViewController
@synthesize buttonType, buttonText;
@dynamic preapprovalKey, merchantName;


#pragma mark -
#pragma mark Custom accessors

- (NSString *)preapprovalKey {
	return ((UITextField *)[self.tableView.tableHeaderView viewWithTag:TAG_PREAPPROVAL]).text;
}

- (void)setPreapprovalKey:(NSString *)key {
	((UITextField *)[self.tableView.tableHeaderView viewWithTag:TAG_PREAPPROVAL]).text = key;
}

- (NSString *)merchantName {
	return ((UITextField *)[self.tableView.tableHeaderView viewWithTag:TAG_MERCHANTNAME]).text;
}

- (void)setMerchantName:(NSString *)name {
	((UITextField *)[self.tableView.tableHeaderView viewWithTag:TAG_MERCHANTNAME]).text = name;
}


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
	preapprovalStatus = PREAPPROVALSTATUS_CANCELED;
	self.title = @"Preapproval";
	
	CGRect appFrame = [UIScreen mainScreen].applicationFrame;
	UIView *header = [[[UIView alloc] initWithFrame:CGRectMake(0., 0., appFrame.size.width, 1000.)] autorelease];
	
	UITextField *field = nil;
	field = [self addTextFieldWithLabel:@"Merchant Name" tag:TAG_MERCHANTNAME toView:header required:TRUE];
	field = [self addTextFieldWithLabel:@"Preapproval Key" tag:TAG_PREAPPROVAL toView:header required:TRUE];
	
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
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
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
	
	[[PayPal getPayPalInst] preapprovalWithKey:self.preapprovalKey andMerchantName:self.merchantName];
}


#pragma mark -
#pragma mark PayPalPaymentDelegate methods

-(void)paymentSuccessWithKey:(NSString *)payKey andStatus:(PayPalPaymentStatus)status; {
	preapprovalStatus = PREAPPROVALSTATUS_SUCCESS;
}

-(void)paymentFailedWithCorrelationID:(NSString *)correlationID {
	preapprovalStatus = PREAPPROVALSTATUS_FAILED;
}

-(void)paymentCanceled {
	preapprovalStatus = PREAPPROVALSTATUS_CANCELED;
}

-(void)paymentLibraryExit {
	UIAlertView *alert = nil;
	switch (preapprovalStatus) {
		case PREAPPROVALSTATUS_SUCCESS:
			[self.navigationController pushViewController:[[[PaymentSuccessViewController alloc] init] autorelease] animated:TRUE];
			break;
		case PREAPPROVALSTATUS_FAILED:
			alert = [[UIAlertView alloc] initWithTitle:@"Preapproval failed" 
											   message:@"Your preapproval failed. Touch \"Pay with PayPal\" to try again." 
											  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			break;
		case PREAPPROVALSTATUS_CANCELED:
			alert = [[UIAlertView alloc] initWithTitle:@"Preapproval canceled" 
											   message:@"You canceled preapproval. Touch \"Pay with PayPal\" to try again." 
											  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			break;
	}
	[alert show];
	[alert release];
}


@end

