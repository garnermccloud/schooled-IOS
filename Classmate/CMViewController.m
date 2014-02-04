//
//  CMViewController.m
//  Classmate
//
//  Created by Garner McCloud on 1/23/14.
//  Copyright (c) 2014 Classmate. All rights reserved.
//

#import "CMViewController.h"
#import <ObjectiveDDP/BSONIdGenerator.h>
#import "CMLoginViewController.h"
#import "CMAppDelegate.h"

@interface CMViewController ()

@end

@implementation CMViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    CMAppDelegate *cmAppDelegate = (CMAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.meteor = cmAppDelegate.meteorClient;
    if (!self.meteor.userId) {
        [self performSegueWithIdentifier:@"Login" sender:self];
    }
    
}

-(void)viewWillAppear:(BOOL)animated
{
    if (self.meteor.authState == 3) {
        [self performSegueWithIdentifier:@"Login" sender:self];
    }
    NSLog(@"Meteor Client = %@", self.meteor);
    self.navigationItem.title = nil;
    [self loadSubscriptions];
    [self reloadUI];
    
     
     [[NSNotificationCenter defaultCenter] addObserver:self
     selector:@selector(didReceiveUpdate:)
     name:@"tasks_added"
     object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self
     selector:@selector(didReceiveUpdate:)
     name:@"tasks_removed"
     object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self
     selector:@selector(didReceiveUpdate:)
     name:@"tasks_changed"
     object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveUpdate:)
                                                 name:@"users_added"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveUpdate:)
                                                 name:@"users_removed"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveUpdate:)
                                                 name:@"users_changed"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveUpdate:)
                                                 name:MeteorClientDidConnectNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    
    [self reloadUI];
}




- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadSubscriptions {
  //  [self.meteor addSubscription:@"currentUser"];
  //  [self.meteor addSubscription:@"courses"];
}

- (void)didReceiveUpdate:(NSNotification *)notification {
    //[self loadSubscriptions];
    [self reloadUI];
}

- (void)reloadUI
{
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}





@end
