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
    
    // Fix legacy storyboard layout by using a UIStackView
    UIView *container = self.email.superview;
    if (container && container != self.view) {
        // Remove old constraints on the container
        [container removeConstraints:container.constraints];
        container.translatesAutoresizingMaskIntoConstraints = NO;
        
        [container.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
        [container.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor constant:-50].active = YES;
        [container.widthAnchor constraintEqualToAnchor:self.view.widthAnchor multiplier:0.8].active = YES;
        
        UIStackView *stack = [[UIStackView alloc] initWithArrangedSubviews:@[self.email, self.password, self.signUpButton]];
        stack.axis = UILayoutConstraintAxisVertical;
        stack.spacing = 20;
        stack.translatesAutoresizingMaskIntoConstraints = NO;
        [container addSubview:stack];
        
        [stack.topAnchor constraintEqualToAnchor:container.topAnchor].active = YES;
        [stack.bottomAnchor constraintEqualToAnchor:container.bottomAnchor].active = YES;
        [stack.leadingAnchor constraintEqualToAnchor:container.leadingAnchor].active = YES;
        [stack.trailingAnchor constraintEqualToAnchor:container.trailingAnchor].active = YES;
        
        [self.email.heightAnchor constraintEqualToConstant:50].active = YES;
        [self.password.heightAnchor constraintEqualToConstant:50].active = YES;
        [self.signUpButton.heightAnchor constraintEqualToConstant:50].active = YES;
    }
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
                @"name": @"👤",
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
