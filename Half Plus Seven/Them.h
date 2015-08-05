
#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "Person.h"

@interface Them : UIViewController

@property Person *themself;
@property IBOutlet UITextField *theirName;
@property IBOutlet UIDatePicker *theirDOB;

- (NSDate*)getDate:(id)sender;

@end
