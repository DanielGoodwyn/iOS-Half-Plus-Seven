#import "UserViewController.h"
#import "LogInViewController.h"
#import "NamesViewController.h"
#import "NamesViewController+NavBarHelper.h"
#import <GoogleSignIn/GoogleSignIn.h>
@import Firebase;
@import FirebaseAuth;
@import FirebaseFirestore;

@interface UserViewController ()
@property (nonatomic, strong) id<FIRListenerRegistration> userListener;
@end

@implementation UserViewController

@synthesize passedPerson, passedDOB;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.388 green:0.565 blue:0.898 alpha:1.0];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];

    self.name.textColor = [UIColor whiteColor];
    self.name.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Name"
                                                                      attributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:1.0 alpha:0.7]}];
    self.ageTextField.textColor = [UIColor whiteColor];
    self.ageTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Age"
                                                                              attributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:1.0 alpha:0.7]}];

    FIRUser *currentUser = [FIRAuth auth].currentUser;
    if (currentUser) {
        FIRFirestore *db = [FIRFirestore firestore];
        self.userListener = [[[db collectionWithPath:@"users"] documentWithPath:currentUser.uid] addSnapshotListener:^(FIRDocumentSnapshot * _Nullable snapshot, NSError * _Nullable error) {
            if (snapshot.exists) {
                NSString *name = [snapshot.data objectForKey:@"name"];
                NSString *displayName = @"";
                if ([name isKindOfClass:[NSString class]] && [[name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0) {
                    displayName = [name capitalizedString];
                } else if (currentUser.email.length > 0) {
                    displayName = currentUser.email;
                }
                [self.name setText:displayName];
                id dobObj = [snapshot.data objectForKey:@"dob"];
                NSDate *dob = nil;
                if ([dobObj isKindOfClass:[FIRTimestamp class]]) {
                    dob = ((FIRTimestamp *)dobObj).dateValue;
                } else if ([dobObj isKindOfClass:[NSDate class]]) {
                    dob = (NSDate *)dobObj;
                }
                if (dob) {
                    [self.yourDOB setDate:dob];
                    [self.ageTextField setText:[NSString stringWithFormat:(@"%.02f"), (((([[self.yourDOB date] timeIntervalSinceNow]*-1)/60)/60)/24)/365.25 ]];
                }
            }
        }];
    }
    
    if (@available(iOS 14.0, *)) {
        self.yourDOB.preferredDatePickerStyle = UIDatePickerStyleWheels;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.userListener) {
        [self.userListener remove];
        self.userListener = nil;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    flattenNavBar(self.view);
    addFlatTitle(self.view, @"Edit Profile", 9003);
    addFlatButton(self.view, @"✕", 9001, @selector(dismissTapped), self, YES, [UIFont systemFontOfSize:20]);
    addFlatButton(self.view, @"Update", 9002, @selector(updateTapped), self, NO, [UIFont systemFontOfSize:17]);

    if (![self.view viewWithTag:9004]) {
        UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        deleteBtn.tag = 9004;
        [deleteBtn setTitle:@"Delete Account" forState:UIControlStateNormal];
        [deleteBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        deleteBtn.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
        deleteBtn.backgroundColor = [UIColor colorWithRed:0.85 green:0.20 blue:0.20 alpha:0.95];
        deleteBtn.layer.cornerRadius = 10.0;
        deleteBtn.layer.masksToBounds = YES;
        deleteBtn.layer.borderWidth = 1.0;
        deleteBtn.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.4].CGColor;
        [deleteBtn addTarget:self action:@selector(deleteAccountTapped) forControlEvents:UIControlEventTouchUpInside];
        deleteBtn.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:deleteBtn];

        if (@available(iOS 11.0, *)) {
            [deleteBtn.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
            [deleteBtn.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-32].active = YES;
            [deleteBtn.widthAnchor constraintEqualToConstant:220].active = YES;
            [deleteBtn.heightAnchor constraintEqualToConstant:46].active = YES;
        }
    }
}

- (void)deleteAccountTapped {
    [self.view endEditing:YES];
    UIAlertController *confirmAlert = [UIAlertController alertControllerWithTitle:@"Delete Account"
                                                                          message:@"Are you sure you want to permanently delete your account and all saved data? This action cannot be undone."
                                                                   preferredStyle:UIAlertControllerStyleAlert];
    [confirmAlert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [confirmAlert addAction:[UIAlertAction actionWithTitle:@"Delete Account" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self performAccountDeletion];
    }]];
    [self presentViewController:confirmAlert animated:YES completion:nil];
}

- (void)performAccountDeletion {
    if (self.userListener) {
        [self.userListener remove];
        self.userListener = nil;
    }

    FIRUser *currentUser = [FIRAuth auth].currentUser;
    if (!currentUser) {
        [self navigateToLogIn];
        return;
    }

    NSString *uid = currentUser.uid;
    FIRFirestore *db = [FIRFirestore firestore];

    [[[db collectionWithPath:@"persons"] queryWhereField:@"user" isEqualTo:uid] getDocumentsWithCompletion:^(FIRQuerySnapshot * _Nullable snapshot, NSError * _Nullable error) {
        for (FIRDocumentSnapshot *doc in snapshot.documents) {
            [doc.reference deleteDocument];
        }
    }];

    [[[db collectionWithPath:@"persons"] queryWhereField:@"userId" isEqualTo:uid] getDocumentsWithCompletion:^(FIRQuerySnapshot * _Nullable snapshot, NSError * _Nullable error) {
        for (FIRDocumentSnapshot *doc in snapshot.documents) {
            [doc.reference deleteDocument];
        }
    }];

    [[[db collectionWithPath:@"users"] documentWithPath:uid] deleteDocumentWithCompletion:^(NSError * _Nullable firestoreError) {
        [currentUser deleteWithCompletion:^(NSError * _Nullable authError) {
            NSError *signOutError = nil;
            [[FIRAuth auth] signOut:&signOutError];
            [GIDSignIn.sharedInstance signOut];

            UIAlertController *doneAlert = [UIAlertController alertControllerWithTitle:@"Account Deleted"
                                                                               message:@"Your account and all associated data have been permanently deleted."
                                                                        preferredStyle:UIAlertControllerStyleAlert];
            [doneAlert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self navigateToLogIn];
            }]];
            [self presentViewController:doneAlert animated:YES completion:nil];
        }];
    }];
}

- (void)navigateToLogIn {
    LogInViewController *profile = [self.storyboard instantiateViewControllerWithIdentifier:@"LogIn"];
    profile.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.view.window makeKeyAndVisible];
    [self presentViewController:profile animated:YES completion:nil];
}

- (void)dismissTapped {
    NamesViewController *names = [self.storyboard instantiateViewControllerWithIdentifier:@"Names"];
    names.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.view.window makeKeyAndVisible];
    [self presentViewController:names animated:YES completion:nil];
}

- (void)updateTapped {
    [self update];
}

- (void)viewDidAppear:(BOOL)animated {
    FIRUser *currentUser = [FIRAuth auth].currentUser;
    if (!currentUser) {
	LogInViewController *profile = [self.storyboard instantiateViewControllerWithIdentifier:@"LogIn"];
    profile.modalPresentationStyle = UIModalPresentationFullScreen;
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
    names.modalPresentationStyle = UIModalPresentationFullScreen;
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
    [GIDSignIn.sharedInstance signOut];
    LogInViewController *profile = [self.storyboard instantiateViewControllerWithIdentifier:@"LogIn"];
    profile.modalPresentationStyle = UIModalPresentationFullScreen;
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
