sed -i '' -e 's/self.profile.title = \[name capitalizedString\];/self.profile.title = [name capitalizedString];\
                    if ([self.profile.customView isKindOfClass:[UILabel class]]) {\
                        ((UILabel *)self.profile.customView).text = self.profile.title;\
                        [self.profile.customView sizeToFit];\
                    }/' "/Users/danielgoodwyn/src/DanielGoodwyn.com backup/halfplusseven/iOS-Half-Plus-Seven/Half Plus Seven/NamesViewController.m"

sed -i '' -e 's/self.profile.title = @"👤";/self.profile.title = @"👤";\
                    if ([self.profile.customView isKindOfClass:[UILabel class]]) {\
                        ((UILabel *)self.profile.customView).text = self.profile.title;\
                        [self.profile.customView sizeToFit];\
                    }/' "/Users/danielgoodwyn/src/DanielGoodwyn.com backup/halfplusseven/iOS-Half-Plus-Seven/Half Plus Seven/NamesViewController.m"

