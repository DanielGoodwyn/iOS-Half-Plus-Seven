// Helper to strip nav bar items and add flat buttons across all VCs
#import <UIKit/UIKit.h>

static inline void flattenNavBar(UIView *parentView) {
    for (UIView *subview in parentView.subviews) {
        if ([subview isKindOfClass:[UINavigationBar class]]) {
            UINavigationBar *navBar = (UINavigationBar *)subview;
            [navBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
            navBar.shadowImage = [UIImage new];
            navBar.translucent = YES;
            navBar.backgroundColor = [UIColor clearColor];
            navBar.barTintColor = [UIColor clearColor];
            navBar.tintColor = [UIColor whiteColor];
            // Remove bar button items so iOS can't draw shapes
            UINavigationItem *topItem = navBar.topItem;
            if (topItem) {
                topItem.leftBarButtonItem = nil;
                topItem.rightBarButtonItem = nil;
                topItem.title = @"";
            }
        }
    }
}

static inline void addFlatButton(UIView *parentView, NSString *title, NSInteger tag, SEL action, id target,
                                  BOOL isLeft, UIFont *font) {
    if ([parentView viewWithTag:tag]) return;
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.tag = tag;
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.titleLabel.font = font;
    btn.contentEdgeInsets = UIEdgeInsetsMake(8, 12, 8, 12);
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    btn.translatesAutoresizingMaskIntoConstraints = NO;
    [parentView addSubview:btn];

    if (@available(iOS 11.0, *)) {
        [btn.topAnchor constraintEqualToAnchor:parentView.safeAreaLayoutGuide.topAnchor].active = YES;
        [btn.heightAnchor constraintEqualToConstant:44].active = YES;
        if (isLeft) {
            [btn.leadingAnchor constraintEqualToAnchor:parentView.safeAreaLayoutGuide.leadingAnchor constant:4].active = YES;
        } else {
            [btn.trailingAnchor constraintEqualToAnchor:parentView.safeAreaLayoutGuide.trailingAnchor constant:-4].active = YES;
        }
    }
}

static inline void addFlatTitle(UIView *parentView, NSString *title, NSInteger tag) {
    if ([parentView viewWithTag:tag]) return;
    UILabel *lbl = [[UILabel alloc] init];
    lbl.tag = tag;
    lbl.text = title;
    lbl.textColor = [UIColor whiteColor];
    lbl.font = [UIFont boldSystemFontOfSize:17];
    lbl.textAlignment = NSTextAlignmentCenter;
    lbl.translatesAutoresizingMaskIntoConstraints = NO;
    [parentView addSubview:lbl];

    if (@available(iOS 11.0, *)) {
        [lbl.centerXAnchor constraintEqualToAnchor:parentView.centerXAnchor].active = YES;
        [lbl.topAnchor constraintEqualToAnchor:parentView.safeAreaLayoutGuide.topAnchor].active = YES;
        [lbl.heightAnchor constraintEqualToConstant:44].active = YES;
    }
}
