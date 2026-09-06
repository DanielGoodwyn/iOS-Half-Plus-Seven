
#import "AnswerViewController.h"

@import Firebase;

@interface AnswerViewController ()

@end

@implementation AnswerViewController

@synthesize passedPerson, passedDOB;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.388 green:0.565 blue:0.898 alpha:1.0];
    [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UINavigationBar class]]] setBackgroundImage:[[UIImage alloc] init] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UINavigationBar class]]] setBackgroundImage:[[UIImage alloc] init] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];

    for (UIView *subview in self.view.subviews) {
        if ([subview isKindOfClass:[UINavigationBar class]]) {
            UINavigationBar *navBar = (UINavigationBar *)subview;
            [navBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
            navBar.shadowImage = [UIImage new];
            navBar.translucent = YES;
            navBar.backgroundColor = [UIColor clearColor];
            navBar.barTintColor = [UIColor clearColor];
            navBar.tintColor = [UIColor whiteColor];
            for (UINavigationItem *item in navBar.items) {
                if (item.leftBarButtonItem && !item.leftBarButtonItem.customView) {
                    if (item.leftBarButtonItem.title) {
                        UILabel *lbl = [[UILabel alloc] init];
                        lbl.text = item.leftBarButtonItem.title;
                        lbl.textColor = [UIColor whiteColor];
                        lbl.font = [UIFont systemFontOfSize:17];
                        [lbl sizeToFit];
                        lbl.userInteractionEnabled = NO;
                        item.leftBarButtonItem.customView = lbl;
                    } else if (item.leftBarButtonItem.image) {
                        UIImageView *iv = [[UIImageView alloc] initWithImage:item.leftBarButtonItem.image];
                        iv.tintColor = [UIColor whiteColor];
                        iv.userInteractionEnabled = NO;
                        item.leftBarButtonItem.customView = iv;
                    }
                }
                if (item.rightBarButtonItem && !item.rightBarButtonItem.customView) {
                    if (item.rightBarButtonItem.title) {
                        UILabel *lbl = [[UILabel alloc] init];
                        lbl.text = item.rightBarButtonItem.title;
                        lbl.textColor = [UIColor whiteColor];
                        lbl.font = [UIFont systemFontOfSize:17];
                        [lbl sizeToFit];
                        lbl.userInteractionEnabled = NO;
                        item.rightBarButtonItem.customView = lbl;
                    } else if (item.rightBarButtonItem.image || !item.rightBarButtonItem.title) {
                        UILabel *lbl = [[UILabel alloc] init];
                        lbl.text = @"+";
                        lbl.textColor = [UIColor whiteColor];
                        lbl.font = [UIFont systemFontOfSize:24 weight:UIFontWeightRegular];
                        [lbl sizeToFit];
                        lbl.userInteractionEnabled = NO;
                        item.rightBarButtonItem.customView = lbl;
                    }
                }
            }

            if (@available(iOS 15.0, *)) {
                UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
                [appearance configureWithTransparentBackground];
                appearance.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
                UIBarButtonItemAppearance *buttonAppearance = [[UIBarButtonItemAppearance alloc] initWithStyle:UIBarButtonItemStylePlain];
                buttonAppearance.normal.backgroundImage = [[UIImage alloc] init];
                buttonAppearance.highlighted.backgroundImage = [[UIImage alloc] init];
                buttonAppearance.focused.backgroundImage = [[UIImage alloc] init];
                buttonAppearance.disabled.backgroundImage = [[UIImage alloc] init];
                buttonAppearance.normal.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
                appearance.buttonAppearance = buttonAppearance;
                navBar.standardAppearance = appearance;
                navBar.scrollEdgeAppearance = appearance;
                navBar.compactAppearance = appearance;
            }
        }
    }

    self.yourself = [[Person alloc] init];
    self.themself = [[Person alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {

    FIRUser *currentUser = [FIRAuth auth].currentUser;
    if (currentUser) {
        FIRFirestore *db = [FIRFirestore firestore];
        [[[db collectionWithPath:@"users"] documentWithPath:currentUser.uid] getDocumentWithCompletion:^(FIRDocumentSnapshot * _Nullable snapshot, NSError * _Nullable error) {
            if (snapshot.exists) {
                self.yourself.name = [snapshot.data objectForKey:@"name"];
                self.yourself.DOB = ((FIRTimestamp *)[snapshot.data objectForKey:@"DOB"]).dateValue;
                [self.themself setName:passedPerson];
                [self.themself setDOB:passedDOB];
                [self.yourself getAge];
                [self.themself getAge];
                double yourLowerRange = (self.yourself.age/2)+7;
                double yourUpperRange = (self.yourself.age-7)*2;
                if (self.yourself.age < 14 || self.themself.age < 14) {
                    self.answer.text = @"⛔️";
                    self.name.text = [NSString stringWithFormat: @"Nobody under 14 please..."];
                    self.emoji.text = @"👶👎";
                } else if (self.themself.age > yourLowerRange && self.themself.age < yourUpperRange) {
                    self.answer.text = @"YES";
                    self.name.text = [NSString stringWithFormat: @"to %@", self.themself.name];
                    self.emoji.text = @"😍👍";
                } else if (self.themself.age < yourLowerRange) {
                    self.answer.text = @"NO";
                    self.name.text = [NSString stringWithFormat: @"%@ is too young for you.", self.themself.name];
                    self.emoji.text = @"😖👎";
                } else if (self.themself.age > yourUpperRange) {
                    self.answer.text = @"NO";
                    self.name.text = [NSString stringWithFormat: @"%@ is too old for you.", self.themself.name];
                    self.emoji.text = @"😖👎";
                }
            }
        }];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"AnswerToResults"]) {
	AnswerViewController *answer = [segue destinationViewController];
	[answer setPassedPerson:passedPerson];
	[answer setPassedDOB:passedDOB];
    }
}

@end
