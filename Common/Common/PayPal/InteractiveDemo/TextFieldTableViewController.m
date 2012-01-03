
#import "TextFieldTableViewController.h"
#import "PayPal.h"


static NSNumberFormatter *formatter = nil;
static NSArray *currencyStrings = nil;

@implementation TextFieldTableViewController
@dynamic formatter, appInfo, currencyStrings;

#pragma mark -
#pragma mark Custom accessors

- (NSNumberFormatter *)formatter {
	if (formatter == nil) {
		formatter = [[NSNumberFormatter alloc] init];
		[formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	}
	return formatter;
}

- (UILabel *)appInfo {
	CGRect appFrame = [UIScreen mainScreen].applicationFrame;
	NSString *text = [NSString stringWithFormat:@"Library Version: %@\nDemo App Version: %@",
					  [PayPal buildVersion], [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];
	UIFont *font = [UIFont systemFontOfSize:14.];
	CGSize size = [text sizeWithFont:font constrainedToSize:CGSizeMake(appFrame.size.width, MAXFLOAT)];
	UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(round((appFrame.size.width - size.width) / 2.), 0., size.width, size.height)] autorelease];
	label.font = font;
	label.text = text;
	label.textAlignment = UITextAlignmentCenter;
	label.numberOfLines = 0;
	label.backgroundColor = [UIColor clearColor];
	return label;
}

- (NSArray *)currencyStrings {
	if (currencyStrings == nil) {
		currencyStrings = [[[kCurrencyNames componentsSeparatedByString:@"|"] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] retain];
	}
	return currencyStrings;
}


#pragma mark -
#pragma mark Utility methods

- (void)setCurrencyCode:(NSString *)code {
	[self.formatter setCurrencyCode:code];
	[formatter setNegativeFormat:[NSString stringWithFormat:@"-%@", [formatter positiveFormat]]];
}

- (UITextField *)addTextFieldWithLabel:(NSString *)text tag:(NSUInteger)tag toView:(UIView *)container required:(BOOL)required type:(UIKeyboardType)type delegate:(id<UITextFieldDelegate>)delegate {
	CGFloat yPos = round((40. * container.subviews.count / 2.) + 10.);
	UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(5, yPos, 110, 30)] autorelease];
	label.text = text;
	label.font = [UIFont systemFontOfSize:14.];
	label.textAlignment = UITextAlignmentRight;
	label.backgroundColor = [UIColor clearColor];
	[container addSubview:label];
	UITextField *textField = [[[UITextField alloc] initWithFrame:CGRectMake(120, yPos, 190, 30)] autorelease];
	textField.tag = tag;
	textField.placeholder = [NSString stringWithFormat:@"%@ (%@)", text, required ? @"required" : @"optional"];
	textField.font = [UIFont systemFontOfSize:14.];
	textField.borderStyle = UITextBorderStyleRoundedRect;
	textField.delegate = delegate;
	textField.keyboardType = type;
	textField.autocorrectionType = UITextAutocorrectionTypeNo;
	textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	[container addSubview:textField];
	return textField;
}

- (UITextField *)addTextFieldWithLabel:(NSString *)text tag:(NSUInteger)tag toView:(UIView *)container required:(BOOL)required type:(UIKeyboardType)type {
	return [self addTextFieldWithLabel:text tag:tag toView:container required:required type:type delegate:self];
}

- (UITextField *)addTextFieldWithLabel:(NSString *)text tag:(NSUInteger)tag toView:(UIView *)container required:(BOOL)required {
	return [self addTextFieldWithLabel:text tag:tag toView:container required:required type:UIKeyboardTypeDefault];
}

- (UITextField *)addTextFieldWithLabel:(NSString *)text tag:(NSUInteger)tag toView:(UIView *)container {
	return [self addTextFieldWithLabel:text tag:tag toView:container required:FALSE];
}

BOOL containsOnlyDigits(NSString *string) {
	for (int i = 0; i < string.length; i++) {
		if (!isdigit([string characterAtIndex:i])) {
			return FALSE;
		}
	}
	return TRUE;
}

BOOL containsOnlyZeros(NSString *string) {
	for (int i = 0; i < string.length; i++) {
		if ([string characterAtIndex:i] != '0') {
			return FALSE;
		}
	}
	return TRUE;
}

