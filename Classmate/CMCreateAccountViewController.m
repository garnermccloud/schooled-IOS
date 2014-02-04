//
//  CMCreateAccountViewController.m
//  Classmate
//
//  Created by Garner McCloud on 1/28/14.
//  Copyright (c) 2014 Classmate. All rights reserved.
//

#import "CMCreateAccountViewController.h"
#import "CMAppDelegate.h"
#import <ObjectiveDDP/ObjectiveDDP.h>
#import <ObjectiveDDP/MeteorClient.h>
#import "CMCoursesTableViewController.h"

@interface CMCreateAccountViewController ()

@end

@implementation CMCreateAccountViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    CMAppDelegate *cmAppDelegate = (CMAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.meteor = cmAppDelegate.meteorClient;
    UITapGestureRecognizer *tapScroll = [[UITapGestureRecognizer alloc]initWithTarget:self     action:@selector(tapped)];
    tapScroll.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapScroll];
}

- (void) tapped
{
    [self.view endEditing:YES];
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
- (IBAction)didTapCreateButton:(id)sender {
    if (!self.meteor.websocketReady) {
        UIAlertView *notConnectedAlert = [[UIAlertView alloc] initWithTitle:@"Connection Error"
                                                                    message:@"Can't find the Classmate server, try again"
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
        [notConnectedAlert show];
        return;
    }
    
    [self.meteor callMethodName:@"createAccount" parameters:@[self.email.text, self.password.text] responseCallback:^(NSDictionary *response, NSError *error) {
        if (error) {
            [self handleFailedAuth:error];
            return;
        }
        else {
            NSLog(@"Successful Create Meteor account");
            [self.meteor logonWithUsername:self.email.text password:self.password.text responseCallback:^(NSDictionary *response, NSError *error) {
                if (error) {
                    [self handleFailedAuth:error];
                    return;
                } else {
                    NSLog(@"Successful Login Meteor Client = %@", self.meteor);
                    id pvc = self.presentingViewController;
                    if ([pvc respondsToSelector:NSSelectorFromString(@"meteor")]) {
                        NSLog(@"has meteor property");
                        [pvc setValue:self.meteor forKey:@"meteor"];
                    }
                    [pvc dismissViewControllerAnimated:YES completion:nil];
                }
                
            }];
        }
    }];
    
    
}


#pragma mark - Internal


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
    if (error) {
        NSString *errorMessage;
        if ([[error localizedDescription] isKindOfClass:[NSString class]])
        {
            errorMessage = [error localizedDescription];
        } else {
            id errorId = [error localizedDescription];
            NSDictionary *errorDictionary = (NSDictionary *)errorId;
            errorMessage = errorDictionary[@"reason"];
        }
        NSLog(@"Error = %@", error);
        //NSDictionary *errorDictionary = (NSDictionary *)errorId;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:errorMessage
                                                       delegate:nil
                                              cancelButtonTitle:@"Try Again"
                                              otherButtonTitles:nil];
        [alert show];
        
    }
}




@end
