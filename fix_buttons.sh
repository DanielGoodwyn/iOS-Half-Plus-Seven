for file in "NamesViewController.m" "AddViewController.m" "UserViewController.m" "AnswerViewController.m" "ResultsViewController.m" "LogInViewController.m"; do
    sed -i '' -e '/for (UIView \*subview in self.view.subviews) {/i\
\    // Replace standard bar button items with custom UIButton to bypass iOS pill/circle shapes completely\
\    for (UINavigationItem *item in navBar.items) {\
\        if (item.leftBarButtonItem) {\
\            UIButton *customLeftBtn = [UIButton buttonWithType:UIButtonTypeCustom];\
\            [customLeftBtn setTitle:item.leftBarButtonItem.title ?: @"" forState:UIControlStateNormal];\
\            if (item.leftBarButtonItem.image) [customLeftBtn setImage:item.leftBarButtonItem.image forState:UIControlStateNormal];\
\            [customLeftBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];\
\            customLeftBtn.tintColor = [UIColor whiteColor];\
\            [customLeftBtn addTarget:item.leftBarButtonItem.target action:item.leftBarButtonItem.action forControlEvents:UIControlEventTouchUpInside];\
\            item.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:customLeftBtn];\
\        }\
\        if (item.rightBarButtonItem) {\
\            UIButton *customRightBtn = [UIButton buttonWithType:UIButtonTypeCustom];\
\            [customRightBtn setTitle:item.rightBarButtonItem.title ?: @"" forState:UIControlStateNormal];\
\            if (item.rightBarButtonItem.image) [customRightBtn setImage:item.rightBarButtonItem.image forState:UIControlStateNormal];\
\            // If it was a system add button, it might not have an image property directly. \
\            if (!item.rightBarButtonItem.title && !item.rightBarButtonItem.image) {\
\                [customRightBtn setTitle:@"+" forState:UIControlStateNormal];\
\                customRightBtn.titleLabel.font = [UIFont systemFontOfSize:24 weight:UIFontWeightRegular];\
\            }\
\            [customRightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];\
\            customRightBtn.tintColor = [UIColor whiteColor];\
\            [customRightBtn addTarget:item.rightBarButtonItem.target action:item.rightBarButtonItem.action forControlEvents:UIControlEventTouchUpInside];\
\            item.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:customRightBtn];\
\        }\
\    }\
' "/Users/danielgoodwyn/src/DanielGoodwyn.com backup/halfplusseven/iOS-Half-Plus-Seven/Half Plus Seven/$file"
done
