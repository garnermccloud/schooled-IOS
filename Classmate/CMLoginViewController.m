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
#import <UICKeyChainStore.h>
#import "GAIDictionaryBuilder.h"



@interface CMLoginViewController ()
@property (strong, nonatomic) IBOutlet UIView *createAccountView;
@property (strong, nonatomic) IBOutlet UIView *loginView;
@property (strong, nonatomic) IBOutlet UIView *splashView;




@end

@implementation CMLoginViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view = self.splashView;
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
    
#pragma mark Google Analytics
    // returns the same tracker you created in your app delegate
    // defaultTracker originally declared in AppDelegate.m
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    // This screen name value will remain set on the tracker and sent with
    // hits until it is set to a new value or to nil.
    [tracker set:kGAIScreenName
           value:@"Login Screen"];
    
    // manual screen tracking
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    [self.meteor addObserver:self
                  forKeyPath:@"websocketReady"
                     options:NSKeyValueObservingOptionNew
                     context:nil];
    if ([UICKeyChainStore stringForKey:@"email"] ) {
        [self.rememberEmailSwitch setOn:YES];
        self.loginEmail.text = [UICKeyChainStore stringForKey:@"email"];
    }
    
    
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


- (IBAction)didTapSplashLoginButton:(id)sender
{
    [self didTapGoToLoginButton:sender];
}

- (IBAction)didTapSplashSignUpButton:(id)sender
{
    [self didTapSignUpNowButton:sender];
}


- (IBAction)didTapLoginButton:(id)sender {
    if (self.rememberEmailSwitch.on) {
        [UICKeyChainStore setString:self.loginEmail.text forKey:@"email"];
    } else {
        [UICKeyChainStore removeItemForKey:@"email"];
    }
    
    if (!self.meteor.websocketReady) {
        UIAlertView *notConnectedAlert = [[UIAlertView alloc] initWithTitle:@"Connection Error"
                                                                    message:@"Can't find the Classmate server, try again"
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
        [notConnectedAlert show];
        return;
    }
    
    [self.meteor logonWithUsername:[self.loginEmail.text lowercaseString] password:self.loginPassword.text responseCallback:^(NSDictionary *response, NSError *error) {
        if (error) {
            [self handleFailedAuth:error];
            return;
        } else {
            id pvc = self.presentingViewController;
            if ([pvc respondsToSelector:NSSelectorFromString(@"meteor")]) {
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
        [user setValue:[self.createEmail.text lowercaseString] forKeyPath:@"email"];
        [user setValue:self.createPassword.text forKeyPath:@"password"];
        
        [self.meteor signupWithUsername:[self.createEmail.text lowercaseString] password:self.createPassword.text responseCallback:^(NSDictionary *response, NSError *error) {
                if (error) {
                    //NSLog(@"Error = %@", error);
                        [self handleFailedAuth:error];
                        return;
                    }
                [self handleSuccessfulAuth];
            }];
         
        /*

        [self.meteor callMethodName:@"createUser" parameters:@[user] responseCallback:^(NSDictionary *response, NSError *error) {
            NSLog(@"response = %@", response);
            if (error) {
                NSString *errorMessage;
                if ([[error localizedDescription] isKindOfClass:[NSString class]])
                {
                    errorMessage = [error description];
                } else {
                    id errorId = [error description];
                    NSDictionary *errorDictionary = (NSDictionary *)errorId;
                    errorMessage = errorDictionary[@"reason"];
                }
                NSLog(@"Error = %@", errorMessage);
                //NSDictionary *errorDictionary = (NSDictionary *)errorId;
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:@"test message"//errorMessage
                                                               delegate:nil
                                                      cancelButtonTitle:@"Try Again"
                                                      otherButtonTitles:nil];
                [alert show];
                
            }
            else {
                [self handleSuccessfulAuth];
                NSLog(@"Successful Create Meteor account");
                [self.meteor logonWithUsername:[self.createEmail.text lowercaseString] password:self.createPassword.text responseCallback:^(NSDictionary *response, NSError *error) {
                    if (error) {
                        [self handleFailedAuth:error];
                        return;
                    } else {
                        [self handleSuccessfulAuth];
                    }
                }]; 
         
            }
        }];
         */
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

- (void)handleSuccessfulAuth {
    NSLog(@"Successful Login Meteor Client = %@", self.meteor);
    id pvc = self.presentingViewController;
    if ([pvc respondsToSelector:NSSelectorFromString(@"meteor")]) {
        NSLog(@"has meteor property");
        [pvc setValue:self.meteor forKey:@"meteor"];
    }
    [pvc dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL) validateEmailWithString:(NSString *)emailStr
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:emailStr];
}



@end
