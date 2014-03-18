//
//  Instrument.h
//  SoundRunner
//
//  Created by JP Wright on 3/17/14.
//  Copyright (c) 2014 Zachary Waleed Saraf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Instrument : NSObject

@property (nonatomic) NSInteger patchNum;
@property (nonatomic) uint8_t bankNum;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) UIColor * color;

@end
