
#import "LogInViewController.h"
#import "NamesViewController.h"
#import "UserViewController.h"

@interface LogInViewController ()

@end

@implementation LogInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.email becomeFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated {
    [[self.signUpButton layer] setBorderWidth:1.5f];
    [[self.signUpButton layer] setBorderColor:[UIColor whiteColor].CGColor];
}

- (IBAction)signUp:(id)sender {
    [self signUp];
}

- (void)signUp{
    PFUser *user = [PFUser user];
    user.username = [self.email.text lowercaseString];
    user.password = self.password.text;
    user.email = [self.email.text lowercaseString];

    user[@"DOB"] = [NSDate dateWithTimeIntervalSince1970:595857600];

    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
	if (!error) {
	    UserViewController *user = [self.storyboard instantiateViewControllerWithIdentifier:@"User"];
	    [self.view.window makeKeyAndVisible];
	    [self presentViewController:user animated:YES completion:nil];
	} else {
	    [self logIn];
	}
    }];
}

- (void)logIn{
    [PFUser logInWithUsernameInBackground:[self.email.text lowercaseString] password:self.password.text block:^(PFUser *user, NSError *error) {
	if (user) {
	    NamesViewController *names = [self.storyboard instantiateViewControllerWithIdentifier:@"Names"];
	    [self.view.window makeKeyAndVisible];
	    [self presentViewController:names animated:YES completion:nil];
	} else {
	    NSString *errorString = [error userInfo][@"error"];
	    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:errorString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	    [alert show];
	}
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSInteger nextTag = textField.tag + 1;
    UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
    if (nextResponder) {
	[nextResponder becomeFirstResponder];
    } else {
	[textField resignFirstResponder];
	[self signUp];
    }
    return NO;
}

@end
