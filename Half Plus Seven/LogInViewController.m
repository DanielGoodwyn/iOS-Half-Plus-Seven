#import "LogInViewController.h"
#import "NamesViewController.h"
#import "UserViewController.h"
@import Firebase;

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
    NSString *emailText = [self.email.text lowercaseString];
    NSString *passwordText = self.password.text;

    [[FIRAuth auth] createUserWithEmail:emailText
                               password:passwordText
                             completion:^(FIRAuthDataResult * _Nullable authResult, NSError * _Nullable error) {
        if (!error) {
            // Write DOB to Firestore users collection
            FIRFirestore *db = [FIRFirestore firestore];
            [[[db collectionWithPath:@"users"] documentWithPath:authResult.user.uid] setData:@{
                @"email": emailText,
                @"dob": [NSDate dateWithTimeIntervalSince1970:595857600]
            } completion:^(NSError * _Nullable error) {
                UserViewController *user = [self.storyboard instantiateViewControllerWithIdentifier:@"User"];
                [self.view.window makeKeyAndVisible];
                [self presentViewController:user animated:YES completion:nil];
            }];
        } else {
            [self logIn];
        }
    }];
}

- (void)logIn{
    NSString *emailText = [self.email.text lowercaseString];
    NSString *passwordText = self.password.text;
    
    [[FIRAuth auth] signInWithEmail:emailText
                           password:passwordText
                         completion:^(FIRAuthDataResult * _Nullable authResult, NSError * _Nullable error) {
        if (authResult) {
            NamesViewController *names = [self.storyboard instantiateViewControllerWithIdentifier:@"Names"];
            [self.view.window makeKeyAndVisible];
            [self presentViewController:names animated:YES completion:nil];
        } else {
            NSString *errorString = error.localizedDescription;
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
