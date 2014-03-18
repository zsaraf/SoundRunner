//
//  renderer.mm
//  SoundRunner
//
//  Created by JP Wright on 2/26/14.
//  Copyright (c) 2014 Zachary Waleed Saraf. All rights reserved.
//

#import "renderer.h"
#import <math.h>
#import "NetworkManager.h"

#import "Globals.h"
#import "Scale.h"
#import "SoundRunnerUtil.h"
#import "Physics.h"
#import <stdlib.h>
#import "SoundGen.h"
#import "OtherPlayer.h"
#import "Drummer.h"
using namespace std;


#define SRATE 24000
#define FRAMESIZE 512
#define NUM_CHANNELS 2
#define NUM_PARTICLES 1000

#define NUM_NICE_COLORS 4

static const GLfloat niceColors[] = {
    52/255.,  152/255., 219/255., // rgba(52, 152, 219,1.0)
    155/255.,  89/255., 182/255., // rgba(155, 89, 182,1.0)
    46/255.,   204/255., 113/255., // rgba(46, 204, 113,1.0)
    243/255., 156/255., 18/255.// rgba(243, 156, 18,1.0)
};


// -------------------instance variables-------------------
// --------------------------------------------------------
GLfloat g_gfxWidth = 1024;
GLfloat g_gfxHeight = 640;
GLfloat g_ratio = g_gfxWidth / g_gfxHeight;

GLfloat leftClip = -g_ratio;
GLfloat rightClip = g_ratio;
GLfloat avatarYStart = 0.3;
// buffer
UInt32 g_numFrames;

// graphics stuffs
Entity * g_avatar = NULL;
Entity * g_scrollmap;
Entity * g_scrollAvatar;
std::vector<Entity *> g_entities;
std::vector<Entity *> g_tail;

std::vector<Entity *> g_particles;
GLfloat nextAvatarX = 0.0;
int numNotesInScale = 20;//Scales::numNotesPerScale;

// audio stuffs
SoundGen * soundGen;
// number of voices
int numVoices = 32;

// time keepingstuffs
double lastTime = 0.0;
int samplesPerBeat = SRATE * 1/(Globals::BPM/60.0); // samples per beat
bool newBeat = false;
bool touch_down = false;

int sampCount = 0;

// -------------------function prototypes------------------
// --------------------------------------------------------

Entity * makeOtherAvatar (float x, float y);
Entity * makeAvatar(float x, float y);
void renderEntities();
void renderSingleEntity(Entity * e);
void makeParticleSystem();
void makeNoteBoundarys(int numNotes);
void handleCollisions(std::vector<Entity *> * entities, std::vector<Entity *>::iterator p);
// bound the left and right boundaries of the world
void boundClipPlanes(bool * atEdge);
void stopAndStartPlayingMidiNoteForCurrentAvatar ();
Entity * makeScrollMap();
Entity * makeScrollAvatar(ScrollMap * scrollMap, GLfloat * nextAvX);




void moveCamera(GLfloat inc)
{
    float boundConst = 1.3;
    // bound the avatar
    if ( nextAvatarX <= Globals::leftBound + g_ratio*boundConst && leftClip == Globals::leftBound )
    {
        return;
    }
    else if (nextAvatarX >= Globals::rightBound - g_ratio*boundConst && rightClip == Globals::rightBound)
    {
        return;
    }
    
    
    bool atEdge = false;
    // increment the clip
    leftClip += inc;
    rightClip += inc;
    
    boundClipPlanes(&atEdge);
    
    // min distance between clipping planes and avatar when its in motion and away from world bounds.
    GLfloat minBuffer = .8;
    if ( nextAvatarX - leftClip <= minBuffer && !atEdge)
    {
        GLfloat clipGoal = nextAvatarX - minBuffer;
        float slew = 0.8;
        leftClip = (clipGoal - leftClip)*slew + leftClip;
        rightClip = leftClip + g_ratio*2;
        boundClipPlanes(&atEdge);
        //nextAvatarX = leftClip + minBuffer;
        
    }
    if ( rightClip - nextAvatarX <= minBuffer && !atEdge)
    {
        GLfloat clipGoal = nextAvatarX + minBuffer;
        float slew = 0.8;
        rightClip = (clipGoal - rightClip)*slew + rightClip;
        leftClip = rightClip - g_ratio*2;
        boundClipPlanes(&atEdge);

        //nextAvatarX = rightClip - minBuffer;
    }
    
    
}

