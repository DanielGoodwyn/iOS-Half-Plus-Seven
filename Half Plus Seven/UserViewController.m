
#import "UserViewController.h"
#import "LogInViewController.h"
#import "NamesViewController.h"

@interface UserViewController ()

@end

@implementation UserViewController

@synthesize passedPerson, passedDOB;

- (void)viewDidLoad {
    [super viewDidLoad];

    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
	PFQuery *query= [PFUser query];
	[query whereKey:@"username" equalTo:[[PFUser currentUser]username]];
	[query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error){
	    [self.name setText:[[object objectForKey:@"name"] capitalizedString]];
	    [self.yourDOB setDate:[object objectForKey:@"DOB"]];
	    [self.ageTextField setText:[NSString stringWithFormat:(@"%.02f"), (((([[self.yourDOB date] timeIntervalSinceNow]*-1)/365.25)/24)/60)/60 ]];
	}];
    } else {
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [self.name becomeFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated {
    PFUser *currentUser = [PFUser currentUser];
    if (!currentUser) {
	LogInViewController *profile = [self.storyboard instantiateViewControllerWithIdentifier:@"LogIn"];
	[self.view.window makeKeyAndVisible];
	[self presentViewController:profile animated:NO completion:nil];
    }
}

- (void)update {
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
	if ([self.name.text isEqual: @""]) {
	    [currentUser setObject:@"👤" forKey:@"name"];
	} else {
	    [currentUser setObject:[self.name.text lowercaseString] forKey:@"name"];
	}
	[currentUser setValue:[self getDate:self.yourDOB] forKey:@"DOB"];
	[currentUser save];
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
    [PFUser logOut];
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
