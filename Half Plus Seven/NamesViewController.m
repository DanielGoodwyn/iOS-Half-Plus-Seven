
#import "NamesViewController.h"
#import "AnswerViewController.h"
#import "LogInViewController.h"
#import "UserViewController.h"

@interface NamesViewController ()

@end

@implementation NamesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.people = [[NSMutableArray alloc] init];
    self.DOBs = [[NSMutableArray alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
    [self setProfileName];
    [self.people removeAllObjects];
    [self.DOBs removeAllObjects];

    PFUser *user = [PFUser currentUser];
    if (user) {
	[self.activityIndicator startAnimating];
	PFQuery *themselfArrayQuery = [PFQuery queryWithClassName:@"Person"];
	[themselfArrayQuery orderByAscending:@"name"];
	[themselfArrayQuery whereKey:@"user" equalTo:user];
	[themselfArrayQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
	    if (!error) {
		for (PFObject *object in objects) {
		    [self.people addObject:[object objectForKey:@"name"]];
		    [self.DOBs addObject:[object objectForKey:@"DOB"]];
		}
	    } else {
	    }
	    if (self.people.count == 0) {
		[self.add setAlpha:1];
	    } else {
		[self.add setAlpha:0];
	    }
	    [self.activityIndicator stopAnimating];
	    [self.peopleTableView reloadData];
	}];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    PFUser *currentUser = [PFUser currentUser];
    if (!currentUser) {
	LogInViewController *logIn = [self.storyboard instantiateViewControllerWithIdentifier:@"LogIn"];
	[self.view.window makeKeyAndVisible];
	[self presentViewController:logIn animated:NO completion:nil];
    }
}

#pragma mark Quizzes Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.people count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:@"personCell"];
    if (cell == nil){
	cell = [[UITableViewCell alloc] initWithFrame:CGRectZero];
    }
    cell.textLabel.text = [self.people objectAtIndex:indexPath.row];
    if (indexPath.row % 2) {
	UIColor * color = [UIColor colorWithRed:0.40 green:0.60 blue:0.90 alpha:1.0];
	[cell.textLabel.superview setBackgroundColor: color];
	[cell.textLabel setBackgroundColor: color];
    } else {
	UIColor * color = [UIColor colorWithRed:0.30 green:0.50 blue:0.80 alpha:1.0];
	[cell.textLabel.superview setBackgroundColor: color];
	[cell.textLabel setBackgroundColor: color];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
	PFQuery *themselfArrayQuery = [PFQuery queryWithClassName:@"Person"];
	[themselfArrayQuery whereKey:@"name" equalTo:self.people[indexPath.row]];
	[themselfArrayQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
	    if (!error) {
		for (PFObject *object in objects) {
		    [object deleteInBackground];
		}
	    } else {
	    }
	}];
	[self.people removeObjectAtIndex:indexPath.row];
	[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
    }
    [self.peopleTableView reloadData];
}

- (void)setProfileName {
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
	PFQuery *query= [PFUser query];
	[query whereKey:@"username" equalTo:[[PFUser currentUser]username]];
	[query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error){
	    self.profile.title = [[currentUser objectForKey:@"name"] capitalizedString];
	}];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"NamesToAnswer"]) {
	AnswerViewController *answer = [segue destinationViewController];
	NSIndexPath *indexPath = [self.peopleTableView indexPathForSelectedRow];
	[answer setPassedPerson:[self.people objectAtIndex: indexPath.row]];
	[answer setPassedDOB:[self.DOBs objectAtIndex: indexPath.row]];
    } else if ([[segue identifier] isEqualToString:@"NamesToUser"]) {
	UserViewController *user = [segue destinationViewController];
	NSIndexPath *indexPath = [self.peopleTableView indexPathForSelectedRow];
	[user setPassedPerson:[self.people objectAtIndex: indexPath.row]];
    }
}

@end
