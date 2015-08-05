
#import "List.h"
#import "Answer.h"
#import "Profile.h"

@interface List ()

@end

@implementation List

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
        PFQuery *themselfArrayQuery = [PFQuery queryWithClassName:@"Person"];
        [themselfArrayQuery orderByAscending:@"name"];
        [themselfArrayQuery whereKey:@"user" equalTo:user];
        [themselfArrayQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                for (PFObject *object in objects) {
                    [self.people addObject:[[themselfArrayQuery getObjectWithId:object.objectId] objectForKey:@"name"]];
                    [self.DOBs addObject:[[themselfArrayQuery getObjectWithId:object.objectId] objectForKey:@"DOB"]];
                }
            } else {
            }
            if (self.people.count == 0) {
                [self.add setAlpha:1];
            } else {
                [self.add setAlpha:0];
            }
            [self.peopleTableView reloadData];
        }];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    PFUser *currentUser = [PFUser currentUser];
    if (!currentUser) {
        Profile *profile = [self.storyboard instantiateViewControllerWithIdentifier:@"Profile"];
        [self.view.window makeKeyAndVisible];
        [self presentViewController:profile animated:NO completion:nil];
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
    if ([[segue identifier] isEqualToString:@"listToAnswer"]) {
        Answer *answer = [segue destinationViewController];
        NSIndexPath *indexPath = [self.peopleTableView indexPathForSelectedRow];
        [answer setPassedPerson:[self.people objectAtIndex: indexPath.row]];
        [answer setPassedDOB:[self.DOBs objectAtIndex: indexPath.row]];
    }
}

@end
