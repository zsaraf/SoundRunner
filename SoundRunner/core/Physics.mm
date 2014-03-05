//
//  Physics.mm
//  GLamorHD2
//
//  Created by JP Wright on 1/29/14.
//  Copyright (c) 2014 Ge Wang. All rights reserved.
//

#import "Physics.h"



GLfloat dot_product( Vector3D * a, Vector3D * b)
{
    return a->x * b->x   +   a->y * b->y   +   a->z * b->z;
}


Vector3D * calculate_midpoint( Vector3D *ptA, Vector3D *ptB )
{
    return new Vector3D( (ptA->x + ptB->x) / 2 , (ptA->y + ptB->y) / 2, (ptA->z + ptB->z) / 2 );
}

// only works for two dimensions
Vector3D * tangent( Vector3D * norm )
{
    return new Vector3D(-norm->y, norm->x, norm->z);
}


/** Returns a new vector connecting two points. Vector pointing from ptA Vector to ptB.
 */
Vector3D * connection_vector( Vector3D *ptA, Vector3D *ptB )
{
    return new Vector3D( ptB->x - ptA->x, ptB->y - ptA->y, ptB->z - ptA->z );
}

// normalize a vector so it is of length one but pointing in the right direction
void normalize( Vector3D * vec )
{
    
    GLfloat mag = magnitude(vec);
    vec->set(vec->x/mag, vec->y/mag, vec->z/mag);
}


GLfloat magnitude( Vector3D * vec )
{
    return powf( vec->x*vec->x + vec->y*vec->y + vec->z*vec->z, 0.5);
}

/** Distance between two points--the magnitude of the vector con
 *  connecting two points.
 */
GLfloat distance_two_points( Vector3D *ptA, Vector3D *ptB )
{
    return powf( powf( ptA->x - ptB->x, 2 ) + powf( ptA->y - ptB->y, 2 ) + powf( ptA->z - ptB->z, 2 ), 0.5 );
}

