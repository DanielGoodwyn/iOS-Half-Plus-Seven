sed -i '' -e '/for (UINavigationItem \*item in navBar.items) {/i\
\            UIButton *profileBtn = [UIButton buttonWithType:UIButtonTypeCustom];\
\            [profileBtn setTitle:@"👤" forState:UIControlStateNormal];\
\            [profileBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];\
\            [profileBtn addTarget:self action:@selector(profileTapped) forControlEvents:UIControlEventTouchUpInside];\
\            self.profile = [[UIBarButtonItem alloc] initWithCustomView:profileBtn];\
\            navBar.topItem.leftBarButtonItem = self.profile;\
\            UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];\
\            [addBtn setTitle:@"+" forState:UIControlStateNormal];\
\            addBtn.titleLabel.font = [UIFont systemFontOfSize:24 weight:UIFontWeightRegular];\
\            [addBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];\
\            [addBtn addTarget:self action:@selector(addTapped) forControlEvents:UIControlEventTouchUpInside];\
\            navBar.topItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:addBtn];\
' "/Users/danielgoodwyn/src/DanielGoodwyn.com backup/halfplusseven/iOS-Half-Plus-Seven/Half Plus Seven/NamesViewController.m"

cat << 'EOF2' > append_methods.py
import sys
with open("/Users/danielgoodwyn/src/DanielGoodwyn.com backup/halfplusseven/iOS-Half-Plus-Seven/Half Plus Seven/NamesViewController.m", "r") as f:
    lines = f.readlines()

new_lines = []
for line in lines:
    if "@implementation NamesViewController" in line:
        new_lines.append(line)
        new_lines.append("- (void)profileTapped { [self performSegueWithIdentifier:@\"NamesToUser\" sender:nil]; }\n")
        new_lines.append("- (void)addTapped { [self performSegueWithIdentifier:@\"NamesToAdd\" sender:nil]; }\n")
    else:
        new_lines.append(line)

with open("/Users/danielgoodwyn/src/DanielGoodwyn.com backup/halfplusseven/iOS-Half-Plus-Seven/Half Plus Seven/NamesViewController.m", "w") as f:
    f.writelines(new_lines)
EOF2
python3 append_methods.py
chmod +x test_buttons.sh
./test_buttons.sh