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
@property (strong, nonatomic) IBOutlet UIView *createAccountView;
@property (strong, nonatomic) IBOutlet UIView *loginView;




@end

@implementation CMLoginViewController


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
    [super viewWillAppear:YES];
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
    NSLog(@"tapped login button");
    
    [self.meteor logonWithUsername:self.loginEmail.text password:self.loginPassword.text responseCallback:^(NSDictionary *response, NSError *error) {
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

- (IBAction)didTapSignUpNowButton:(id)sender
{
    self.view = self.createAccountView;
    
    UITapGestureRecognizer *tapScroll = [[UITapGestureRecognizer alloc]initWithTarget:self     action:@selector(tapped)];
    tapScroll.cancelsTouchesInView = NO;
    
    [self.view addGestureRecognizer:tapScroll];
}

- (IBAction)didTapGoToLoginButton:(id)sender
{
    self.view = self.loginView;
    
    UITapGestureRecognizer *tapScroll = [[UITapGestureRecognizer alloc]initWithTarget:self     action:@selector(tapped)];
    tapScroll.cancelsTouchesInView = NO;
    
    [self.view addGestureRecognizer:tapScroll];
}

- (void)didTapCreateAccountButton:(id)sender
{
     if(!([self validateEmailWithString:self.createEmail.text] &&
       [self validateEmailWithString:self.confirmEmail.text] && (self.confirmEmail.text.length > 5)))
    {
        // user entered invalid email address
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Enter a valid email address." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
        return;
    } else if (![self.createEmail.text isEqualToString:self.confirmEmail.text]) {
        UIAlertView *emailMismatch = [[UIAlertView alloc] initWithTitle:@"Email Mismatch"
                                                                    message:@"Please confirm your email address and try again"
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
        [emailMismatch show];
        return;

    } else if (self.createPassword.text.length < 6) {
        // user entered invalid  password
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Password must be at least 6 characters" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
        return;
    } else if (![self.createPassword.text isEqualToString:self.confirmPassword.text]) {
        UIAlertView *passwordMistmatch = [[UIAlertView alloc] initWithTitle:@"Password Mismatch"
                                                                    message:@"Please confirm your password and try again"
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
        [passwordMistmatch show];
        return;
        
    } else if (!self.meteor.websocketReady) {
        UIAlertView *notConnectedAlert = [[UIAlertView alloc] initWithTitle:@"Connection Error"
                                                                    message:@"Can't find the Classmate server, try again"
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
        [notConnectedAlert show];
        return;
    } else {
        NSMutableDictionary *user = [[NSMutableDictionary alloc] init];
        [user setValue:self.createEmail.text forKeyPath:@"email"];
        [user setValue:self.createPassword.text forKeyPath:@"password"];

        [self.meteor callMethodName:@"createUser" parameters:@[user] responseCallback:^(NSDictionary *response, NSError *error) {
            NSLog(@"response = %@", response);
            if (error) {
                id errorId = [error localizedDescription];
                NSDictionary *errorDictionary = (NSDictionary *)errorId;
                NSLog(@"error = %@", errorDictionary);
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:errorDictionary[@"reason"]
                                                               delegate:nil
                                                      cancelButtonTitle:@"Try Again"
                                                      otherButtonTitles:nil];
                [alert show];
                return;
            }
            else {
                NSLog(@"Successful Create Meteor account");
                [self.meteor logonWithUsername:self.createEmail.text password:self.createPassword.text responseCallback:^(NSDictionary *response, NSError *error) {
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
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Classmate"
                                                    message:[error localizedDescription]
                                                   delegate:nil
                                          cancelButtonTitle:@"Try Again"
                                          otherButtonTitles:nil];
    [alert show];
}

- (BOOL) validateEmailWithString:(NSString *)emailStr
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:emailStr];
}



@end
