//
//  RTCSystemSetting.h
//  RTCSystemSetting
//
//  Created by ninty on 2017/5/29.
//  Copyright © 2017年 ninty. All rights reserved.
//

#import <Foundation/Foundation.h>

#if __has_include(<React/RCTBridgeModule.h>)
#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#else
#import "RCTBridgeModule.h"
#import "RCTEventEmitter.h"
#endif

@interface RCTSystemSetting : RCTEventEmitter <RCTBridgeModule>

@property (nonatomic, strong) UISlider *volumeSlider;

@end
