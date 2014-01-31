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
    [self.meteorClient addSubscription:@"courses"];
    [self.meteorClient addSubscription:@"currentUser"];

    ObjectiveDDP *ddp = [[ObjectiveDDP alloc] initWithURLString:@"wss://classmate-s.herokuapp.com/websocket" delegate:self.meteorClient];

    
    self.meteorClient.ddp = ddp;
    [self.meteorClient.ddp connectWebSocket];
    

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reportConnection) name:MeteorClientDidConnectNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reportDisconnection) name:MeteorClientDidDisconnectNotification object:nil];
    
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
