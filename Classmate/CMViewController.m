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
    self.navigationItem.title = nil;
    [self reloadUI];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveUpdate:)
                                                 name:@"added"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveUpdate:)
                                                 name:@"removed"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveUpdate:)
                                                 name:@"changed"
                                               object:nil];
}

- (void)didReceiveUpdate:(NSNotification *)notification {
    [self reloadUI];
}

- (void)reloadUI
{
    
}





@end
