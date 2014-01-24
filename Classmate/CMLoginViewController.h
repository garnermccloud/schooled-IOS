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




@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UILabel *connectionStatusText;
@property (weak, nonatomic) IBOutlet UIImageView *connectionStatusLight;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (strong, nonatomic) MeteorClient *meteor;
@property (weak, nonatomic) IBOutlet UIButton *sayHiButton;

- (IBAction)didTapLoginButton:(id)sender;


@end
