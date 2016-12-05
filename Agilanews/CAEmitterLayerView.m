//
//  CAEmitterLayerView.m
//  Agilanews
//
//  Created by 张思思 on 16/12/5.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "CAEmitterLayerView.h"

@interface CAEmitterLayerView() {
    CAEmitterLayer *_emitterLayer;
}
@end

@implementation CAEmitterLayerView

+(Class)layerClass {
    return [CAEmitterLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _emitterLayer = (CAEmitterLayer *)self.layer;
    }
    return self;
}

- (void)setEmitterLayer:(CAEmitterLayer *)layer {
    _emitterLayer = layer;
}

- (CAEmitterLayer *)emitterLayer {
    return _emitterLayer;
}

- (void)show {
    
}

- (void)hide {
    
}

@end