void boundClipPlanes(bool * atEdge)
{
    if (leftClip <= Globals::leftBound)
    {
        *atEdge = true;
        leftClip = Globals::leftBound;
        rightClip = Globals::leftBound + g_ratio*2;
    }
    // bounding to Globals::rightBound
    
    if (rightClip >= Globals::rightBound)
    {
        *atEdge = true;
        rightClip = Globals::rightBound;
        leftClip = Globals::rightBound - g_ratio*2;
    }
}

// avatar is bounded in the world bounds via its own update function in Entity.mm
void moveAvatar(float displacement)
{
    nextAvatarX = g_avatar->loc.x + displacement*2.;
}


//-----------------------------------------------------------------------------
// name: touch_callback()
// desc: the touch call back
//-----------------------------------------------------------------------------
void touch_callback( NSSet * touches, UIView * view, void * data)
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
                
                stopAndStartPlayingMidiNoteForCurrentAvatar();
                [[NetworkManager instance] sendNoteOn:YES];
                //NSLog( @"touch began... %f %f", x, y );
                
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
                    newBeat = false;
                    
                }
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

                    newBeat = false;

                }

                break;
            }
                
            // --------------------------------------------
            // ---------------touch ended------------------
            case UITouchPhaseEnded:
            {
                // NSLog( @"touch ended... %f %f", x, y );
                g_avatar->col.set(1.0, 1.0, 1.0);
                touch_down = false;
                //NSLog( @"touch ended... %f %f", x, y );
                // note off
                //[soundGen stopPlayingMidiNote:127];
                [soundGen stopPlayingAllNotes];
                [[NetworkManager instance] sendNoteOn:NO];
                newBeat = false;
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




/** handleCollision(std::vector<Entity *> * entities, std::vector<Entity *>::iterator p)
 *  -----------------------------
 *  Arguments std::vector<Entity *> * entities is a pointer to a vector of entity pointers that are the entities that
 *  will be colliding. Also pass in an iterator to the same
 */
void handleCollisions(std::vector<Entity *> * entities, std::vector<Entity *>::iterator p)
{
    std::vector<Entity *>::iterator p2;
    for ( p2 = g_entities.begin(); p2 != g_entities.end(); p2++ )
    {
        // get midpoint between two objects.
        GLfloat distance = distance_two_points( &(*p)->loc, &(*p2)->loc );
        
        // create a connection between the two vectors
        Vector3D * connection = connection_vector( &(*p)->loc, &(*p2)->loc );
        
        // sum the radii
        GLfloat radiiSum = ( (*p)->sca.x + (*p2)->sca.x ) / 2;
        
        // if we aren't comparing at the same projectile and the distance is too short
        if ( (*p) != (*p2) && distance <= radiiSum  )
        {
            // thanks to chets paper and the paper reza sent out :-)
            
            // first correct the distances so that they are now the minimum distance apart
            (*p)->loc =  (*p)->loc + (*connection) * ( (distance - radiiSum ) / (GLfloat)2.0) ;
            (*p2)->loc = (*p2)->loc - (*connection) * ( (distance - radiiSum ) / (GLfloat)2.0) ;
            
            // recompute connection vector and name it unit normal--pointing from p to p2
            Vector3D * unitNormAB = connection_vector( &(*p)->loc, &(*p2)->loc );
            
            // normalize
            normalize( unitNormAB );
            
            // get tangent
            Vector3D * unitTang = tangent( unitNormAB );
            
            // calculate projections-- pointing from A to B
            GLfloat ptA_vel_norm = dot_product( &(*p)->vel , unitNormAB );
            
            // get unit norm poiting in opposite direction from p2 to p (B to A)
            Vector3D * unitNormBA = new Vector3D( *unitNormAB );
            (*unitNormBA) = (*unitNormAB);
            
            GLfloat ptB_vel_norm = dot_product( &(*p2)->vel, unitNormBA );
            
            // remember tangent before = tangent after
            GLfloat ptA_vel_tang = dot_product( &(*p)->vel , unitTang );
            GLfloat ptB_vel_tang = dot_product( &(*p2)->vel , unitTang );
            
            // arbitrary mass values
            GLfloat massA = 1.0;
            GLfloat massB = 1.0;
            
            // calculate norm velocity projections after collisions [derived from elastic collision equations]
            GLfloat ptA_vel_norm_after = ptA_vel_norm * (massA - massB) + 2 * massB * ptB_vel_norm / (massA + massB);
            GLfloat ptB_vel_norm_after = ptB_vel_norm * (massB - massA) + 2 * massA * ptA_vel_norm / (massA + massB);
            
            
            // final vecocity is scalar norm after collion times norm
            (*p)->vel = (*unitNormAB) * ptA_vel_norm_after + (*unitTang) * ptA_vel_tang;
            (*p2)->vel = (*unitNormBA) * ptB_vel_norm_after + (*unitTang) * ptB_vel_tang;
            
            // cleanup
            delete(connection);
            delete(unitNormAB);
            delete(unitNormBA);
            delete(unitTang);
            
            
    
            //NSLog(@"COLLLISION!");
        }
        
    }
    
}


// initialize the engine (audio, grx, interaction)
void RunnerInit()
{
    NSLog( @"init..." );
    
    // set touch callback
    //MoTouch::addCallback( touch_callback, NULL );
    
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
    
    NSURL *presetURL = [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:@"GeneralUser_GS_FluidSynth_v1" ofType:@"sf2"]];
    [SoundRunnerUtil appDelegate].soundGen = [[SoundGen alloc] initWithSoundFontURL:presetURL bankNumber:120 patchNumber:0];
    soundGen = [SoundRunnerUtil appDelegate].soundGen;
    [SoundRunnerUtil appDelegate].drummer = [[Drummer alloc] init];
    
    g_avatar = makeAvatar(0.0, avatarYStart);
    makeNoteBoundarys(numNotesInScale);
    g_scrollmap = makeScrollMap();
    g_scrollAvatar = makeScrollAvatar((ScrollMap*)g_scrollmap, &nextAvatarX);
    

    makeParticleSystem();
    
}

