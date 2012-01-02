
#import <UIKit/UIKit.h>

@class ListChoiceViewController;

@protocol ListChoiceDelegate <NSObject>
	@required
	- (void)itemChosenInListChoiceViewController:(ListChoiceViewController *)lcvc;
@end

@interface ListChoiceViewController : UITableViewController {
	@private
	id<ListChoiceDelegate> choiceDelegate;
	NSUInteger groupId;
	NSArray *items;
	NSUInteger selectedIndex;
}

@property (nonatomic, assign) id<ListChoiceDelegate> choiceDelegate;
@property (nonatomic, assign) NSUInteger groupId;
@property (nonatomic, retain) NSArray *items;
@property (nonatomic, assign) NSUInteger selectedIndex;

@end
