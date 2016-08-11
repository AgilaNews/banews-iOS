//
//  UIDevice+UhouAdditions.h
//  Uhou_Framework
//
//  Created by Sunny on 16/1/20.
//  Copyright © 2016年 Sunny. All rights reserved.
//

#import <UIKit/UIKit.h>



#define IS_IPAD_DEVICE ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)

@interface UIDevice (UhouAdditions)

+ (UIInterfaceOrientation)currentOrientation;

- (BOOL)hasRetinaDisplay;
- (BOOL)screenIs4InchScreen;

- (NSUInteger)totalMemory;
- (NSUInteger)userMemory;

- (NSString*)macAddress;
- (NSString*)platformString;
- (NSString*)deviceIdentifier;
- (NSString*)uuid;


@end
