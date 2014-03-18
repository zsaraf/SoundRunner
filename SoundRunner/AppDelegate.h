//
//  AppDelegate.h
//  SoundRunner
//
//  Created by Zachary Waleed Saraf on 2/25/14.
//  Copyright (c) 2014 Zachary Waleed Saraf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import "SoundGen.h"
#import "Drummer.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    CMMotionManager *motionManager;
}
@property (readonly) CMMotionManager *motionManager;

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) SoundGen *soundGen;
@property (nonatomic, strong) Drummer *drummer;
@property (nonatomic, strong) NSMutableDictionary *otherPlayers;

@end
