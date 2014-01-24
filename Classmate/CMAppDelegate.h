//
//  CMAppDelegate.h
//  Classmate
//
//  Created by Garner McCloud on 1/21/14.
//  Copyright (c) 2014 Classmate. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ViewController, MeteorClient;


@interface CMAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) MeteorClient *meteorClient;

@end
