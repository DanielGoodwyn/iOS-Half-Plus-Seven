for file in "NamesViewController.m" "AddViewController.m" "UserViewController.m" "AnswerViewController.m" "ResultsViewController.m" "LogInViewController.m"; do
    # Replace the buttonAppearance setup to also clear the background image
    sed -i '' -e 's/UIBarButtonItemAppearance \*buttonAppearance = \[\[UIBarButtonItemAppearance alloc\] initWithStyle:UIBarButtonItemStylePlain\];/UIBarButtonItemAppearance *buttonAppearance = [[UIBarButtonItemAppearance alloc] initWithStyle:UIBarButtonItemStylePlain];\
                buttonAppearance.normal.backgroundImage = [[UIImage alloc] init];\
                buttonAppearance.highlighted.backgroundImage = [[UIImage alloc] init];\
                buttonAppearance.focused.backgroundImage = [[UIImage alloc] init];\
                buttonAppearance.disabled.backgroundImage = [[UIImage alloc] init];/' "/Users/danielgoodwyn/src/DanielGoodwyn.com backup/halfplusseven/iOS-Half-Plus-Seven/Half Plus Seven/$file"
done