- (NSDecimalNumber *)decimalNumberForField:(UITextField *)textField range:(NSRange)range string:(NSString *)string {
	NSMutableString *buf = [NSMutableString stringWithString:textField.text == nil ? @"" : textField.text];
	
	//check for negative sign in textField as well as in replacement string
	BOOL isDelete = string.length == 0;
	BOOL isNegative = [buf rangeOfString:@"-"].location != NSNotFound;
	if ([string rangeOfString:@"-"].location != NSNotFound) { //negative sign toggles
		isNegative = !isNegative;
		string = [string stringByReplacingOccurrencesOfString:@"-" withString:@""];
	}
	if ([string rangeOfString:@"+"].location != NSNotFound) { //plus sign makes positive
		isNegative = FALSE;
		string = [string stringByReplacingOccurrencesOfString:@"+" withString:@""];
	}
	
	for (int i = 0; i < buf.length; i++) {
		if (!isdigit([buf characterAtIndex:i])) {
			[buf replaceCharactersInRange:NSMakeRange(i, 1) withString:@""];
			
			if (range.location > i) {
				range.location--;
			} else if (range.location + range.length > i) {
				if (range.location > 0 && isDelete) {
					range.location--;
				} else if (range.length > 0) {
					range.length--;
				}
			}
			
			i--; //account for character just removed
		}
	}
	
	if (containsOnlyDigits(string)) {
		[buf replaceCharactersInRange:range withString:string];
	}
	
	NSUInteger paddedLength = [self.formatter maximumFractionDigits] + 1;
	
	while (buf.length < paddedLength) {
		[buf insertString:@"0" atIndex:0];
	}
	while (buf.length > paddedLength) {
		if ([buf characterAtIndex:0] == '0') {
			[buf replaceCharactersInRange:NSMakeRange(0, 1) withString:@""];
		} else {
			break;
		}
	}
	
	NSDecimalNumber *retVal = nil;
	if (isDelete && containsOnlyZeros(buf)) {
		textField.text = nil;
	} else {
		if (paddedLength > 1) {
			[buf insertString:@"." atIndex:buf.length - paddedLength + 1];
		}
		
		//place negative sign in buffer if needed
		if (isNegative) {
			[buf insertString:@"-" atIndex:0];
		}
		
		retVal = [NSDecimalNumber decimalNumberWithString:buf];
		
		NSString *formattedAmount = [self.formatter stringFromNumber:retVal];
		
		//allow negative sign to be entered first
		if (isNegative && [retVal isEqualToNumber:[NSDecimalNumber zero]]) {
			formattedAmount = [NSString stringWithFormat:@"-%@", formattedAmount];
		}
		
		textField.text = formattedAmount;
	}
	return retVal;
}

- (NSString *)currencyInfoForCurrency:(NSString *)currency fromString:(NSString *)currencyInfoString {
	return [[currencyInfoString componentsSeparatedByString:@"|"] objectAtIndex:[[kCurrencyCodes componentsSeparatedByString:@"|"] indexOfObject:currency]];
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 0; //override in children
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0; //override in children
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	return nil; //override in children
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	//override in children
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
    [super dealloc];
}


#pragma mark -
#pragma mark UITextFieldDelegate Methods

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
	
	CGFloat contentOffset = round(textField.frame.origin.y - (self.tableView.frame.size.height - 216. - textField.frame.size.height) / 2.);
	if (contentOffset < 0.) {
		contentOffset = 0.;
	}
	
	[self.tableView setContentOffset:CGPointMake(0., contentOffset) animated:TRUE];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
	if (resetScrollView) {
		resetScrollView = FALSE;
		BOOL animated = self.tableView.tableHeaderView.frame.size.height > self.tableView.contentOffset.y;
		if (animated) {
			[UIView beginAnimations:nil context:nil];
			[UIView setAnimationDuration:.3];
			[UIView setAnimationBeginsFromCurrentState:TRUE];
		}
		[self.tableView setContentOffset:CGPointZero animated:FALSE];
		if (animated) {
			[UIView commitAnimations];
		}
	}
	return TRUE;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	return TRUE; //override in children
}


@end

