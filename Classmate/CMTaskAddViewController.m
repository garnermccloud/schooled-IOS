//
//  CMTaskAddViewController.m
//  Classmate
//
//  Created by Garner McCloud on 1/27/14.
//  Copyright (c) 2014 Classmate. All rights reserved.
//

#import "CMTaskAddViewController.h"

@interface CMTaskAddViewController ()
@property (weak, nonatomic) IBOutlet UITextField *titleField;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UITextView *notesTextView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *submitBarButtonItem;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation CMTaskAddViewController

-(void)loadSubscriptions
{
    [super loadSubscriptions];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UITapGestureRecognizer *tapScroll = [[UITapGestureRecognizer alloc]initWithTarget:self     action:@selector(tapped)];
    tapScroll.cancelsTouchesInView = NO;
    [self.scrollView addGestureRecognizer:tapScroll];
}

- (void) tapped
{
    [self.view endEditing:YES];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self reloadUI];
    
}

-(void)reloadUI
{
    self.navigationItem.title = @"Add Task";
}


#pragma mark - Meteor Collection Querying



- (IBAction)pressedSubmitBarButton:(id)sender
{
    NSMutableDictionary *task = [[NSMutableDictionary alloc] init];
    [task setValue:self.titleField.text forKeyPath:@"title"];
     [task setValue:self.course[@"_id"] forKeyPath:@"courseId"];
    double dateInMillisecondsSince1970 = [self.datePicker.date timeIntervalSince1970];
    dateInMillisecondsSince1970 = dateInMillisecondsSince1970 * 1000;
    NSNumber *date = [[NSNumber alloc] initWithDouble:dateInMillisecondsSince1970];
    [task setValue:date forKeyPath:@"dueDate"];
    [task setValue:self.notesTextView.text forKeyPath:@"notes"];

    
    [self.meteor callMethodName:@"addTask" parameters:@[task] responseCallback:^(NSDictionary *response, NSError *error) {
        if (error) {
            id errorId = [error localizedDescription];
            NSDictionary *errorDictionary = (NSDictionary *)errorId;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:errorDictionary[@"reason"]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Try Again"
                                                  otherButtonTitles:nil];
            [alert show];
        }
        else {
            [self.navigationController popViewControllerAnimated: YES];
        }
    }];
    
}


@end