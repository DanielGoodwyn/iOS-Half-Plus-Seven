
#import "AddViewController.h"
#import "AnswerViewController.h"
@import Firebase;

@interface AddViewController ()

@end

@implementation AddViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.themself = [[Person alloc] init];
    [self.theirName setText:@""];
    [self.theirDOB setDate:[NSDate dateWithTimeIntervalSince1970:360936000]];
    [self.theirDOB addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
    [self.theirName becomeFirstResponder];
    [self.theirAge setText:[NSString stringWithFormat:(@"%.02f"), (((([[self.theirDOB date] timeIntervalSinceNow]*-1)/365.25)/24)/60)/60 ]];

}

- (void)update {
    FIRUser *user = [FIRAuth auth].currentUser;
    if ([self.theirName.text isEqual: @""]) {
	[self.themself name:@"👤"];
    } else {
	[self.themself name:self.theirName.text];
    }
    [self.themself date:[self getDate:self.theirDOB]];
    [self.themself getAgeForDate:self.themself.DOB];
    
    FIRFirestore *db = [FIRFirestore firestore];
    [[db collectionWithPath:@"persons"] addDocumentWithData:@{
        @"name": self.themself.name.capitalizedString,
        @"dob": self.themself.DOB,
        @"user": user.uid,
        @"userId": user.uid
    }];
    
    AnswerViewController *answer = [self.storyboard instantiateViewControllerWithIdentifier:@"Answer"];
    answer.modalPresentationStyle = UIModalPresentationFullScreen;
    [answer setPassedPerson:self.theirName.text.capitalizedString];
    [answer setPassedDOB:self.theirDOB.date];
    [self.view.window makeKeyAndVisible];
    [self presentViewController:answer animated:YES completion:nil];
}

-(NSDate*)getDate:(id)sender {
    return [sender date];
}

- (IBAction)didEndOnExit:(id)sender {
    [self.theirName setAlpha:0];
    [self.theirAge setAlpha:0];
    [self.theirDOB setAlpha:1];
    [self.theirName resignFirstResponder];
    [self.theirAge resignFirstResponder];
    [self.segmentedControl setSelectedSegmentIndex:1];
}

- (void) dateChanged:(id)sender{
}

- (IBAction)update:(id)sender {
    [self update];
}

- (IBAction)valueChanged:(id)sender {
    [self.theirAge setText:[NSString stringWithFormat:(@"%.02f"), (((([[self.theirDOB date] timeIntervalSinceNow]*-1)/365.25)/24)/60)/60 ]];
}

- (IBAction)editingChanged:(id)sender {
    float age = [self.theirAge.text floatValue];
    NSDate *birthday = [NSDate dateWithTimeIntervalSinceNow:-(age*365.25*24*60*60)];
    [self.theirDOB setDate:birthday];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"themToAnswer"]) {
	AnswerViewController *answer = [segue destinationViewController];
	[answer setPassedPerson:self.theirName.text.capitalizedString];
	[answer setPassedDOB:self.theirDOB.date];
    }
}

- (IBAction)segmentedControl:(id)sender {

    UISegmentedControl *segmentedControl = (UISegmentedControl *) sender;
    NSInteger selectedSegment = segmentedControl.selectedSegmentIndex;

    if (selectedSegment == 0) {
	[self.theirName setAlpha:1];
	[self.theirDOB setAlpha:0];
	[self.theirAge setAlpha:0];
	[self.theirName becomeFirstResponder];
    } else if (selectedSegment == 1){
	[self.theirName setAlpha:0];
	[self.theirAge setAlpha:0];
	[self.theirDOB setAlpha:1];
	[self.theirName resignFirstResponder];
	[self.theirAge resignFirstResponder];
    } else if (selectedSegment == 2){
	[self.theirName setAlpha:0];
	[self.theirAge setAlpha:1];
	[self.theirDOB setAlpha:0];
	[self.theirAge becomeFirstResponder];
    }
}

@end
