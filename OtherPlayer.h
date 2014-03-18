//
//  OtherPlayer.h
//  SoundRunner
//
//  Created by Zachary Waleed Saraf on 3/17/14.
//  Copyright (c) 2014 Zachary Waleed Saraf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SoundGen.h"
#import "Entity.h"
#import "Instrument.h"

@interface OtherPlayer : NSObject

-(id)initWithName:(NSString *)name;

@property (nonatomic, strong) NSString *name;
@property (nonatomic) BOOL noteOn;
@property (nonatomic) CGFloat xLoc;
@property (nonatomic, strong) SoundGen *soundGen;
@property (nonatomic) OtherAvatar *avatar;
@property (nonatomic) ScrollAvatar *scrollAvatar;
@property (nonatomic, weak) Instrument *instrument;

@end
