//
//  Drummer.h
//  SoundRunner
//
//  Created by Zachary Waleed Saraf on 3/17/14.
//  Copyright (c) 2014 Zachary Waleed Saraf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SoundGen.h"

@interface Drummer : NSObject

-(void)tick;

@property (nonatomic, strong) SoundGen *soundGen;

@end
