
#import "NamesViewController.h"
#import "AnswerViewController.h"
#import "LogInViewController.h"
#import "UserViewController.h"

@import Firebase;

@interface NamesViewController ()

@property NSArray<FIRDocumentSnapshot *> *legacyDocs;
@property NSArray<FIRDocumentSnapshot *> *webDocs;
@property id<FIRListenerRegistration> legacyListener;
@property id<FIRListenerRegistration> webListener;
@end

@implementation NamesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.388 green:0.565 blue:0.898 alpha:1.0];
    for (UIView *subview in self.view.subviews) {
        if ([subview isKindOfClass:[UINavigationBar class]]) {
            UINavigationBar *navBar = (UINavigationBar *)subview;
            [navBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
            navBar.shadowImage = [UIImage new];
            navBar.translucent = YES;
            navBar.backgroundColor = [UIColor clearColor];
            navBar.barTintColor = [UIColor clearColor];
            navBar.tintColor = [UIColor whiteColor];
            if (@available(iOS 15.0, *)) {
                UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
                [appearance configureWithTransparentBackground];
                appearance.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
                UIBarButtonItemAppearance *buttonAppearance = [[UIBarButtonItemAppearance alloc] initWithStyle:UIBarButtonItemStylePlain];
                buttonAppearance.normal.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
                appearance.buttonAppearance = buttonAppearance;
                navBar.standardAppearance = appearance;
                navBar.scrollEdgeAppearance = appearance;
                navBar.compactAppearance = appearance;
            }
        }
    }

    self.people = [[NSMutableArray alloc] init];
    self.DOBs = [[NSMutableArray alloc] init];
    self.documentIDs = [[NSMutableArray alloc] init]; // We'll need document IDs for deletion
    self.legacyDocs = @[];
    self.webDocs = @[];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setProfileName];

    FIRUser *user = [FIRAuth auth].currentUser;
    if (user) {
        [self.activityIndicator startAnimating];
        FIRFirestore *db = [FIRFirestore firestore];
        
        self.legacyListener = [[[db collectionWithPath:@"persons"] queryWhereField:@"user" isEqualTo:user.uid] addSnapshotListener:^(FIRQuerySnapshot * _Nullable snapshot, NSError * _Nullable error) {
            if (snapshot) {
                self.legacyDocs = snapshot.documents;
                [self mergeAndReloadData];
            }
        }];
        
        self.webListener = [[[db collectionWithPath:@"persons"] queryWhereField:@"userId" isEqualTo:user.uid] addSnapshotListener:^(FIRQuerySnapshot * _Nullable snapshot, NSError * _Nullable error) {
            if (snapshot) {
                self.webDocs = snapshot.documents;
                [self mergeAndReloadData];
            }
        }];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.legacyListener) {
        [self.legacyListener remove];
    }
    if (self.webListener) {
        [self.webListener remove];
    }
}

- (void)mergeAndReloadData {
    NSMutableArray *allDocs = [NSMutableArray arrayWithArray:self.legacyDocs];
    [allDocs addObjectsFromArray:self.webDocs];
    
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
    
    [self.people removeAllObjects];
    [self.DOBs removeAllObjects];
    [self.documentIDs removeAllObjects];
    
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
