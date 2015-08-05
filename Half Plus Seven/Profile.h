
#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface Profile : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;

@end
