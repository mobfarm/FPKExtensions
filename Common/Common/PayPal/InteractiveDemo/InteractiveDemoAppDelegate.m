
#import "InteractiveDemoAppDelegate.h"
#import "PayPal.h"
#import "PayPalContext.h"
#import "GlobalSettingsViewController.h"

@implementation InteractiveDemoAppDelegate

@synthesize window, navigationController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {
	GlobalSettingsViewController *gsvc = [[[GlobalSettingsViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
	self.navigationController = [[[UINavigationController alloc] initWithRootViewController:gsvc] autorelease];
	
	self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
	[window addSubview:navigationController.view];    
	[window makeKeyAndVisible];
}

- (void)dealloc {
	self.navigationController = nil;
	self.window = nil;
    [super dealloc];
}


@end
