
#import "AnswerViewController.h"
#import "NamesViewController.h"
#import "NamesViewController+NavBarHelper.h"

@import Firebase;

@interface AnswerViewController ()
@property id<FIRListenerRegistration> userListener;
@end

@implementation AnswerViewController

@synthesize passedPerson, passedDOB;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.388 green:0.565 blue:0.898 alpha:1.0];

    self.yourself = [[Person alloc] init];
    self.themself = [[Person alloc] init];

    // Make sure answer labels are white on blue background
    self.answer.textColor = [UIColor whiteColor];
    self.name.textColor = [UIColor whiteColor];
    self.emoji.textColor = [UIColor whiteColor];
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
    addFlatButton(self.view, @"Done", 9002, @selector(doneTapped), self, NO, [UIFont systemFontOfSize:17]);

    FIRUser *currentUser = [FIRAuth auth].currentUser;
    if (currentUser) {
        FIRFirestore *db = [FIRFirestore firestore];
        self.userListener = [[[db collectionWithPath:@"users"] documentWithPath:currentUser.uid] addSnapshotListener:^(FIRDocumentSnapshot * _Nullable snapshot, NSError * _Nullable error) {
            if (snapshot.exists) {
                self.yourself.name = [snapshot.data objectForKey:@"name"];
                self.yourself.DOB = ((FIRTimestamp *)[snapshot.data objectForKey:@"dob"]).dateValue;
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

- (void)doneTapped {
    NamesViewController *names = [self.storyboard instantiateViewControllerWithIdentifier:@"Names"];
    names.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.view.window makeKeyAndVisible];
    [self presentViewController:names animated:YES completion:nil];
}

@end
