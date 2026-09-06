for file in "NamesViewController.m" "AddViewController.m" "UserViewController.m" "AnswerViewController.m" "ResultsViewController.m" "LogInViewController.m"; do
    sed -i '' -e '/for (UIView \*subview in self.view.subviews) {/i\
\    [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UINavigationBar class]]] setBackgroundImage:[[UIImage alloc] init] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];\
\    [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UINavigationBar class]]] setBackgroundImage:[[UIImage alloc] init] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];\
' "/Users/danielgoodwyn/src/DanielGoodwyn.com backup/halfplusseven/iOS-Half-Plus-Seven/Half Plus Seven/$file"
done
