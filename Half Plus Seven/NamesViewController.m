
#import "NamesViewController.h"
#import "AnswerViewController.h"
#import "LogInViewController.h"
#import "UserViewController.h"

@import Firebase;

@interface NamesViewController ()

@end

@implementation NamesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.people = [[NSMutableArray alloc] init];
    self.DOBs = [[NSMutableArray alloc] init];
    self.documentIDs = [[NSMutableArray alloc] init]; // We'll need document IDs for deletion
}

- (void)viewWillAppear:(BOOL)animated {
    [self setProfileName];
    [self.people removeAllObjects];
    [self.DOBs removeAllObjects];
    [self.documentIDs removeAllObjects];

    FIRUser *user = [FIRAuth auth].currentUser;
    if (user) {
        [self.activityIndicator startAnimating];
        FIRFirestore *db = [FIRFirestore firestore];
        
        // Query both 'user' (legacy iOS) and 'userId' (Web) fields and combine results
        dispatch_group_t group = dispatch_group_create();
        NSMutableArray *allDocs = [NSMutableArray array];
        
        dispatch_group_enter(group);
        [[[db collectionWithPath:@"persons"] queryWhereField:@"user" isEqualTo:user.uid] getDocumentsWithCompletion:^(FIRQuerySnapshot * _Nullable snapshot, NSError * _Nullable error) {
            if (snapshot) [allDocs addObjectsFromArray:snapshot.documents];
            dispatch_group_leave(group);
        }];
        
        dispatch_group_enter(group);
        [[[db collectionWithPath:@"persons"] queryWhereField:@"userId" isEqualTo:user.uid] getDocumentsWithCompletion:^(FIRQuerySnapshot * _Nullable snapshot, NSError * _Nullable error) {
            if (snapshot) [allDocs addObjectsFromArray:snapshot.documents];
            dispatch_group_leave(group);
        }];
        
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            // Deduplicate by document ID
            NSMutableDictionary *uniqueDocs = [NSMutableDictionary dictionary];
            for (FIRDocumentSnapshot *doc in allDocs) {
                uniqueDocs[doc.documentID] = doc;
            }
            NSArray *finalDocs = [uniqueDocs allValues];
            
            NSArray *sortedDocs = [finalDocs sortedArrayUsingComparator:^NSComparisonResult(FIRDocumentSnapshot *doc1, FIRDocumentSnapshot *doc2) {
                NSString *name1 = [doc1.data objectForKey:@"name"];
                NSString *name2 = [doc2.data objectForKey:@"name"];
                if (![name1 isKindOfClass:[NSString class]]) name1 = @"Unknown";
                if (![name2 isKindOfClass:[NSString class]]) name2 = @"Unknown";
                return [name1 caseInsensitiveCompare:name2];
            }];
            
            for (FIRDocumentSnapshot *document in sortedDocs) {
                NSString *name = [document.data objectForKey:@"name"];
                if (![name isKindOfClass:[NSString class]]) name = @"Unknown";
                [self.people addObject:name];
                
                FIRTimestamp *dobTs = [document.data objectForKey:@"dob"];
                NSDate *dob = [dobTs isKindOfClass:[FIRTimestamp class]] ? dobTs.dateValue : [NSDate date];
                [self.DOBs addObject:dob];
                
                [self.documentIDs addObject:document.documentID];
            }
            
            if (self.people.count == 0) {
                [self.add setAlpha:1];
            } else {
                [self.add setAlpha:0];
            }
            [self.activityIndicator stopAnimating];
            [self.peopleTableView reloadData];
        });
    }
}

- (void)viewDidAppear:(BOOL)animated {
    FIRUser *currentUser = [FIRAuth auth].currentUser;
    if (!currentUser) {
	LogInViewController *logIn = [self.storyboard instantiateViewControllerWithIdentifier:@"LogIn"];
    logIn.modalPresentationStyle = UIModalPresentationFullScreen;
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
        FIRFirestore *db = [FIRFirestore firestore];
        NSString *docID = self.documentIDs[indexPath.row];
        [[[db collectionWithPath:@"persons"] documentWithPath:docID] deleteDocument];
        
	[self.people removeObjectAtIndex:indexPath.row];
        [self.DOBs removeObjectAtIndex:indexPath.row];
        [self.documentIDs removeObjectAtIndex:indexPath.row];
	[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
    }
    [self.peopleTableView reloadData];
}

- (void)setProfileName {
    FIRUser *currentUser = [FIRAuth auth].currentUser;
    if (currentUser) {
        FIRFirestore *db = [FIRFirestore firestore];
        [[[db collectionWithPath:@"users"] documentWithPath:currentUser.uid] getDocumentWithCompletion:^(FIRDocumentSnapshot * _Nullable snapshot, NSError * _Nullable error) {
            if (snapshot.exists) {
                NSString *name = [snapshot.data objectForKey:@"name"];
                if ([name isKindOfClass:[NSString class]]) {
                    self.profile.title = [name capitalizedString];
                } else {
                    self.profile.title = @"👤";
                }
            }
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
