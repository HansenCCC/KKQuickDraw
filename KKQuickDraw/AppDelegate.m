//
//  AppDelegate.m
//  KKQuickDraw
//
//  Created by Hansen on 5/17/21.
//

#import "AppDelegate.h"
#import "KKWKURLSchemeHandler.h"

@interface AppDelegate ()

@end

@implementation AppDelegate
@synthesize window;
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [KKWKURLSchemeHandler setupHTMLCache];
    NSLog(@"缓存路径\n\n%@\n\n",[KKWKURLSchemeHandler filePath]);
    return YES;
}
@end
