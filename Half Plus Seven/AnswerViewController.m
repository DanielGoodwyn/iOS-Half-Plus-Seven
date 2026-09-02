
#import "AnswerViewController.h"

@import Firebase;

@interface AnswerViewController ()

@end

@implementation AnswerViewController

@synthesize passedPerson, passedDOB;

- (void)viewDidLoad {
    [super viewDidLoad];
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
