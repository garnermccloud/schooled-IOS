//
//  CMLoginViewController.h
//  Classmate
//
//  Created by Garner McCloud on 1/22/14.
//  Copyright (c) 2014 Classmate. All rights reserved.
//

#import <UIKit/UIKit.h>


@class MeteorClient;

@interface CMLoginViewController : UIViewController




@property (weak, nonatomic) IBOutlet UITextField *loginEmail;
@property (weak, nonatomic) IBOutlet UITextField *loginPassword;
@property (weak, nonatomic) IBOutlet UISwitch *rememberEmailSwitch;

@property (weak, nonatomic) IBOutlet UITextField *createEmail;
@property (weak, nonatomic) IBOutlet UITextField *confirmEmail;
@property (weak, nonatomic) IBOutlet UITextField *createPassword;
@property (weak, nonatomic) IBOutlet UITextField *confirmPassword;


@property (weak, nonatomic) IBOutlet UILabel *connectionStatusText;
@property (weak, nonatomic) IBOutlet UIImageView *connectionStatusLight;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *createAccountButton;

@property (weak, nonatomic) IBOutlet UIButton *goToLoginButton;
@property (weak, nonatomic) IBOutlet UIButton *goToSignUpButton;

@property (strong, nonatomic) MeteorClient *meteor;

- (IBAction)didTapLoginButton:(id)sender;
- (IBAction)didTapSignUpNowButton:(id)sender;
- (IBAction)didTapCreateAccountButton:(id)sender;
- (IBAction)didTapGoToLoginButton:(id)sender;
- (IBAction)didTapSplashLoginButton:(id)sender;
- (IBAction)didTapSplashSignUpButton:(id)sender;



@end
