//
//  Scale.m
//  SoundRunner
//
//  Created by Zachary Waleed Saraf on 3/6/14.
//  Copyright (c) 2014 Zachary Waleed Saraf. All rights reserved.
//

#import "Scale.h"

@implementation Scale

const int majorScale[] = {
    0, 2, 3, 5, 7, 8, 10
};
const int majorScale_numNotes = 7;



+(Scale *)instance
{
    static Scale *sharedScale = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedScale = [[self alloc] init];
    });
    return sharedScale;
}



-(NSInteger)noteForKey:(NSInteger)key
{
    int *scale = NULL;
    int numNotes = -1;
    if (self.scaleType == SRMajor) {
        scale = (int *)majorScale;
        numNotes = majorScale_numNotes;
    }
    
    int note = 12 * (key / numNotes) + scale[key % numNotes];
    
    return note;
}

@end
