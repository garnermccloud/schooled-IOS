//
//  CMLoginViewController.m
//  Classmate
//
//  Created by Garner McCloud on 1/22/14.
//  Copyright (c) 2014 Classmate. All rights reserved.
//

#import "CMLoginViewController.h"
#import "CMAppDelegate.h"
#import <ObjectiveDDP/ObjectiveDDP.h>
#import <ObjectiveDDP/MeteorClient.h>
#import "CMCoursesTableViewController.h"


@interface CMLoginViewController ()



@end

@implementation CMLoginViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    CMAppDelegate *cmAppDelegate = (CMAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.meteor = cmAppDelegate.meteorClient;
}

- (void)viewWillAppear:(BOOL)animated {
    [self.meteor addObserver:self
                  forKeyPath:@"websocketReady"
                     options:NSKeyValueObservingOptionNew
                     context:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.meteor removeObserver:self forKeyPath:@"websocketReady"];
}

#pragma mark <NSKeyValueObserving>

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"websocketReady"] && self.meteor.websocketReady) {
        self.connectionStatusText.text = @"Connected to Classmate Server";
        UIImage *image = [UIImage imageNamed: @"green_light.png"];
        [self.connectionStatusLight setImage:image];
    }
}

#pragma mark UI Actions
- (IBAction)didTapLoginButton:(id)sender {
    if (!self.meteor.websocketReady) {
        UIAlertView *notConnectedAlert = [[UIAlertView alloc] initWithTitle:@"Connection Error"
                                                                    message:@"Can't find the Classmate server, try again"
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
        [notConnectedAlert show];
        return;
    }
    NSLog(@"Username = %@, Password = %@", self.username.text, self.password.text);
    
    [self.meteor logonWithUsername:self.username.text password:self.password.text responseCallback:^(NSDictionary *response, NSError *error) {
        if (error) {
            [self handleFailedAuth:error];
            return;
        } else {
            NSLog(@"Successful Login Meter Client = %@", self.meteor);
            id pvc = self.presentingViewController;
            if ([pvc respondsToSelector:NSSelectorFromString(@"meteor")]) {
                NSLog(@"has meteor property");
                [pvc setValue:self.meteor forKey:@"meteor"];
            }
            [pvc dismissViewControllerAnimated:YES completion:nil];
        }
        
    }];
}


#pragma mark - Internal

- (void)handleSuccessfulAuth {
    // ListViewController *controller = [[ListViewController alloc] initWithNibName:@"ListViewController"
    //bundle:nil
    //meteor:self.meteor];
    //  controller.userId = self.meteor.userId;
    //  [self.navigationController pushViewController:controller animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Login"]) {
        if ([segue.destinationViewController isKindOfClass:[CMCoursesTableViewController class]]) {
            CMCoursesTableViewController *cmcTVC = (CMCoursesTableViewController *)segue.destinationViewController;
            cmcTVC.meteor = self.meteor;
            cmcTVC.userId = self.meteor.userId;
        }
    }
}

- (void)handleFailedAuth:(NSError *)error {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Classmate"
                                                    message:[error localizedDescription]
                                                   delegate:nil
                                          cancelButtonTitle:@"Try Again"
                                          otherButtonTitles:nil];
    [alert show];
}



@end