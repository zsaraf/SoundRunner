//
//  RunnerViewController.m
//  SoundRunner
//
//  Created by JP Wright on 2/26/14.
//  Copyright (c) 2014 Zachary Waleed Saraf. All rights reserved.
//

#import "RunnerViewController.h"
#import <CoreMotion/CoreMotion.h>
#import "renderer.h"


@interface RunnerViewController ()
{
    CMAttitude *referenceAttitude;
    SettingsViewController *settings;
}
@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;
@property (strong, nonatomic) CMAttitude *refAttitude;

- (void)setupGL;
- (void)tearDownGL;

@end

@implementation RunnerViewController

// first time that view loads.
bool firstTime = true;


//// idk what this function is for
//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

- (void)viewDidLoad
{
    NSLog(@"go");
    [super viewDidLoad];
    if (firstTime)
    {
        NSLog(@"go");
        self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
        
        if (!self.context) {
            NSLog(@"Failed to create ES context");
        }
        
        GLKView *view = (GLKView *)self.view;
        view.context = self.context;
        view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
        
        [self setupGL];
        settings = [[SettingsViewController alloc] init];
        
        
        // initialize
        RunnerInit();
        
        // init accelerometer interaction.
        [self startMyMotionDetect];
        [self startGyroDetect];
        firstTime = false;
    }
    
    
}

- (void)viewDidLayoutSubviews
{
    
    RunnerSetDims( self.view.bounds.size.width, self.view.bounds.size.height );
}

- (void)dealloc
{
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    if ([self isViewLoaded] && ([[self view] window] == nil)) {
        self.view = nil;
        
        [self tearDownGL];
        
        if ([EAGLContext currentContext] == self.context) {
            [EAGLContext setCurrentContext:nil];
        }
        self.context = nil;
    }
    
    // Dispose of any resources that can be recreated.
}



// motion manager stuffs
- (CMMotionManager *)motionManager
{
    CMMotionManager *motionManager = nil;
    
    id appDelegate = [UIApplication sharedApplication].delegate;
    
    if ([appDelegate respondsToSelector:@selector(motionManager)])
    {
        motionManager = [appDelegate motionManager];
    }
    return motionManager;
}

// accelerometer stuffs
- (void)startMyMotionDetect
{
    NSTimeInterval updateInterval = 1/90; // 60 Hz updateInterval
    [self.motionManager setAccelerometerUpdateInterval:updateInterval];
    
    
    [self.motionManager startAccelerometerUpdatesToQueue:[[NSOperationQueue alloc] init] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error)
     {
         
         // do stuff with accelerometer data
         
     }];
}

// also gathers attitude data via the attitude fucntion below
- (void)startGyroDetect
{
    if ([self.motionManager isGyroAvailable])
    {
        if([self.motionManager isGyroActive] == NO)
        {
            CMDeviceMotion *deviceMotion = self.motionManager.deviceMotion ;
            CMAttitude *attitude = deviceMotion.attitude;
            
            // devicemotion update interval
            float updateInterval = 1/90.;
            self.motionManager.deviceMotionUpdateInterval = updateInterval; // 90 Hz
            [self.motionManager startDeviceMotionUpdates];
            
            // gyro update interval
            [self.motionManager setGyroUpdateInterval:1/30.f]; // 30 Hz
            
            [self.motionManager startGyroUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMGyroData *gyroData, NSError *error)
             {
                 // processing of gyro data here.
                 
                 // TODO: figure out slew for moving around the screen.
                 float roll = 180/M_PI*self.motionManager.deviceMotion.attitude.roll;
                 float yaw = 180/M_PI*self.motionManager.deviceMotion.attitude.yaw;
                 float pitch = 180/M_PI*self.motionManager.deviceMotion.attitude.pitch;
                 
                 
                 moveAvatar(pitch/180.0);
                 moveCamera(pitch/180.0);
                 
                 // do stuff with gyro data
                 
                 
             }];
            
            
        }
    }
    else
    {
        NSLog(@"Gyroscope not Available!");
    }
}



// ============================graphics stuffs=============================
- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];
    
    // glEnable( GL_DEPTH_TEST );
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
    self.effect = nil;
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    //    glClearColor( 1.0f, 1.0f, 0.0f, 1.0f);
    //    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    RunnerRender();
}
@end