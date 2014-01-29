//
//  CMCreateAccountViewController.h
//  Classmate
//
//  Created by Garner McCloud on 1/28/14.
//  Copyright (c) 2014 Classmate. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MeteorClient;

@interface CMCreateAccountViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *confirmPassword;
@property (weak, nonatomic) IBOutlet UILabel *connectionStatusText;
@property (weak, nonatomic) IBOutlet UIImageView *connectionStatusLight;
@property (weak, nonatomic) IBOutlet UIButton *createButton;
@property (strong, nonatomic) MeteorClient *meteor;

- (IBAction)didTapCreateButton:(id)sender;



@end
