#import "LogInViewController.h"
#import "NamesViewController.h"
#import "UserViewController.h"
@import Firebase;

@interface LogInViewController ()

@end

@implementation LogInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.388 green:0.565 blue:0.898 alpha:1.0];
    [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UINavigationBar class]]] setBackgroundImage:[[UIImage alloc] init] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UINavigationBar class]]] setBackgroundImage:[[UIImage alloc] init] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];

    for (UIView *subview in self.view.subviews) {
        if ([subview isKindOfClass:[UINavigationBar class]]) {
            UINavigationBar *navBar = (UINavigationBar *)subview;
            [navBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
            navBar.shadowImage = [UIImage new];
            navBar.translucent = YES;
            navBar.backgroundColor = [UIColor clearColor];
            navBar.barTintColor = [UIColor clearColor];
            navBar.tintColor = [UIColor whiteColor];
            for (UINavigationItem *item in navBar.items) {
                if (item.leftBarButtonItem && !item.leftBarButtonItem.customView) {
                    if (item.leftBarButtonItem.title) {
                        UILabel *lbl = [[UILabel alloc] init];
                        lbl.text = item.leftBarButtonItem.title;
                        lbl.textColor = [UIColor whiteColor];
                        lbl.font = [UIFont systemFontOfSize:17];
                        [lbl sizeToFit];
                        lbl.userInteractionEnabled = NO;
                        item.leftBarButtonItem.customView = lbl;
                    } else if (item.leftBarButtonItem.image) {
                        UIImageView *iv = [[UIImageView alloc] initWithImage:item.leftBarButtonItem.image];
                        iv.tintColor = [UIColor whiteColor];
                        iv.userInteractionEnabled = NO;
                        item.leftBarButtonItem.customView = iv;
                    }
                }
                if (item.rightBarButtonItem && !item.rightBarButtonItem.customView) {
                    if (item.rightBarButtonItem.title) {
                        UILabel *lbl = [[UILabel alloc] init];
                        lbl.text = item.rightBarButtonItem.title;
                        lbl.textColor = [UIColor whiteColor];
                        lbl.font = [UIFont systemFontOfSize:17];
                        [lbl sizeToFit];
                        lbl.userInteractionEnabled = NO;
                        item.rightBarButtonItem.customView = lbl;
                    } else if (item.rightBarButtonItem.image || !item.rightBarButtonItem.title) {
                        UILabel *lbl = [[UILabel alloc] init];
                        lbl.text = @"+";
                        lbl.textColor = [UIColor whiteColor];
                        lbl.font = [UIFont systemFontOfSize:24 weight:UIFontWeightRegular];
                        [lbl sizeToFit];
                        lbl.userInteractionEnabled = NO;
                        item.rightBarButtonItem.customView = lbl;
                    }
                }
            }

            if (@available(iOS 15.0, *)) {
                UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
                [appearance configureWithTransparentBackground];
                appearance.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
                UIBarButtonItemAppearance *buttonAppearance = [[UIBarButtonItemAppearance alloc] initWithStyle:UIBarButtonItemStylePlain];
                buttonAppearance.normal.backgroundImage = [[UIImage alloc] init];
                buttonAppearance.highlighted.backgroundImage = [[UIImage alloc] init];
                buttonAppearance.focused.backgroundImage = [[UIImage alloc] init];
                buttonAppearance.disabled.backgroundImage = [[UIImage alloc] init];
                buttonAppearance.normal.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
                appearance.buttonAppearance = buttonAppearance;
                navBar.standardAppearance = appearance;
                navBar.scrollEdgeAppearance = appearance;
                navBar.compactAppearance = appearance;
            }
        }
    }

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
                user.modalPresentationStyle = UIModalPresentationFullScreen;
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
            names.modalPresentationStyle = UIModalPresentationFullScreen;
            [self.view.window makeKeyAndVisible];
            [self presentViewController:names animated:YES completion:nil];
        } else {
            NSString *errorString = error.localizedDescription;
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:errorString preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
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
