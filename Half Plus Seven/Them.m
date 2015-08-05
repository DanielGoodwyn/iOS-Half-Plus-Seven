
#import "Them.h"

@interface Them ()

@end

@implementation Them {
    PFObject *themself;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.themself = [[Person alloc] init];
    [self.theirName setText:@""];
    [self.theirDOB setDate:[NSDate dateWithTimeIntervalSince1970:360936000]];
    [self.theirDOB addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)viewWillAppear:(BOOL)animated {
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
    PFUser *user = [PFUser currentUser];
    if ([self.theirName.text isEqual: @""]) {
        [self.themself name:@"👤"];
    } else {
        [self.themself name:self.theirName.text];
    }
    [self.themself date:[self getDate:self.theirDOB]];
    [self.themself getAgeForDate:self.themself.DOB];
    themself = [PFObject objectWithClassName:@"Person"];
    themself[@"name"] = self.themself.name;
    themself[@"DOB"] = self.themself.DOB;
    themself[@"user"] = user;
    [themself saveInBackground];
}

-(NSDate*)getDate:(id)sender {
    return [sender date];
}

- (void) dateChanged:(id)sender{
}

- (IBAction)update:(id)sender {
    [self update];
}

@end
