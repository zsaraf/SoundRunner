//
//  NetworkManager.m
//  lovestep
//
//  Created by Zachary Waleed Saraf on 11/13/13.
//  Copyright (c) 2013 Zachary Waleed Saraf. All rights reserved.
//

#import "NetworkManager.h"

#define WAITING_FOR_OTHER_USER_TAG 20
#define USER_NAME_SEND_TAG 21
#define USER_NAME_RECEIVE_TAG 22
#define RECEIVED_ARRAY 23
#define HEADER_TAG 24
#define RECEIVED_DISABLE 25
#define RECEIVED_ENABLE 26


#define LOOP_TYPE 1
#define ENABLE_TYPE 2
#define DISABLE_TYPE 3

@interface NetworkManager ()

@property (nonatomic, strong) GCDAsyncSocket *asyncSocket;

@end

@implementation NetworkManager

static NetworkManager *myInstance;

//singleton
+(NetworkManager *)instance
{
    @synchronized(self)
    {
        if (myInstance == NULL)
            myInstance = [[self alloc] init];
    }
    
    return(myInstance);
}

-(void)createNetwork
{
    if (self.asyncSocket) return;
    self.asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    [self.asyncSocket connectToHost:@"10.34.70.75" onPort:80 error:nil];
    [self.asyncSocket readDataWithTimeout:-1 tag:WAITING_FOR_OTHER_USER_TAG];
}

#pragma delegate methods
-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSString *dataString = [NSString stringWithUTF8String:[data bytes]];\
    NSLog(@"RECEIVED: %@", dataString);
    [self.asyncSocket readDataToLength:sizeof(header_t) withTimeout:-1 tag:HEADER_TAG];
}

@end
