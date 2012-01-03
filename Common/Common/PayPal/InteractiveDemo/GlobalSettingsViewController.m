
#import "GlobalSettingsViewController.h"
#import "PaymentViewController.h"
#import "PreapprovalViewController.h"

//copied from MPL
#define kSupportedLangs @"en_US,es_AR,pt_BR,en_GB,en_AU,de_AT,en_DE,en_BE,nl_BE,fr_BE,fr_CH,en_CA,fr_CA,fr_FR,en_FR,de_DE,en_DE,zh_HK,en_HK,en_IN,it_IT,ja_JP,en_JP,es_MX,en_MX,nl_NL,en_NL,pl_PL,en_PL,en_SG,es_ES,en_ES,de_CH,en_CH,fr_CH,zh_TW,en_TW,en_IT,en_AR,en_BR,en_AT"

typedef enum GlobalSettingsSections {
	SECTION_SETTINGS,
	SECTION_FLOWCHOICE,
	SECTION_COUNT,
} GlobalSettingsSection;

typedef enum GlobalSettingsRows {
	SETTING_ENVIRONMENT,
	SETTING_LANGUAGE,
	SETTING_BUTTON,
	SETTING_COUNT,
} GlobalSettingsRow;

typedef enum GlobalPaymentFlowRows {
	PAYMENTFLOW_SIMPLE,
	PAYMENTFLOW_ADVANCED,
	PAYMENTFLOW_PREAPPROVAL,
	PAYMENTFLOW_COUNT,
} GlobalPaymentFlowRow;

@implementation GlobalSettingsViewController
@synthesize appIdField, language, environment, buttonType, buttonTextControl, languageStrings, environmentStrings, buttonTypeStrings;

#pragma mark -
#pragma mark Utility methods

