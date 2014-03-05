//
//  Physics.h
//  GLamorHD2
//
//  Created by JP Wright on 1/29/14.
//  Copyright (c) 2014 Ge Wang. All rights reserved.
//


#ifndef __PHYSICS_H__
#define __PHYSICS_H__


#import <Foundation/Foundation.h>
#import <math.h>
#import "mo_gfx.h"



GLfloat dot_product( Vector3D * a, Vector3D * b);

// returns midpoint between two GLvertices
Vector3D * calculate_midpoint( Vector3D *ptA, Vector3D *ptB );

// given a norm vector, returns the tangent vector but only works for two dimensional vectors
Vector3D * tangent( Vector3D * norm);

// Returns a new vector connecting two points.
//Vector pointing from second Vector to first.
Vector3D * connection_vector( Vector3D *ptA, Vector3D *ptB );

// normalize a vector so it is of length one but pointing in the right direction
void normalize( Vector3D * vec );
GLfloat magnitude( Vector3D * vec );

// returns the distance between two points
GLfloat distance_two_points( Vector3D *ptA, Vector3D *ptB );

// normalize a vector so it still points in same direction but is magnitude one.
void normalize( Vector3D * vec );



    

#endif