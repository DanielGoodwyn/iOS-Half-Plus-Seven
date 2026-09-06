import re

with open("Half Plus Seven/NamesViewController.m", "r") as f:
    content = f.read()

# First, remove the old customView injection loop we added earlier
content = re.sub(r'for \(UIView \*subview in self\.view\.subviews\) \{.*?\}\n        \}', '', content, flags=re.DOTALL)

# Add our foolproof manual custom buttons at the end of viewDidLoad
new_vdl = """
    // Foolproof Custom UIButtons to completely defeat iOS accessibility button shapes
    for (UIView *subview in self.view.subviews) {
        if ([subview isKindOfClass:[UINavigationBar class]]) {
            UINavigationBar *navBar = (UINavigationBar *)subview;
            [navBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
            navBar.shadowImage = [UIImage new];
            navBar.translucent = YES;
            navBar.backgroundColor = [UIColor clearColor];
            navBar.barTintColor = [UIColor clearColor];
            
            UINavigationItem *topItem = navBar.topItem;
            if (topItem) {
                // Left Button (Profile)
                UIButton *profileBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                [profileBtn setTitle:@"👤" forState:UIControlStateNormal];
                [profileBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                profileBtn.titleLabel.font = [UIFont systemFontOfSize:17];
                [profileBtn addTarget:self action:@selector(profileBtnTapped) forControlEvents:UIControlEventTouchUpInside];
                [profileBtn sizeToFit];
                self.profile = [[UIBarButtonItem alloc] initWithCustomView:profileBtn];
                topItem.leftBarButtonItem = self.profile;
                
                // Right Button (Add)
                UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                [addBtn setTitle:@"+" forState:UIControlStateNormal];
                [addBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                addBtn.titleLabel.font = [UIFont systemFontOfSize:30 weight:UIFontWeightLight];
                [addBtn addTarget:self action:@selector(addBtnTapped) forControlEvents:UIControlEventTouchUpInside];
                [addBtn sizeToFit];
                topItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:addBtn];
            }
        }
    }
"""

content = content.replace("self.people = [[NSMutableArray alloc] init];", new_vdl + "\n    self.people = [[NSMutableArray alloc] init];")

# Add the action methods
methods = """
- (void)profileBtnTapped {
    [self performSegueWithIdentifier:@"NamesToUser" sender:nil];
}
- (void)addBtnTapped {
    [self performSegueWithIdentifier:@"NamesToAdd" sender:nil];
}
"""
content = content.replace("@end", methods + "\n@end")

# Fix setProfileName to update our custom button correctly
content = content.replace("((UILabel *)self.profile.customView).text = self.profile.title;", "[(UIButton *)self.profile.customView setTitle:self.profile.title forState:UIControlStateNormal];")
content = content.replace("[self.profile.customView isKindOfClass:[UILabel class]]", "[self.profile.customView isKindOfClass:[UIButton class]]")

with open("Half Plus Seven/NamesViewController.m", "w") as f:
    f.write(content)

