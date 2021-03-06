//
//  RTCSystemSetting.m
//  RTCSystemSetting
//
//  Created by ninty on 2017/5/29.
//  Copyright © 2017年 ninty. All rights reserved.
//

#import "RTCSystemSetting.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import <ifaddrs.h>
#import <net/if.h>

@import UIKit;
@import MediaPlayer;

@implementation RCTSystemSetting{
    bool hasListeners;
}

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(setBrightness:(float)val){
    [[UIScreen mainScreen] setBrightness:val];
}

RCT_EXPORT_METHOD(getBrightness:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject){
    resolve([NSNumber numberWithFloat:[UIScreen mainScreen].brightness]);
}

RCT_EXPORT_METHOD(setVolume:(float)val){
    if(self.volumeSlider) {
        [self.volumeSlider setValue:1.0f animated:NO];
    }
}

RCT_EXPORT_METHOD(getVolume:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject){
    if(self.volumeSlider){
        float val =[self.volumeSlider value];
        resolve([NSNumber numberWithFloat:val]);
    }else {
        resolve([NSNumber numberWithFloat:-1]);
    }
}

RCT_EXPORT_METHOD(switchWifi){
    [self openWifiNative];
}

RCT_EXPORT_METHOD(isWifiEnabled:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject){
    resolve([NSNumber numberWithBool:[self isWifiEnabled]]);
}

-(void)openWifiNative{
    NSString *url = [UIDevice currentDevice].systemVersion.doubleValue >= 10.0 ? @"App-Prefs:root=WIFI" : @"prefs:root=WIFI";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url] options:[NSDictionary new] completionHandler:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWakeUp:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

-(BOOL)isWifiEnabled{
    NSCountedSet * cset = [NSCountedSet new];
    struct ifaddrs *interfaces;
    if( ! getifaddrs(&interfaces) ) {
        for( struct ifaddrs *interface = interfaces; interface; interface = interface->ifa_next)
        {
            if ( (interface->ifa_flags & IFF_UP) == IFF_UP ) {
                [cset addObject:[NSString stringWithUTF8String:interface->ifa_name]];
            }
        }
    }
    return [cset countForObject:@"awdl0"] > 1 ? YES : NO;
}

-(void)applicationWakeUp:(NSNotification*)notification{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [self sendEventWithName:@"EventEnterForeground" body:nil];
}

-(instancetype)init{
    self = [super init];
    if(self){
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(volumeChanged:)
                                                     name:@"AVSystemController_SystemVolumeDidChangeNotification"
                                                   object:nil];
        
        MPVolumeView *volumeView = [[MPVolumeView alloc] init];
        for (UIView *view in [volumeView subviews]) {
            if ([view.class.description isEqualToString:@"MPVolumeSlider"]) {
                self.volumeSlider = (UISlider *)view;
                break;
            }
        }
    }
    return self;
}

- (NSArray<NSString *> *)supportedEvents
{
    return @[@"EventVolume", @"EventEnterForeground"];
}

-(void)startObserving {
    hasListeners = YES;
}

-(void)stopObserving {
    hasListeners = NO;
}

-(void)volumeChanged:(NSNotification *)notification{
    if(hasListeners){
        float volume = [[[notification userInfo] objectForKey:@"AVSystemController_AudioVolumeNotificationParameter"] floatValue];
        [self sendEventWithName:@"EventVolume" body:@{@"value": [NSNumber numberWithFloat:volume]}];
    }
}

@end
