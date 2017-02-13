//
//  DebugViewController.h
//  Agilanews
//
//  Created by 张思思 on 17/2/13.
//  Copyright © 2017年 banews. All rights reserved.
//

#import "BaseViewController.h"

@interface DebugViewController : BaseViewController <UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, strong) NSArray *apiArray;

@end
