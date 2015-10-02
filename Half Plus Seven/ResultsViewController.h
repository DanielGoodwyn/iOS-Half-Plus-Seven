
#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "Person.h"

@interface ResultsViewController : UIViewController
{
    NSString *passedPerson;
    NSDate *passedDOB;
}

@property Person *yourself;
@property Person *themself;
@property IBOutlet UILabel *us;
@property(nonatomic) NSString *passedPerson;
@property(nonatomic) NSDate *passedDOB;

@end
