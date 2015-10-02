
#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface NamesViewController : UIViewController

@property NSMutableArray *people;
@property NSMutableArray *DOBs;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *profile;
@property IBOutlet UITableView *peopleTableView;
@property (weak, nonatomic) IBOutlet UIButton *add;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end
