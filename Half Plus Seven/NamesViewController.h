
#import <UIKit/UIKit.h>

@interface NamesViewController : UIViewController

@property NSMutableArray *people;
@property NSMutableArray *DOBs;
@property NSMutableArray *documentIDs;
@property id<FIRListenerRegistration> legacyListener;
@property id<FIRListenerRegistration> webListener;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *profile;
@property IBOutlet UITableView *peopleTableView;
@property (weak, nonatomic) IBOutlet UIButton *add;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end