Entity *getCurrentAvatar ()
{
    return g_avatar;
}

void stopAndStartPlayingMidiNoteForCurrentAvatar ()
{
    GLfloat xInc = (Globals::rightBound - Globals::leftBound) / (float)numNotesInScale;
    int key = (int)((g_avatar->loc.x - Globals::leftBound) / xInc);
    int note = [[Scale instance] noteForKey:key] + 20;
    
    NSLog(@"PLaying note: %d", note);
    
    [soundGen stopPlayingAllNotes];
    [soundGen playMidiNote:note velocity:127];
//    NSLog(@"playing note %d %d", note, key);
}

void stopAndStartPlayingMidiNoteForOtherPlayers()
{
    GLfloat xInc = (Globals::rightBound - Globals::leftBound) / (float)numNotesInScale;
    
    for (NSString *playerName in [SoundRunnerUtil appDelegate].otherPlayers) {
        OtherPlayer *otherPlayer = [[SoundRunnerUtil appDelegate].otherPlayers objectForKey:playerName];
        [otherPlayer.soundGen stopPlayingAllNotes];
        if (otherPlayer.avatar == NULL) {
            otherPlayer.avatar = (OtherAvatar *)makeOtherAvatar(otherPlayer.xLoc, avatarYStart);
        }
        if (otherPlayer.noteOn) {
            int key = (int)((otherPlayer.xLoc - Globals::leftBound) / xInc);
            int note = [[Scale instance] noteForKey:key] + 60;
            [otherPlayer.soundGen playMidiNote:note velocity:127];
        }
    }
}

