
#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "Person.h"

@interface Answer : UIViewController
{
    NSString *passedPerson;
    NSDate *passedDOB;
}

@property Person *yourself;
@property Person *themself;
@property IBOutlet UILabel *answer;
@property IBOutlet UILabel *name;
@property IBOutlet UILabel *emoji;
@property(nonatomic) NSString *passedPerson;
@property(nonatomic) NSDate *passedDOB;

@end
