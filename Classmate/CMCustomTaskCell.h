//
//  CMCustomTaskCell.h
//  Classmate
//
//  Created by Garner McCloud on 1/24/14.
//  Copyright (c) 2014 Classmate. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CMCustomTaskCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *dueDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *courseLabel;

@end
