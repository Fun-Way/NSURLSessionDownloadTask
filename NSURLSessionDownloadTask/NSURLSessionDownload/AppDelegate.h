//
//  AppDelegate.h
//  NSURLSessionDownload
//
//  Created by HEYANG on 16/2/17.
//  Copyright © 2016年 HEYANG. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^BackGroundSession)(void);

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (copy, nonatomic) BackGroundSession backgroundSessionCompletionHandler;


@end

