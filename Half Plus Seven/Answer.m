
#import "Answer.h"

@interface Answer ()

@end

@implementation Answer

@synthesize passedPerson, passedDOB;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.yourself = [[Person alloc] init];
    self.themself = [[Person alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
    
    PFQuery *yourselfQuery= [PFUser query];
    [yourselfQuery whereKey:@"username" equalTo:[[PFUser currentUser]username]];
    [yourselfQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error){
        self.yourself.name = [[yourselfQuery getObjectWithId:object.objectId] objectForKey:@"username"];
        self.yourself.DOB = [[yourselfQuery getObjectWithId:object.objectId] objectForKey:@"DOB"];
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
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"AnswerToResults"]) {
        Answer *answer = [segue destinationViewController];
        [answer setPassedPerson:passedPerson];
        [answer setPassedDOB:passedDOB];
    }
}

@end
