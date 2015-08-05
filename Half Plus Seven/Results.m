
#import "Results.h"
#import "Answer.h"

@interface Results ()

@end

@implementation Results

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
        self.yourself.name = [[[yourselfQuery getObjectWithId:object.objectId] objectForKey:@"username"] capitalizedString];
        self.yourself.DOB = [[yourselfQuery getObjectWithId:object.objectId] objectForKey:@"DOB"];
        self.themself.name = passedPerson;
        self.themself.DOB = passedDOB;
        [self update];
    }];
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
        Answer *answer = [segue destinationViewController];
        [answer setPassedPerson:passedPerson];
        [answer setPassedDOB:passedDOB];
    }
}

@end
