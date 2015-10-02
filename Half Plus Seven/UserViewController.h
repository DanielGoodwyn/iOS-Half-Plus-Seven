
#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "Person.h"

@interface UserViewController : UIViewController
{
    NSString *passedPerson;
    NSDate *passedDOB;
}

@property IBOutlet UITextField *name;
@property IBOutlet UIDatePicker *yourDOB;
@property(nonatomic) NSString *passedPerson;
@property(nonatomic) NSDate *passedDOB;
@property (weak, nonatomic) IBOutlet UITextField *ageTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

- (NSDate*)getDate:(id)sender;
- (IBAction)valueChanged:(id)sender;
- (IBAction)editingChanged:(id)sender;
- (IBAction)didEndOnExit:(id)sender;

@end
