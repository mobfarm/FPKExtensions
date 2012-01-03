
#import <UIKit/UIKit.h>

#define TextFieldTableInstance ((TextFieldTableViewController *)[self.navigationController.viewControllers objectAtIndex:0])

//copied from MPL
#define kCurrencyCodes @"USD|AUD|BRL|GBP|CAD|CZK|DKK|EUR|HKD|HUF|ILS|JPY|MYR|MXN|NZD|NOK|PHP|PLN|SGD|SEK|CHF|TWD|THB"
#define kCurrencyNames @"U.S. Dollars|Australian Dollars|Brazilian Real|British Pounds|Canadian Dollars|Czech Koruna|Danish Kroner|Euros|Hong Kong Dollars|Hungarian Forint|Israeli New Shekels|Japanese Yen|Malaysian Ringgits|Mexican Pesos|New Zealand Dollars|Norwegian Kroner|Philippine Pesos|Polish Zlotych|Singapore Dollars|Swedish Kronor|Swiss Francs|Taiwan New Dollars|Thai Bhat"

#define DEFAULT_CURRENCY @"USD"

@interface TextFieldTableViewController : UITableViewController <UITextFieldDelegate> {
@private
	BOOL resetScrollView;
}

@property (nonatomic, readonly) NSNumberFormatter *formatter;
@property (nonatomic, readonly) UILabel *appInfo;
@property (nonatomic, readonly) NSArray *currencyStrings;

- (UITextField *)addTextFieldWithLabel:(NSString *)text tag:(NSUInteger)tag toView:(UIView *)container required:(BOOL)required type:(UIKeyboardType)type delegate:(id<UITextFieldDelegate>)delegate;
- (UITextField *)addTextFieldWithLabel:(NSString *)text tag:(NSUInteger)tag toView:(UIView *)container required:(BOOL)required type:(UIKeyboardType)type;
- (UITextField *)addTextFieldWithLabel:(NSString *)text tag:(NSUInteger)tag toView:(UIView *)container required:(BOOL)required;
- (UITextField *)addTextFieldWithLabel:(NSString *)text tag:(NSUInteger)tag toView:(UIView *)container;
- (NSDecimalNumber *)decimalNumberForField:(UITextField *)textField range:(NSRange)range string:(NSString *)string;
- (NSString *)currencyInfoForCurrency:(NSString *)currency fromString:(NSString *)currencyInfoString;
- (void)setCurrencyCode:(NSString *)code;

@end
