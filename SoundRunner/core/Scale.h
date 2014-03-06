//
//  Scale.h
//  SoundRunner
//
//  Created by Zachary Waleed Saraf on 3/6/14.
//  Copyright (c) 2014 Zachary Waleed Saraf. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    SRMajor
} SRScaleType;

@interface Scale : NSObject

+(Scale *)instance;
-(NSInteger)noteForKey:(NSInteger)key;

@property (nonatomic) SRScaleType scaleType;

@end
