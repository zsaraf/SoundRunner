//
//  renderer.mm
//  SoundRunner
//
//  Created by JP Wright on 2/26/14.
//  Copyright (c) 2014 Zachary Waleed Saraf. All rights reserved.
//

#import "renderer.h"
#import "mo_audio.h"
#import <math.h>

#import "Globals.h"
#import "Scales.h"
#import <stdlib.h>
using namespace std;


#define SRATE 24000
#define FRAMESIZE 512
#define NUM_CHANNELS 2
#define NUM_PARTICLES 400

#define NUM_NICE_COLORS 4

static const GLfloat niceColors[] = {
    52/255.,  152/255., 219/255., // rgba(52, 152, 219,1.0)
    155/255.,  89/255., 182/255., // rgba(155, 89, 182,1.0)
    46/255.,   204/255., 113/255., // rgba(46, 204, 113,1.0)
    243/255., 156/255., 18/255.// rgba(243, 156, 18,1.0)
};


// -------------------instance variables-------------------
// --------------------------------------------------------
GLfloat g_waveformWidth = 2;
GLfloat g_gfxWidth = 1024;
GLfloat g_gfxHeight = 640;
GLfloat g_ratio = g_gfxWidth / g_gfxHeight;

GLfloat leftClip = -g_ratio;
GLfloat rightClip = g_ratio;
GLfloat avatarYStart = 0.3;
// buffer
UInt32 g_numFrames;

// graphics stuffs
Entity * g_avatar;
std::vector<Entity *> g_entities;
GLfloat nextAvatarX = 0.0;
int numNotesInScale = Scales::numNotesPerScale;


// number of voices
int numVoices = 32;

// time keepingstuffs
double lastTime = 0.0;
int samplesPerBeat = SRATE * 1/(Globals::BPM/60.0); // samples per beat
bool newBeat = false;
int sampCount = 0;



// -------------------function prototypes------------------
// --------------------------------------------------------

Entity * makeAvatar(float x, float y);
void renderEntities();
void renderSingleEntity(Entity * e);
void makeParticleSystem();
void makeNoteBoundarys(int numNotes);



void moveCamera(GLfloat inc)
{
    if ( nextAvatarX <= Globals::leftBound + g_ratio && leftClip == Globals::leftBound )
    {
        return;
    }
    else if (nextAvatarX >= Globals::rightBound - g_ratio && rightClip == Globals::rightBound)
    {
        return;
    }
    leftClip += inc;
    rightClip += inc;
    
    
    if (leftClip <= Globals::leftBound)
    {
        
        leftClip = Globals::leftBound;
        rightClip = Globals::leftBound + g_ratio*2;
    }
    if (rightClip >= Globals::rightBound)
    {
        
        rightClip = Globals::rightBound;
        leftClip = Globals::rightBound - g_ratio*2;
    }
    
}

void moveAvatar(float displacement)
{
    nextAvatarX = g_avatar->loc.x + displacement*2.5;
}






//-----------------------------------------------------------------------------
// name: audio_callback()
// desc: audio callback, yeah
//-----------------------------------------------------------------------------
void audio_callback( Float32 * buffer, UInt32 numFrames, void * userData )
{
    for( int i = 0; i < numFrames; i++ )
    {
        sampCount++;
        // zero out for now so we don't get mic input coming out!
        buffer[2*i] = buffer[2*i+1] = 0;
        // synching stuff
        if (sampCount == samplesPerBeat)
        {
            // turn note off
            newBeat = true;
            sampCount = 0;
        }
    }
    
    
    
    // save the num frames
    g_numFrames = numFrames;
    
    // NSLog( @"." );
}

bool touch_down = false;

