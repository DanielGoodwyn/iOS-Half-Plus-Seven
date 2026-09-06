
#import "AnswerViewController.h"

@import Firebase;

@interface AnswerViewController ()

@end

@implementation AnswerViewController

@synthesize passedPerson, passedDOB;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.388 green:0.565 blue:0.898 alpha:1.0];
    for (UIView *subview in self.view.subviews) {
        if ([subview isKindOfClass:[UINavigationBar class]]) {
            UINavigationBar *navBar = (UINavigationBar *)subview;
            [navBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
            navBar.shadowImage = [UIImage new];
            navBar.translucent = YES;
            navBar.backgroundColor = [UIColor clearColor];
            navBar.barTintColor = [UIColor clearColor];
            navBar.tintColor = [UIColor whiteColor];
            if (@available(iOS 15.0, *)) {
                UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
                [appearance configureWithTransparentBackground];
                appearance.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
                UIBarButtonItemAppearance *buttonAppearance = [[UIBarButtonItemAppearance alloc] initWithStyle:UIBarButtonItemStylePlain];
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
