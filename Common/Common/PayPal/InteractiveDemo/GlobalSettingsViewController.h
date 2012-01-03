
#import <UIKit/UIKit.h>
#import "TextFieldTableViewController.h"
#import "ListChoiceViewController.h"
#import "PayPal.h"

@interface GlobalSettingsViewController : TextFieldTableViewController <ListChoiceDelegate> {
@private
	UITextField *appIdField;
	PayPalEnvironment environment;
	NSString *language;
	PayPalButtonType buttonType;
	UISegmentedControl *buttonTextControl;

	NSArray *languageStrings;
	NSArray *environmentStrings;
	NSArray *buttonTypeStrings;
}

@property (nonatomic, retain) UITextField *appIdField;
@property (nonatomic, retain) NSString *language;
@property (nonatomic, assign) PayPalEnvironment environment;
@property (nonatomic, assign) PayPalButtonType buttonType;

@property (nonatomic, retain) UISegmentedControl *buttonTextControl;

@property (nonatomic, retain) NSArray *languageStrings;
@property (nonatomic, retain) NSArray *environmentStrings;
@property (nonatomic, retain) NSArray *buttonTypeStrings;

@end
