
#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface List : UIViewController

@property NSMutableArray *people;
@property NSMutableArray *DOBs;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *profile;
@property IBOutlet UITableView *peopleTableView;
@property (weak, nonatomic) IBOutlet UIButton *add;

@end
