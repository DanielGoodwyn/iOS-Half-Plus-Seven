
#import "ResultsViewController.h"
#import "AnswerViewController.h"
#import "NamesViewController.h"
#import "NamesViewController+NavBarHelper.h"

@import Firebase;
@import FirebaseAuth;
@import FirebaseFirestore;

@interface ResultsViewController ()
@property id<FIRListenerRegistration> userListener;
@end

@implementation ResultsViewController

@synthesize passedPerson, passedDOB;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.388 green:0.565 blue:0.898 alpha:1.0];

    self.yourself = [[Person alloc] init];
    self.themself = [[Person alloc] init];

    // Make results text white
    self.us.textColor = [UIColor whiteColor];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.userListener) {
        [self.userListener remove];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    flattenNavBar(self.view);
    addFlatTitle(self.view, @"½ + 7", 9003);
    addFlatButton(self.view, @"Back", 9001, @selector(backTapped), self, YES, [UIFont systemFontOfSize:17]);
    addFlatButton(self.view, @"Done", 9002, @selector(doneTapped), self, NO, [UIFont systemFontOfSize:17]);

    FIRUser *currentUser = [FIRAuth auth].currentUser;
    if (currentUser) {
        FIRFirestore *db = [FIRFirestore firestore];
        self.userListener = [[[db collectionWithPath:@"users"] documentWithPath:currentUser.uid] addSnapshotListener:^(FIRDocumentSnapshot * _Nullable snapshot, NSError * _Nullable error) {
            NSString *displayName = @"You";
            if (snapshot.exists) {
                NSString *name = [snapshot.data objectForKey:@"name"];
                if ([name isKindOfClass:[NSString class]] && [[name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0) {
                    displayName = [name capitalizedString];
                } else if (currentUser.email.length > 0) {
                    displayName = currentUser.email;
                }
            } else if (currentUser.email.length > 0) {
                displayName = currentUser.email;
            }
            self.yourself.name = displayName;
            if (snapshot.exists) {
                self.yourself.DOB = ((FIRTimestamp *)[snapshot.data objectForKey:@"dob"]).dateValue;
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

- (void)backTapped {
    AnswerViewController *answer = [self.storyboard instantiateViewControllerWithIdentifier:@"Answer"];
    answer.modalPresentationStyle = UIModalPresentationFullScreen;
    [answer setPassedPerson:passedPerson];
    [answer setPassedDOB:passedDOB];
    [self.view.window makeKeyAndVisible];
    [self presentViewController:answer animated:YES completion:nil];
}

- (void)doneTapped {
    NamesViewController *names = [self.storyboard instantiateViewControllerWithIdentifier:@"Names"];
    names.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.view.window makeKeyAndVisible];
    [self presentViewController:names animated:YES completion:nil];
}

@end
