
#import "Profile.h"
#import "List.h"
#import "You.h"

@interface Profile ()

@end

@implementation Profile

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)signUp:(id)sender {
    [self signUp];
}

- (IBAction)logIn:(id)sender {
    [self logIn];
}

NSString *signUpError;

- (void)signUp{
    PFUser *user = [PFUser user];
    user.username = self.username.text;
    user.password = self.password.text;
    user.email = self.email.text;
    
    user[@"DOB"] = [NSDate dateWithTimeIntervalSince1970:595857600];
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            You *you = [self.storyboard instantiateViewControllerWithIdentifier:@"You"];
            [self.view.window makeKeyAndVisible];
            [self presentViewController:you animated:YES completion:nil];
        } else {            
            [self logIn];
        }
    }];
}

- (void)logIn{
    [PFUser logInWithUsernameInBackground:self.username.text password:self.password.text block:^(PFUser *user, NSError *error) {
        if (user) {
            List *list = [self.storyboard instantiateViewControllerWithIdentifier:@"List"];
            [self.view.window makeKeyAndVisible];
            [self presentViewController:list animated:YES completion:nil];
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