- (NSString *)appIdForCurrentEnvironment {
	switch (environment) {
		case ENV_LIVE:
            //DEVPACKAGE return @"your live app id";
			return @"APP-4CX08424K55554229";
		case ENV_SANDBOX:
			return @"APP-80W284485P519543T";
		case ENV_NONE:
			return @"anything";
	}
	return nil;
}


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = @"Interactive Demo";
	self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Options" style:UIBarButtonItemStylePlain target:nil action:NULL] autorelease];
	
	self.environment = ENV_SANDBOX;
	self.language = nil;
	self.buttonType = BUTTON_294x43;
	
	CGRect appFrame = [UIScreen mainScreen].applicationFrame;
	UIView *header = [[[UIView alloc] initWithFrame:CGRectMake(0., 0., appFrame.size.width, 50.)] autorelease];
	
	self.appIdField = [self addTextFieldWithLabel:@"x.com App Id" tag:0 toView:header required:TRUE];
	appIdField.placeholder = [self appIdForCurrentEnvironment];
	
	CGRect frame = header.frame;
	frame.size.height = appIdField.frame.origin.y + appIdField.frame.size.height + 10.;
	header.frame = frame;
	self.tableView.tableHeaderView = header;
	
	UILabel *label = self.appInfo;
	frame = label.frame;
	frame.origin.y = 10.;
	label.frame = frame;
	UIView *footer = [[[UIView alloc] initWithFrame:CGRectMake(0., 0., appFrame.size.width, label.frame.origin.y + label.frame.size.height + 10.)] autorelease];
	[footer addSubview:label];
	
	self.tableView.tableFooterView = footer;
	
	self.languageStrings = [[kSupportedLangs componentsSeparatedByString:@","] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
	
	//this must match the order of the PayPalEnvironment enum
    self.environmentStrings = [NSArray arrayWithObjects:@"Live", @"Sandbox", @"None", nil];
	
	//this must match the PayPalButtonType enum
	self.buttonTypeStrings = [NSArray arrayWithObjects:@"152 x 33", @"194 x 37", @"278 x 43", @"294 x 43", nil];
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return SECTION_COUNT;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	switch (section) {
		default:
		case SECTION_SETTINGS:
			return SETTING_COUNT;
		case SECTION_FLOWCHOICE:
			return PAYMENTFLOW_COUNT;
	}
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
	if (indexPath.section == SECTION_SETTINGS && indexPath.row == SETTING_BUTTON) {
		cell.accessoryType = UITableViewCellAccessoryNone;
	} else {
		cell.accessoryView = nil;
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
	switch (indexPath.section) {
		case SECTION_SETTINGS:
			switch (indexPath.row) {
				case SETTING_ENVIRONMENT:
                    cell.textLabel.text = [NSString stringWithFormat:@"Environment: %@", [environmentStrings objectAtIndex:environment]];
					break;
				case SETTING_LANGUAGE:
					cell.textLabel.text = [NSString stringWithFormat:@"Language: %@", language.length == 0 ? @"Use Device Setting" : language];
					break;
				case SETTING_BUTTON:
					cell.textLabel.text = [NSString stringWithFormat:@"Button: %@", [buttonTypeStrings objectAtIndex:buttonType]];
					if (buttonTextControl == nil) {
						//must match PayPalButtonText enum
						NSArray *buttonText = [NSArray arrayWithObjects:@"Pay", @"Donate", nil];
						self.buttonTextControl = [[[UISegmentedControl alloc] initWithItems:buttonText] autorelease];
						buttonTextControl.segmentedControlStyle = UISegmentedControlStyleBar;
						buttonTextControl.selectedSegmentIndex = BUTTON_TEXT_PAY;
					}
					cell.accessoryView = buttonTextControl;
					break;
			}
			break;
		case SECTION_FLOWCHOICE:
			switch (indexPath.row) {
				case PAYMENTFLOW_SIMPLE:
					cell.textLabel.text = @"Simple Payment";
					break;
				case PAYMENTFLOW_ADVANCED:
					cell.textLabel.text = @"Advanced Payment";
					break;
				case PAYMENTFLOW_PREAPPROVAL:
					cell.textLabel.text = @"Preapproval";
					break;
			}
			break;
	}
			
    return cell;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	switch (indexPath.section) {
		case SECTION_SETTINGS: {
			ListChoiceViewController *lcvc = [[[ListChoiceViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
			lcvc.choiceDelegate = self;
			lcvc.groupId = indexPath.row;
			
			switch (indexPath.row) {
				case SETTING_ENVIRONMENT:
					lcvc.title = @"Environment";
					lcvc.items = environmentStrings;
                    lcvc.selectedIndex = environment;
					break;
				case SETTING_LANGUAGE:
					lcvc.title = @"Language";
					lcvc.items = languageStrings;
					lcvc.selectedIndex = language.length == 0 ? -1 : [languageStrings indexOfObject:language];
					break;
				case SETTING_BUTTON:
					lcvc.title = @"Button Type";
					lcvc.items = buttonTypeStrings;
					lcvc.selectedIndex = buttonType;
					break;
			}
			
			[self.navigationController pushViewController:lcvc animated:TRUE];
		} break;
		case SECTION_FLOWCHOICE:
			[PayPal initializeWithAppID:appIdField.text.length > 0 ? appIdField.text : appIdField.placeholder forEnvironment:environment];
			if (language.length > 0) {
				[PayPal getPayPalInst].lang = language;
			}
			switch (indexPath.row) {
				case PAYMENTFLOW_SIMPLE:
				case PAYMENTFLOW_ADVANCED: {
					PaymentViewController *pvc = [[[PaymentViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
					pvc.isAdvanced = indexPath.row == PAYMENTFLOW_ADVANCED;
					pvc.buttonType = buttonType;
					pvc.buttonText = buttonTextControl.selectedSegmentIndex;
					[self.navigationController pushViewController:pvc animated:TRUE];
				} break;
				case PAYMENTFLOW_PREAPPROVAL: {
					PreapprovalViewController *pvc = [[[PreapprovalViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
					pvc.buttonType = buttonType;
					pvc.buttonText = buttonTextControl.selectedSegmentIndex;
					[self.navigationController pushViewController:pvc animated:TRUE];
				} break;
			}
			break;
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
	self.appIdField = nil;
	self.language = nil;
	self.buttonTextControl = nil;
	self.languageStrings = nil;
	self.environmentStrings = nil;
	self.buttonTypeStrings = nil;
    [super dealloc];
}


#pragma mark -
#pragma mark ListChoiceDelegate methods

- (void)itemChosenInListChoiceViewController:(ListChoiceViewController *)lcvc {
	switch (lcvc.groupId) {
		case SETTING_ENVIRONMENT:
            self.environment = lcvc.selectedIndex;
			self.appIdField.placeholder = [self appIdForCurrentEnvironment];
			break;
		case SETTING_LANGUAGE:
			self.language = [languageStrings objectAtIndex:lcvc.selectedIndex];
			break;
		case SETTING_BUTTON:
			self.buttonType = lcvc.selectedIndex;
			break;
	}
	
	[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:lcvc.groupId inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}


@end