void RunnerRenderUpdateNote()
{
    [[SoundRunnerUtil appDelegate].drummer tick];
    stopAndStartPlayingMidiNoteForOtherPlayers();
    if ( touch_down)
    {
        stopAndStartPlayingMidiNoteForCurrentAvatar();
        g_avatar->col.set(155/255., 89/255., 182/255.); //rgba(155, 89, 182,1.0)
    }
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

Entity * makeScrollAvatar(ScrollMap * scrollMap, GLfloat * nextAvX)
{
    Entity * e = new ScrollAvatar(scrollMap, nextAvX, 0.05);
    if ( e != NULL )
    {
        //NSLog(@"making new scroll avatar");
        
        // add to g_entities
        g_entities.push_back( e );
        // alpha
        e->alpha = 0.7;
        // set velocity
        e->vel.set( 0.0, 0.0, 0.0);
        // set color
        if (touch_down) {
            e->col.set(244/255.0, 76/255.0, 60/255.0); //rgba(231, 76, 60,1.0)
        } else {
            e->col.set( 1.0, 1.0, 1.0 );
        }
        // set scale
        e->sca.setAll( 1 );
        // activate
        e->active = true;
    }
    return e;
    
    
}


Entity * makeScrollMap()
{
    Entity * e = new ScrollMap(&leftClip, &rightClip);
    if ( e != NULL )
    {
        //NSLog(@"making new avatar");
        
        // add to g_entities
        g_entities.push_back( e );
        // alpha
        e->alpha = 0.05;
        // set velocity
        e->vel.set( 0.0, 0.0, 0.0);
        // set color
        if (touch_down) {
            e->col.set(231/255.0, 76/255.0, 60/255.0); //rgba(231, 76, 60,1.0)
        } else {
            e->col.set( 1.0, 1.0, 1.0 );
        }
        // set scale
        e->sca.setAll( 1 );
        // activate
        e->active = true;
    }
    return e;

    
}





Entity * makeAvatar(float x, float y)
{
    Entity * e = new Avatar(true); // true means velocity is active
    if ( e != NULL )
    {
        //NSLog(@"making new avatar");

        // add to g_entities
        g_tail.push_back( e );
        // alpha
        e->alpha = 1.0;
        // set velocity
        e->vel.set( 0.0, -1.8, -1.0);
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

Entity * makeOtherAvatar (float x, float y)
{
    Entity * e = new OtherAvatar(true); // true means velocity is active
    if ( e != NULL )
    {
        //NSLog(@"making new avatar");
        
        // add to g_entities
        g_entities.push_back( e );
        // alpha
        e->alpha = 1.0;
        // set velocity
        e->vel.set( 0.0, -1.8, -1.0);
        // set location
        e->loc.set( x, y, 0 );
        // set color
        int random_num = rand();
        int color_index = random_num % NUM_NICE_COLORS;
        // color
        e->col.set(niceColors[color_index * 3], niceColors[color_index * 3 + 1], niceColors[color_index * 3 + 2]);
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
        part->vel.y = -.005 + (rand() / (float)RAND_MAX) * .01 - 0.1;
        // alpha
        part->alpha = 1.0;
        // scale
        int random_num = rand();
        
        part->sca.setAll((random_num/(float)RAND_MAX * .04) + .04);

        int color_index = random_num % NUM_NICE_COLORS;
        // color
        part->col.set(niceColors[color_index * 3], niceColors[color_index * 3 + 1], niceColors[color_index * 3 + 2]);
        // active
        part->active = true;
        // insert
        g_entities.push_back(part);
        g_particles.push_back(part);
    }
}


// set graphics dimensions
void RunnerSetDims( GLfloat width, GLfloat height )
{
    NSLog( @"set dims: %f %f", width, height );
    g_gfxWidth = width;
    g_gfxHeight = height;
    
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
    glOrthof( leftClip, rightClip, -1, 1, 1, -1 );
//    glFrustumf(leftClip, rightClip, -1, 1, -1, 1);
//    glDepthMask(GL_TRUE);
//    MoGfx::perspective(30, (rightClip - leftClip)/2, 1, -1);
    // modelview
    glMatrixMode( GL_MODELVIEW );
    // reset
    glLoadIdentity();
    
    // BACKGROUND COLOR
    glClearColor( 22/255.0, 31/255.0, 40/255.0, 1); // rgba(44, 62, 80,1.0)
    glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );
    
    // push
    glPushMatrix();
    
    for (NSString *playerName in [SoundRunnerUtil appDelegate].otherPlayers) {
        OtherPlayer *otherPlayer = [[SoundRunnerUtil appDelegate].otherPlayers objectForKey:playerName];
        if (otherPlayer.avatar != NULL) {
            otherPlayer.avatar->loc.x = (otherPlayer.xLoc - otherPlayer.avatar->loc.x) * .05 + otherPlayer.avatar->loc.x;
        }
    }
    
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
    
    // render tail...HACK: render in reverse for psuedo 3D...
    for ( e = g_tail.end() - 1; e != g_tail.begin(); e--)
    {
        if ( (*e)->active == FALSE )
        {
            delete (*e);
            
            g_tail.erase(e);
            // dont delete that line. a good place to look if weird bugs...
//            e--;
            
            if (g_tail.size() == 0 ) break;
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



