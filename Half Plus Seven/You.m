
#import "You.h"
#import "Profile.h"

@interface You ()

@end

@implementation You {
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        [self.logOut setTitle:@"Log out"];
        PFQuery *query= [PFUser query];
        [query whereKey:@"username" equalTo:[[PFUser currentUser]username]];
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error){
            [self.yourName setText:[[query getObjectWithId:object.objectId] objectForKey:@"username"]];
            [self.yourDOB setDate:[[query getObjectWithId:object.objectId] objectForKey:@"DOB"]];
        }];
    } else {
        [self.logOut setTitle:@"Log in"];
    }
}

- (void)viewWillAppear:(BOOL)animated {
}

- (void)viewDidAppear:(BOOL)animated {
    PFUser *currentUser = [PFUser currentUser];
    if (!currentUser) {
        Profile *profile = [self.storyboard instantiateViewControllerWithIdentifier:@"Profile"];
        [self.view.window makeKeyAndVisible];
        [self presentViewController:profile animated:NO completion:nil];
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    textField.text = textField.text.capitalizedString;
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)update {
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        if ([self.yourName.text isEqual: @""]) {
            [currentUser setUsername:@"👤"];
        } else {
            [currentUser setUsername:self.yourName.text];
        }
        [currentUser setValue:[self getDate:self.yourDOB] forKey:@"DOB"];
        [currentUser save];
    }
}

-(NSDate*)getDate:(id)sender {
    return [sender date];
}

- (void) dateChanged:(id)sender{
}

- (IBAction)update:(id)sender {
    [self update];
}

- (IBAction)logOut:(id)sender {
    [PFUser logOut];
    Profile *profile = [self.storyboard instantiateViewControllerWithIdentifier:@"Profile"];
    [self.view.window makeKeyAndVisible];
    [self presentViewController:profile animated:YES completion:nil];
}

@end
