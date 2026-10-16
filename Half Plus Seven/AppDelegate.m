#import "AppDelegate.h"
#import <GoogleSignIn/GoogleSignIn.h>
@import Firebase;
@import FirebaseAuth;
@import FirebaseFirestore;

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [FIRApp configure];
    
    UIColor *appBlue = [UIColor colorWithRed:0.388 green:0.565 blue:0.898 alpha:1.0];
    
    if (@available(iOS 15.0, *)) {
        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
        [appearance configureWithOpaqueBackground];
        appearance.backgroundColor = appBlue;
        appearance.shadowColor = [UIColor clearColor]; // flat design
        
        // Remove pill backgrounds from buttons by configuring plain button appearance
        UIBarButtonItemAppearance *buttonAppearance = [[UIBarButtonItemAppearance alloc] initWithStyle:UIBarButtonItemStylePlain];
        buttonAppearance.normal.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
        appearance.buttonAppearance = buttonAppearance;
        
        [UINavigationBar appearance].standardAppearance = appearance;
        [UINavigationBar appearance].scrollEdgeAppearance = appearance;
        [UINavigationBar appearance].compactAppearance = appearance;
    } else {
        [UINavigationBar appearance].barTintColor = appBlue;
        [UINavigationBar appearance].translucent = NO;
        [UINavigationBar appearance].shadowImage = [[UIImage alloc] init];
        [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    }
    
    [UINavigationBar appearance].tintColor = [UIColor whiteColor];
    
    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    return [GIDSignIn.sharedInstance handleURL:url];
}

#pragma mark - UISceneSession lifecycle

- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}

- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
}

@end