//-----------------------------------------------------------------------------
// name: touch_callback()
// desc: the touch call back
//-----------------------------------------------------------------------------
void touch_callback( NSSet * touches, UIView * view,
                    std::vector<MoTouchTrack> & tracks,
                    void * data)
{
    // points
    CGPoint pt;
    CGPoint prev;
    
    // number of touches in set
    NSUInteger n = [touches count];
    
    // iterate over all touch events
    for( UITouch * touch in touches )
    {
        // get the location (in window)
        pt = [touch locationInView:view];
        prev = [touch previousLocationInView:view];
        
        GLfloat ratio = g_gfxWidth / g_gfxHeight;
        
        // calc GL coordinates
        GLfloat x = (pt.y / g_gfxWidth * 2 * ratio) - ratio;
        GLfloat y = (pt.x / g_gfxHeight * 2 ) - 1;
        
        GLfloat prevX = (prev.y / g_gfxWidth * 2 * ratio) - ratio;
        GLfloat prevY = (prev.x / g_gfxHeight * 2) - 1;
        
        // check the touch phase
        switch( touch.phase )
        {
                
            // --------------------------------------------
            // ---------------touch began------------------
            case UITouchPhaseBegan:
            {
                touch_down = true;
                if (newBeat)
                {
                    NSLog(@"NOTE ON!");
                    // note on
                    
                    newBeat = false;
                }
                
                //NSLog( @"touch began... %f %f", x, y );
                //g_avatar->col.set(231/255.0, 76/255.0, 60/255.0); //rgba(231, 76, 60,1.0)
                
                break;
            }
            // --------------------------------------------
            // -------------touch stationary---------------
            case UITouchPhaseStationary:
            {
                
                NSLog( @"touch stationary... %f %f", pt.x, pt.y );
                if (newBeat)
                {
                    NSLog(@"NOTE ON!");
                    // note on
                    newBeat = false;

                }
                //g_avatar->col.set(0.0, 0.0, 0.0);
                //g_avatar->col.set(231/255.0, 76/255.0, 60/255.0); //rgba(231, 76, 60,1.0)

                
                break;
            }
                
            // --------------------------------------------
            // ---------------touch moved------------------
            case UITouchPhaseMoved:
            {
                //NSLog( @"touch moved... %f %f", pt.x, pt.y );
                if (newBeat)
                {
                    NSLog(@"NOTE ON!");
                    // note on
                    newBeat = false;

                }
                //g_avatar->col.set(0.0, 0.0, 0.0);
                //g_avatar->col.set(231/255.0, 76/255.0, 60/255.0); //rgba(231, 76, 60,1.0)
                break;
            }
                
            // --------------------------------------------
            // ---------------touch ended------------------
            case UITouchPhaseEnded:
            {
                touch_down = false;
                //NSLog( @"touch ended... %f %f", x, y );
                //g_avatar->col.set(1.0, 1.0, 1.0);
                //g_avatar->col.set(231/255.0, 76/255.0, 60/255.0); //rgba(231, 76, 60,1.0)
                // note off
                break;
            }
                
            // --------------------------------------------
            // --------------touch canceled----------------

            case UITouchPhaseCancelled:
            {
                //NSLog( @"touch cancelled... %f %f", pt.x, pt.y );
                break;
            }
                // should not get here
            default:
                break;
        }
    }
}




// initialize the engine (audio, grx, interaction)
void RunnerInit()
{
    NSLog( @"init..." );
    
    // set touch callback
    MoTouch::addCallback( touch_callback, NULL );
    
    // generate texture name
    glGenTextures( 2, &Globals::g_texture[0] );
    // bind the texture
    glBindTexture( GL_TEXTURE_2D, Globals::g_texture[0] );
    // setting parameters
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
    
    // load the texture
    MoGfx::loadTexture( @"flare-tng-5", @"png" );
    
    glBindTexture( GL_TEXTURE_2D, Globals::g_texture[1] );
    // setting parameters
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
    
    // load the texture
    MoGfx::loadTexture( @"flare-tng-4", @"png" );
    
    GLfloat ratio = g_gfxWidth / g_gfxHeight;
    
    
    // init audio
    bool result = MoAudio::init( SRATE, FRAMESIZE, NUM_CHANNELS );
    if( !result )
    {
        // do not do this:
        int * p = 0;
        *p = 0;
    }
    // start
    result = MoAudio::start( audio_callback, NULL );
    if( !result )
    {
        // do not do this:
        int * p = 0;
        *p = 0;
    }
    
    g_avatar = makeAvatar(0.0, avatarYStart);
    makeNoteBoundarys(numNotesInScale);
    makeParticleSystem();
}

void makeNoteBoundarys(int numNotes)
{
    // entire x range of the GL worldapplication
    GLfloat xRange = Globals::rightBound - Globals::leftBound;
    // spacing between each note boundary
    
    GLfloat xInc = xRange / (float)numNotes;
    
    for (int i = 0; i < numNotes + 1; i++)
    {
        NoteBoundary * bound = new NoteBoundary(Globals::leftBound +  (i * xInc) );
        if ( bound != NULL )
        {
            // add to g_entities
            g_entities.push_back( bound );
            // alpha
            bound->alpha = 1.0;
            // set color
            bound->col.set( 52/255., 73/255., 94/255. ); //rgba(52, 73, 94,1.0)
            // set scale
            bound->sca.setAll( 1 );
            // activate
            bound->active = true;
        }
    }
}





