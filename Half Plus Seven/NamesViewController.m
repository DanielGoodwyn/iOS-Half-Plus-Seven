
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
    self.people = [[NSMutableArray alloc] init];
    self.DOBs = [[NSMutableArray alloc] init];
    self.documentIDs = [[NSMutableArray alloc] init];
    self.legacyDocs = @[];
    self.webDocs = @[];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // Find the nav bar, make it transparent, and REMOVE its bar button items entirely.
    // iOS draws button shapes on UIBarButtonItem no matter what — the only fix is to not use them.
    for (UIView *subview in self.view.subviews) {
        if ([subview isKindOfClass:[UINavigationBar class]]) {
            UINavigationBar *navBar = (UINavigationBar *)subview;
            [navBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
            navBar.shadowImage = [UIImage new];
            navBar.translucent = YES;
            navBar.backgroundColor = [UIColor clearColor];
            navBar.barTintColor = [UIColor clearColor];
            navBar.tintColor = [UIColor whiteColor];
            // Remove the storyboard bar button items so iOS can't draw shapes on them
            navBar.topItem.leftBarButtonItem = nil;
            navBar.topItem.rightBarButtonItem = nil;
            navBar.topItem.title = @""; // Hide built-in title; we render our own
        }
    }

    // Add plain UIButtons and title label directly to self.view.
    // Tag them so we only add once.
    if (![self.view viewWithTag:9001]) {
        // Profile button (top-left)
        UIButton *profileBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        profileBtn.tag = 9001;
        [profileBtn setTitle:@"👤" forState:UIControlStateNormal];
        [profileBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        profileBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        profileBtn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        profileBtn.contentEdgeInsets = UIEdgeInsetsMake(8, 12, 8, 4);
        [profileBtn addTarget:self action:@selector(profileBtnTapped) forControlEvents:UIControlEventTouchUpInside];
        profileBtn.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:profileBtn];

        // Title label (centered)
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.tag = 9003;
        titleLabel.text = @"½ + 7";
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.font = [UIFont boldSystemFontOfSize:17];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:titleLabel];

        // Add button (top-right)
        UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        addBtn.tag = 9002;
        [addBtn setTitle:@"+" forState:UIControlStateNormal];
        [addBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        addBtn.titleLabel.font = [UIFont systemFontOfSize:28 weight:UIFontWeightLight];
        addBtn.contentEdgeInsets = UIEdgeInsetsMake(4, 12, 4, 12);
        [addBtn addTarget:self action:@selector(addBtnTapped) forControlEvents:UIControlEventTouchUpInside];
        addBtn.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:addBtn];

        // Layout: profile | title (centered) | add
        // Profile truncates if name is long; title always stays centered.
        if (@available(iOS 11.0, *)) {
            [profileBtn.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor constant:4].active = YES;
            [profileBtn.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor].active = YES;
            [profileBtn.heightAnchor constraintEqualToConstant:44].active = YES;

            [titleLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
            [titleLabel.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor].active = YES;
            [titleLabel.heightAnchor constraintEqualToConstant:44].active = YES;

            [addBtn.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor constant:-4].active = YES;
            [addBtn.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor].active = YES;
            [addBtn.heightAnchor constraintEqualToConstant:44].active = YES;

            // Profile can't overlap the title
            [profileBtn.trailingAnchor constraintLessThanOrEqualToAnchor:titleLabel.leadingAnchor constant:-4].active = YES;
            // Add can't overlap the title
            [addBtn.leadingAnchor constraintGreaterThanOrEqualToAnchor:titleLabel.trailingAnchor constant:4].active = YES;

            // Profile button shrinks first (lower compression resistance)
            [profileBtn setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
            [titleLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
            [addBtn setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        }
    }

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
                UIButton *profileBtn = (UIButton *)[self.view viewWithTag:9001];
                if ([name isKindOfClass:[NSString class]]) {
                    [profileBtn setTitle:[name capitalizedString] forState:UIControlStateNormal];
                } else {
                    [profileBtn setTitle:@"👤" forState:UIControlStateNormal];
                }
                [profileBtn sizeToFit];
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

- (void)profileBtnTapped {
    [self performSegueWithIdentifier:@"NamesToUser" sender:nil];
}

- (void)addBtnTapped {
    [self performSegueWithIdentifier:@"NamesToAdd" sender:nil];
}

@end
