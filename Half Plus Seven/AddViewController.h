
#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "Person.h"

@interface AddViewController : UIViewController

@property Person *themself;
@property IBOutlet UITextField *theirName;
@property IBOutlet UIDatePicker *theirDOB;
@property (weak, nonatomic) IBOutlet UITextField *theirAge;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

- (NSDate*)getDate:(id)sender;
- (IBAction)didEndOnExit:(id)sender;

@end
