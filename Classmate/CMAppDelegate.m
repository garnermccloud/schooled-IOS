//
//  CMAppDelegate.m
//  Classmate
//
//  Created by Garner McCloud on 1/21/14.
//  Copyright (c) 2014 Classmate. All rights reserved.
//

#import "CMAppDelegate.h"
#import "MeteorClient.h"
#import "ObjectiveDDP.h"
#import <ObjectiveDDP/MeteorClient.h>


@implementation CMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    

    
    self.meteorClient = [[MeteorClient alloc] init];
    [self.meteorClient addSubscription:@"currentUser"];
    [self.meteorClient addSubscription:@"courses"];
    [self.meteorClient addSubscription:@"tasks"];

    ObjectiveDDP *ddp = [[ObjectiveDDP alloc] initWithURLString:@"wss://schooled.herokuapp.com/websocket" delegate:self.meteorClient];

    
    self.meteorClient.ddp = ddp;
    [self.meteorClient.ddp connectWebSocket];
    

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reportConnection) name:MeteorClientDidConnectNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reportDisconnection) name:MeteorClientDidDisconnectNotification object:nil];
    
#pragma mark Google Analytics
    
    // 1
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    
    // 2
    [[GAI sharedInstance].logger setLogLevel:kGAILogLevelVerbose];
    
    // 3
    [GAI sharedInstance].dispatchInterval = 20;
    
    // 4
    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:@"UA-36616047-3"];
    
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    [tracker set:kGAIAppVersion value:version];
    [tracker set:kGAISampleRate value:@"50.0"];
    
    
    return YES;
}

- (void)reportConnection {
    NSLog(@"================> connected to server!");
}

- (void)reportDisconnection {
    NSLog(@"================> disconnected from server!");
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [self.meteorClient.ddp connectWebSocket];
}

@end
