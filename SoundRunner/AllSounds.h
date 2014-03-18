//
//  AllSounds.h
//  SoundRunner
//
//  Created by JP Wright on 3/17/14.
//  Copyright (c) 2014 Zachary Waleed Saraf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Instrument.h"

@interface AllSounds : NSObject

@property (nonatomic) NSMutableArray * instruments;

+(id)instance;
- (Instrument *)getInstrumentAtIndex:(int)index;

@end