Entity * makeAvatar(float x, float y)
{
    Entity * e = new Avatar(true); // true means velocity is active
    if ( e != NULL )
    {
        //NSLog(@"making new avatar");

        // add to g_entities
        g_entities.push_back( e );
        // alpha
        e->alpha = 1.0;
        // set velocity
        e->vel.set( 0.0, -1.5, 0.0);
        // set location
        e->loc.set( x, y, 0 );
        // set color
        if (touch_down) {
            e->col.set(231/255.0, 76/255.0, 60/255.0); //rgba(231, 76, 60,1.0)
        } else {
            e->col.set( 1.0, 1.0, 1.0 );
        }
        // set scale
        e->sca.setAll( .4 );
        // activate
        e->active = true;
    }
    return e;
}



void makeParticleSystem()
{
    for (int i = 0; i < NUM_PARTICLES; i++)
    {
        Particle * part = new Particle();
        // random size between 0 and 0.5
        part->size.setAll( 0.5*( rand()  / (float)RAND_MAX ) );
        // random x location between Globals::leftBound and Globals::rightBound
        part->loc.x = Globals::rightBound * 2*( (rand() / (float)RAND_MAX) - 0.5 );
        // random y location between -1 and1
        part->loc.y = 2*g_ratio*( (rand() / (float)RAND_MAX) - 0.5 );
        part->loc.z = 0;
        part->vel.x = -.005 + (rand() / (float)RAND_MAX) * .01;
        part->vel.y = -.005 + (rand() / (float)RAND_MAX) * .01;
        // alpha
        part->alpha = 1.0;
        // scale
        int random_num = rand();
        
        part->sca.setAll((random_num/(float)RAND_MAX * .06) + .04);

        int color_index = random_num % NUM_NICE_COLORS;
        // color
        part->col.set(niceColors[color_index * 3], niceColors[color_index * 3 + 1], niceColors[color_index * 3 + 2]);
        // active
        part->active = true;
        // insert
        g_entities.push_back(part);
    }
}


// set graphics dimensions
void RunnerSetDims( GLfloat width, GLfloat height )
{
    NSLog( @"set dims: %f %f", width, height );
    g_gfxWidth = width;
    g_gfxHeight = height;
    
    g_waveformWidth = width / height * 1.9;
}




// draw next frame of graphics
void RunnerRender()
{
    g_avatar = makeAvatar(nextAvatarX, avatarYStart);

    // refresh current time reading (in microseconds)
    double currTime = MoGfx::getCurrentTime( true );
    
    // projection
    glMatrixMode( GL_PROJECTION );
    // reset
    glLoadIdentity();
    // alternate
    GLfloat ratio = g_gfxWidth / g_gfxHeight;
    // orthographic
    glOrthof( leftClip, rightClip, -1, 1, -1, 1 );
    // modelview
    glMatrixMode( GL_MODELVIEW );
    // reset
    // glLoadIdentity();
    
    // BACKGROUND COLOR
    glClearColor( 22/255.0, 31/255.0, 40/255.0, 1); // rgba(44, 62, 80,1.0)
    glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );
    
    // push
    glPushMatrix();
    
    // entities
    renderEntities();
    
    // pop
    glPopMatrix();
}



// render all entities in simulation
void renderEntities()
{
    // render g_entities.
    vector<Entity *>::iterator e;
    for ( e = g_entities.begin(); e != g_entities.end(); e++ )
    {
        if ( (*e)->active == FALSE )
        {
            delete (*e);
            
            g_entities.erase(e);
            
            e--;
            
            if (g_entities.size() == 0 ) break;
            continue;
            
            
        }
        else {
            renderSingleEntity((*e));
        }
    }
}


void renderSingleEntity(Entity * e)
{
    // update the entity
    e->update( MoGfx::delta() );
    
    // push
    glPushMatrix();
    
    // translate
    glTranslatef( e->loc.x, e->loc.y, e->loc.z );
    // rotate
    glRotatef( e->ori.x, 1, 0, 0 );
    glRotatef( e->ori.y, 0, 1, 0 );
    glRotatef( e->ori.z, 0, 0, 1 );
    // scale
    glScalef( e->sca.x, e->sca.y, e->sca.z );
    
    // color
    glColor4f( e->col.x, e->col.y, e->col.z, e->alpha );
    
    // render
    e->render();
    
    // pop
    glPopMatrix();
    
}





