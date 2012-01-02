
#import "SimpleDemoAppDelegate.h"
#import "PayPal.h"
#import "FourButtonViewController.h"

@implementation SimpleDemoAppDelegate

@synthesize window, navigationController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {
	//You must call initializeWithAppID:forEnvironment: or initializeWithAppID: before performing any other
	//action with the library. You must supply your application ID, and you may specify the environment
	//by passing in ENV_LIVE (default), ENV_SANDBOX, or ENV_NONE (offline demo mode).
    // [PayPal initializeWithAppID:@"APP-80W284485P519543T" forEnvironment:ENV_SANDBOX];

	
    //	[PayPal initializeWithAppID:@"your live app id" forEnvironment:ENV_LIVE];
	[PayPal initializeWithAppID:@"anything" forEnvironment:ENV_NONE];
	
	FourButtonViewController *fbvc = [[[FourButtonViewController alloc] init] autorelease];
	self.navigationController = [[[UINavigationController alloc] initWithRootViewController:fbvc] autorelease];
	self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
	[window addSubview:navigationController.view];
	[window makeKeyAndVisible];
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

- (void)dealloc {
	self.navigationController = nil;
	self.window = nil;
    [super dealloc];
}


@end
