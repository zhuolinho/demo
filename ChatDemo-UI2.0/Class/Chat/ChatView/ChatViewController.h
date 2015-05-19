/************************************************************
  *  * EaseMob CONFIDENTIAL 
  * __________________ 
  * Copyright (C) 2013-2014 EaseMob Technologies. All rights reserved. 
  *  
  * NOTICE: All information contained herein is, and remains 
  * the property of EaseMob Technologies.
  * Dissemination of this information or reproduction of this material 
  * is strictly forbidden unless prior written permission is obtained
  * from EaseMob Technologies.
  */

#import <UIKit/UIKit.h>
#import "EaseMobHeaders.h"
#import "EaseMob.h"

@protocol ChatViewControllerDelegate;

@interface ChatViewController : UIViewController

@property (nonatomic) id<ChatViewControllerDelegate> delegate;

@property (nonatomic, strong) NSString *chatter;
@property (nonatomic, strong) NSString *myHeadUrl;
@property (nonatomic, strong) NSString *friendHeadUrl;
@property (nonatomic, strong) NSString *nickname;
@property (nonatomic, strong) NSString *url;
@property (nonatomic) BOOL buyCourseRightNow;

- (instancetype)initWithChatter:(NSString *)chatter;

- (instancetype)initWithGroup:(EMGroup *)chatGroup;

@end

@protocol ChatViewControllerDelegate <NSObject>

- (void) wtfButtonClick:(NSString *)username nickname:(NSString*)nickname url:(NSString *)url;

@end