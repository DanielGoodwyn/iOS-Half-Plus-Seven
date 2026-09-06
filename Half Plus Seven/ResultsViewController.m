
#import "ResultsViewController.h"
#import "AnswerViewController.h"

@import Firebase;

@interface ResultsViewController ()

@end

@implementation ResultsViewController

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
                self.yourself.name = [[snapshot.data objectForKey:@"name"] capitalizedString];
                self.yourself.DOB = ((FIRTimestamp *)[snapshot.data objectForKey:@"DOB"]).dateValue;
                self.themself.name = passedPerson;
                self.themself.DOB = passedDOB;
                [self update];
            }
        }];
    }
}

- (void)update{
    [self.yourself getAge];
    [self.themself getAge];
    double yourLowerRange = (self.yourself.age/2)+7;
    double yourUpperRange = (self.yourself.age-7)*2;
    double theirLowerRange = (self.themself.age/2)+7;
    double theirUpperRange = (self.themself.age-7)*2;
    self.us.text = [NSString stringWithFormat:@"%@, %.02f years old\nrange: %.02f - %.02f\n\n%@, %.02f years old\nrange: %.02f - %.02f\n\n",[self.yourself name],[self.yourself age],yourLowerRange,yourUpperRange,[self.themself name],[self.themself age],theirLowerRange,theirUpperRange];
    if (self.yourself.age < 14 || self.themself.age < 14) {
	self.us.text = [NSString stringWithFormat: @"Nobody under 14 please..."];
    } else if (self.yourself.age > self.themself.age) {
	double difference = self.yourself.age - self.themself.age;
	double wait = (yourLowerRange - self.themself.age)*2;
	if (self.themself.age>((self.yourself.age/2)+7)) {
	    if ([[NSString stringWithFormat: @"%.02f",difference] isEqualToString:@"0"]) {
		self.us.text = [NSString stringWithFormat: @"%@You're less than a year older than %@.",self.us.text, [self.themself name]];
	    } else if ([[NSString stringWithFormat: @"%.02f",difference] isEqualToString:@"1"]) {
		self.us.text = [NSString stringWithFormat: @"%@You're only a year older than %@.",self.us.text, [self.themself name]];
	    } else if (difference<((self.yourself.age/2)+7)/6) {
		self.us.text = [NSString stringWithFormat: @"%@You're only %.02f years older than %@.",self.us.text, difference, [self.themself name]];
	    } else {
		self.us.text = [NSString stringWithFormat: @"%@You're %.02f years older than %@.",self.us.text, difference, [self.themself name]];
	    }
	} else {
	    self.us.text = [NSString stringWithFormat: @"%@You're %.02f years older than %@.\n\n...but if you wait %.02f years...",self.us.text, difference, [self.themself name], wait];
	}
    } else  if (self.yourself.age < self.themself.age) {
	double difference = self.themself.age - self.yourself.age;
	double wait = (theirLowerRange - self.yourself.age)*2;
	if (self.yourself.age>((self.themself.age/2)+7)) {
	    if ([[NSString stringWithFormat: @"%.02f",difference] isEqualToString:@"0"]) {
		self.us.text = [NSString stringWithFormat: @"%@%@ is less than a year older than you.",self.us.text, [self.themself name]];
	    } else if ([[NSString stringWithFormat: @"%.02f",difference] isEqualToString:@"1"]) {
		self.us.text = [NSString stringWithFormat: @"%@%@ is only a year older than you.",self.us.text, [self.themself name]];
	    } else if (difference<((self.yourself.age/2)+7)/6) {
		self.us.text = [NSString stringWithFormat: @"%@%@ is only %.02f years older than you.",self.us.text, [self.themself name], difference];
	    } else {
		self.us.text = [NSString stringWithFormat: @"%@%@ is %.02f years older than you.",self.us.text, [self.themself name], difference];
	    }
	} else {
	    self.us.text = [NSString stringWithFormat: @"%@%@ is %.02f years older than you.\n\n...but if you wait %.02f years...",self.us.text, [self.themself name], difference, wait];
	}
    } else {
	self.us.text = [NSString stringWithFormat: @"%@You and %@ are exactly the same age.",self.us.text, [self.themself name]];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"ResultsToAnswer"]) {
	AnswerViewController *answer = [segue destinationViewController];
	[answer setPassedPerson:passedPerson];
	[answer setPassedDOB:passedDOB];
    }
}

@end
