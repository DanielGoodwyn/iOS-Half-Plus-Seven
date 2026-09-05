#import "UserViewController.h"
#import "LogInViewController.h"
#import "NamesViewController.h"
@import Firebase;

@interface UserViewController ()

@end

@implementation UserViewController

@synthesize passedPerson, passedDOB;

- (void)viewDidLoad {
    [super viewDidLoad];

    FIRUser *currentUser = [FIRAuth auth].currentUser;
    if (currentUser) {
        FIRFirestore *db = [FIRFirestore firestore];
        [[[db collectionWithPath:@"users"] documentWithPath:currentUser.uid] getDocumentWithCompletion:^(FIRDocumentSnapshot * _Nullable snapshot, NSError * _Nullable error) {
            if (snapshot.exists) {
                [self.name setText:[[snapshot.data objectForKey:@"name"] capitalizedString]];
                if ([snapshot.data objectForKey:@"dob"]) {
                    NSDate *dob = ((FIRTimestamp *)[snapshot.data objectForKey:@"dob"]).dateValue;
                    [self.yourDOB setDate:dob];
                    [self.ageTextField setText:[NSString stringWithFormat:(@"%.02f"), (((([[self.yourDOB date] timeIntervalSinceNow]*-1)/365.25)/24)/60)/60 ]];
                }
            }
        }];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [self.name becomeFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated {
    FIRUser *currentUser = [FIRAuth auth].currentUser;
    if (!currentUser) {
	LogInViewController *profile = [self.storyboard instantiateViewControllerWithIdentifier:@"LogIn"];
	[self.view.window makeKeyAndVisible];
	[self presentViewController:profile animated:NO completion:nil];
    }
}

- (void)update {
    FIRUser *currentUser = [FIRAuth auth].currentUser;
    if (currentUser) {
        NSString *nameVal = [self.name.text isEqual:@""] ? @"👤" : [self.name.text lowercaseString];
        
        FIRFirestore *db = [FIRFirestore firestore];
        [[[db collectionWithPath:@"users"] documentWithPath:currentUser.uid] setData:@{
            @"name": nameVal,
            @"dob": [self getDate:self.yourDOB]
        } merge:YES];
        
	NamesViewController *names = [self.storyboard instantiateViewControllerWithIdentifier:@"Names"];
	[self.view.window makeKeyAndVisible];
	[self presentViewController:names animated:YES completion:nil];
    }
}

-(NSDate*)getDate:(id)sender {
    return [sender date];
}

- (IBAction)valueChanged:(id)sender {
    [self.ageTextField setText:[NSString stringWithFormat:(@"%.02f"), (((([[self.yourDOB date] timeIntervalSinceNow]*-1)/365.25)/24)/60)/60 ]];
}

- (IBAction)editingChanged:(id)sender {
    float age = [self.ageTextField.text floatValue];
    NSDate *birthday = [NSDate dateWithTimeIntervalSinceNow:-(age*365.25*24*60*60)];
    [self.yourDOB setDate:birthday];
}

- (IBAction)didEndOnExit:(id)sender {
    [self.name setAlpha:0];
    [self.ageTextField setAlpha:0];
    [self.yourDOB setAlpha:1];
    [self.name resignFirstResponder];
    [self.ageTextField resignFirstResponder];
    [self.segmentedControl setSelectedSegmentIndex:1];
}

- (IBAction)update:(id)sender {
    [self update];
}

- (IBAction)logOut:(id)sender {
    NSError *error;
    [[FIRAuth auth] signOut:&error];
    LogInViewController *profile = [self.storyboard instantiateViewControllerWithIdentifier:@"LogIn"];
    [self.view.window makeKeyAndVisible];
    [self presentViewController:profile animated:YES completion:nil];
}

- (IBAction)segmentedControl:(id)sender {

    UISegmentedControl *segmentedControl = (UISegmentedControl *) sender;
    NSInteger selectedSegment = segmentedControl.selectedSegmentIndex;

    if (selectedSegment == 0) {
	[self.name setAlpha:1];
	[self.yourDOB setAlpha:0];
	[self.ageTextField setAlpha:0];
	[self.name becomeFirstResponder];
    } else if (selectedSegment == 1){
	[self.name setAlpha:0];
	[self.ageTextField setAlpha:0];
	[self.yourDOB setAlpha:1];
	[self.name resignFirstResponder];
	[self.ageTextField resignFirstResponder];
    } else if (selectedSegment == 2){
	[self.name setAlpha:0];
	[self.ageTextField setAlpha:1];
	[self.yourDOB setAlpha:0];
	[self.ageTextField becomeFirstResponder];
    }
}

@end
