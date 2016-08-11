//
//  Signature.h
//  Agilanews
//
//  Created by 张思思 on 16/7/13.
//  Copyright © 2016年 banews. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Signature : NSObject

+ (NSString *)hmacsha1:(NSString *)text key:(NSString *)secret;

@end
