#import "SceneDelegate.h"
#import <GoogleSignIn/GoogleSignIn.h>

@interface SceneDelegate ()

@end

@implementation SceneDelegate

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    UIWindowScene *windowScene = (UIWindowScene *)scene;
    if (windowScene) {
        UIWindow *window = [[UIWindow alloc] initWithWindowScene:windowScene];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *rootViewController = [storyboard instantiateInitialViewController];
        
        window.rootViewController = rootViewController;
        self.window = window;
        
        UIColor *appBlue = [UIColor colorWithRed:0.388 green:0.565 blue:0.898 alpha:1.0];
        self.window.backgroundColor = appBlue;
        
        [self.window makeKeyAndVisible];
    }
}

- (void)scene:(UIScene *)scene openURLContexts:(NSSet<UIOpenURLContext *> *)URLContexts {
    UIOpenURLContext *urlContext = URLContexts.anyObject;
    if (urlContext) {
        [GIDSignIn.sharedInstance handleURL:urlContext.URL];
    }
}

- (void)sceneDidDisconnect:(UIScene *)scene {}
- (void)sceneDidBecomeActive:(UIScene *)scene {}
- (void)sceneWillResignActive:(UIScene *)scene {}
- (void)sceneWillEnterForeground:(UIScene *)scene {}
- (void)sceneDidEnterBackground:(UIScene *)scene {}

@end
