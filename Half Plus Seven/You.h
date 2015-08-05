
#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "Person.h"

@interface You : UIViewController

@property IBOutlet UITextField *yourName;
@property IBOutlet UIDatePicker *yourDOB;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *logOut;

- (NSDate*)getDate:(id)sender;

@end
