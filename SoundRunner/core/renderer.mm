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
#import "Entity.h"
#import "gex-basssynth.h"
using namespace std;


#define SRATE 24000
#define FRAMESIZE 512
#define NUM_CHANNELS 2
#define NUM_PARTICLES 1000



// -------------------instance variables-------------------
// --------------------------------------------------------
GLfloat g_waveformWidth = 2;
GLfloat g_gfxWidth = 1024;
GLfloat g_gfxHeight = 640;
GLfloat g_ratio = g_gfxWidth / g_gfxHeight;
GLfloat leftClip = -g_ratio;
GLfloat rightClip = g_ratio;

// buffer
UInt32 g_numFrames;

// graphics stuffs
Entity * g_avatar;
std::vector<Entity *> g_entities;
GLfloat nextAvatarX = 0.0;


// placeholder for audio
GeXBASSSynth * g_synth;
// number of voices
int numVoices = 32;

// time keepingstuffs
double lastTime = 0.0;
double timePerBeat = 1/(Globals::BPM/60.0); // seconds per beat
bool newBeat = false;




// -------------------function prototypes------------------
// --------------------------------------------------------

Entity * makeAvatar(float x, float y);
void renderEntities();
void renderSingleEntity(Entity * e);
void makeParticleSystem();


//-----------------------------------------------------------------------------
// name: audio_callback()
// desc: audio callback, yeah
//-----------------------------------------------------------------------------
void audio_callback( Float32 * buffer, UInt32 numFrames, void * userData )
{
    for( int i = 0; i < numFrames; i++ )
    {
        // zero out for now so we don't get mic input coming out!
        buffer[2*i] = buffer[2*i+1] = 0;
    }
    
    g_synth->synthesize2(buffer, numFrames);
    
    // save the num frames
    g_numFrames = numFrames;
    
    
    // NSLog( @"." );
}


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
                //NSLog( @"touch began... %f %f", x, y );
                g_avatar->col.set(0.0, 0.0, 0.0);
                g_synth->noteOn(0, 440.0, 126);
                

//                if (newBeat)
//                {
//                    // turn note on!
//                    g_synth->noteOn(0, 220.0, 100);
//                    newBeat = false;
//                }
                break;
            }
            // --------------------------------------------
            // -------------touch stationary---------------
            case UITouchPhaseStationary:
            {
                
                //NSLog( @"touch stationary... %f %f", pt.x, pt.y );
//                if (newBeat)
//                {
//                    // turn note on!
//                    g_synth->noteOn(0, 220.0, 100);
//
//                    newBeat = false;
//
//                    
//                }
                
                break;
            }
                
            // --------------------------------------------
            // ---------------touch moved------------------
            case UITouchPhaseMoved:
            {
                //NSLog( @"touch moved... %f %f", pt.x, pt.y );
                // GL coordinates
                // NSLog( @"touch moved... %f %f", x, y );
//                if (newBeat)
//                {
//                    // turn note on!
//                    g_synth->noteOn(0, 220.0, 100);
//
//                    newBeat = false;
//                }
                
                break;
            }
                
            // --------------------------------------------
            // ---------------touch ended------------------
            case UITouchPhaseEnded:
            {
                //NSLog( @"touch ended... %f %f", x, y );
                g_avatar->col.set(1.0, 1.0, 1.0);
                g_synth->noteOff(0, 220.0);
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


void moveAvatar(float displacement)
{
    nextAvatarX = g_avatar->loc.x + displacement;
}



// initialize the engine (audio, grx, interaction)
void RunnerInit()
{
    NSLog( @"init..." );
    
    // set touch callback
    MoTouch::addCallback( touch_callback, NULL );
    
    // generate texture name
    glGenTextures( 1, &Globals::g_texture[0] );
    // bind the texture
    glBindTexture( GL_TEXTURE_2D, Globals::g_texture[0] );
    // setting parameters
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
    
    // load the texture
    MoGfx::loadTexture( @"flare-tng-3", @"png" );
    
    
    
    GLfloat ratio = g_gfxWidth / g_gfxHeight;
    
    // init bass (soundfont player)
    g_synth = new GeXBASSSynth();
    g_synth->init(SRATE, numVoices);
    g_synth->load("GeneralUser_GS_FluidSynth_v1.44.sf2");
    

//    g_synth->programChange( 0, 0 );
//    g_synth->programChange( 1, 79 );
//    g_synth->programChange( 2, 4 );
//    g_synth->programChange( 3, 10 );
//    g_synth->programChange( 4, 13 );
    
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
    
    g_avatar = makeAvatar(0.0, 0.0);
    makeParticleSystem();
}



void moveCamera(GLfloat inc)
{
    leftClip += inc;
    
    rightClip += inc;
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
        e->alpha = .60;
        // set velocity
        e->vel.set( 0.0, -1.5, 0.0);
        // set location
        e->loc.set( x, y, 0 );
        // set color
        e->col.set( 1.0, 1.0, 1.0 );
        // set scale
        e->sca.setAll( .6 );
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
        // random x location
        part->loc.x = 10*( (rand() / (float)RAND_MAX) - 0.5 );
        // random y location between -1 and1
        part->loc.y = 2*g_ratio*( (rand() / (float)RAND_MAX) - 0.5 );
        part->loc.z = 0;
        // alpha
        part->alpha = 1.0;
        // scale
        part->sca.setAll( 0.3 );
        // color
        part->col.set(1.0, 1.0, 1.0);
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
    g_avatar = makeAvatar(nextAvatarX, 0.0);

    // refresh current time reading (in microseconds)
    double currTime = MoGfx::getCurrentTime( true );
    
    
    
    // if the duration of a beat has passed
    if (currTime - lastTime >= timePerBeat && !newBeat)
    {
        // update the lastTime
        lastTime = currTime;
        // turn off anything that is playing
        
        // tell touch callback that a note can be played.
        newBeat = true;

    }
    
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
    
    
    glClearColor( 0, 1, 1, 0.85); // turquoize
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





