for file in "NamesViewController.m" "AddViewController.m" "UserViewController.m" "AnswerViewController.m" "ResultsViewController.m" "LogInViewController.m"; do
    sed -i '' -e '/\[super viewDidLoad\];/a\
\    self.view.backgroundColor = [UIColor colorWithRed:0.388 green:0.565 blue:0.898 alpha:1.0];\
\    for (UIView *subview in self.view.subviews) {\
\        if ([subview isKindOfClass:[UINavigationBar class]]) {\
\            UINavigationBar *navBar = (UINavigationBar *)subview;\
\            [navBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];\
\            navBar.shadowImage = [UIImage new];\
\            navBar.translucent = YES;\
\            navBar.backgroundColor = [UIColor clearColor];\
\            navBar.barTintColor = [UIColor clearColor];\
\            navBar.tintColor = [UIColor whiteColor];\
\            if (@available(iOS 15.0, *)) {\
\                UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];\
\                [appearance configureWithTransparentBackground];\
\                appearance.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};\
\                UIBarButtonItemAppearance *buttonAppearance = [[UIBarButtonItemAppearance alloc] initWithStyle:UIBarButtonItemStylePlain];\
\                buttonAppearance.normal.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};\
\                appearance.buttonAppearance = buttonAppearance;\
\                navBar.standardAppearance = appearance;\
\                navBar.scrollEdgeAppearance = appearance;\
\                navBar.compactAppearance = appearance;\
\            }\
\        }\
\    }\
' "/Users/danielgoodwyn/src/DanielGoodwyn.com backup/halfplusseven/iOS-Half-Plus-Seven/Half Plus Seven/$file"
done
