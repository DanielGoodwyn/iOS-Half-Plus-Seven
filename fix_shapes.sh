for file in "NamesViewController.m" "AddViewController.m" "UserViewController.m" "AnswerViewController.m" "ResultsViewController.m" "LogInViewController.m"; do
    sed -i '' -e '/navBar\.tintColor = \[UIColor whiteColor\];/a\
\            for (UINavigationItem *item in navBar.items) {\
\                if (item.leftBarButtonItem && !item.leftBarButtonItem.customView) {\
\                    if (item.leftBarButtonItem.title) {\
\                        UILabel *lbl = [[UILabel alloc] init];\
\                        lbl.text = item.leftBarButtonItem.title;\
\                        lbl.textColor = [UIColor whiteColor];\
\                        lbl.font = [UIFont systemFontOfSize:17];\
\                        [lbl sizeToFit];\
\                        lbl.userInteractionEnabled = NO;\
\                        item.leftBarButtonItem.customView = lbl;\
\                    } else if (item.leftBarButtonItem.image) {\
\                        UIImageView *iv = [[UIImageView alloc] initWithImage:item.leftBarButtonItem.image];\
\                        iv.tintColor = [UIColor whiteColor];\
\                        iv.userInteractionEnabled = NO;\
\                        item.leftBarButtonItem.customView = iv;\
\                    }\
\                }\
\                if (item.rightBarButtonItem && !item.rightBarButtonItem.customView) {\
\                    if (item.rightBarButtonItem.title) {\
\                        UILabel *lbl = [[UILabel alloc] init];\
\                        lbl.text = item.rightBarButtonItem.title;\
\                        lbl.textColor = [UIColor whiteColor];\
\                        lbl.font = [UIFont systemFontOfSize:17];\
\                        [lbl sizeToFit];\
\                        lbl.userInteractionEnabled = NO;\
\                        item.rightBarButtonItem.customView = lbl;\
\                    } else if (item.rightBarButtonItem.image || !item.rightBarButtonItem.title) {\
\                        UILabel *lbl = [[UILabel alloc] init];\
\                        lbl.text = @"+";\
\                        lbl.textColor = [UIColor whiteColor];\
\                        lbl.font = [UIFont systemFontOfSize:24 weight:UIFontWeightRegular];\
\                        [lbl sizeToFit];\
\                        lbl.userInteractionEnabled = NO;\
\                        item.rightBarButtonItem.customView = lbl;\
\                    }\
\                }\
\            }\
' "/Users/danielgoodwyn/src/DanielGoodwyn.com backup/halfplusseven/iOS-Half-Plus-Seven/Half Plus Seven/$file"
done
