/*
 * Filename      : camera.cpp
 * Author(s)     : Chris Thielen (chris@luethy.net)
 * Date Created  : Unknown (2006?)
 * Last Modified : Saturday, January 5, 2008
 * Purpose       : 
 * Notes         :
 */

#include "Graphics/video.h"
#include "includes.h"
#include "Utilities/camera.h"
#include "Utilities/log.h"

Camera *Camera::pInstance = 0; // initialize pointer

Camera *Camera::Instance( void ) {
	if( pInstance == 0 ) { // is this the first call?
		pInstance = new Camera; // create the sold instance
	}
	return( pInstance );
}

Camera::Camera( void ) {
	x = 0;
	y = 0;
	dx = 0;
	dy = 0;
	focusSprite = NULL;
	zoom = 1.;
	hasZoomed = true;
}

void Camera::Focus( double x, double y ) {
	// calculate the difference (this is used in many conversions)
	dx = x - this->x;
	dy = y - this->y;

	this->x += dx;
	this->y += dy;
	
	// assign the new camera position
	//if(hasZoomed){
		//this->x = x;
		//this->y = y;
		//hasZoomed=true;
	//} else {
		//this->x = x;
		//this->y = y;
		//hasZoomed=false;
	//}
}

void Camera::Focus( Sprite *sprite ) {
	focusSprite = sprite;
}

// Converts world to screen coordinates
void Camera::Translate( Coordinate &world, Coordinate &screen ) {
	int tx, ty;

	tx = (int)(world.GetX() - x + Video::GetHalfWidth());
	ty = (int)(world.GetY() - y + Video::GetHalfHeight());
	
	screen.SetX( tx );
	screen.SetY( ty );
}

// returns the most recent camera position change
void Camera::GetDelta( double *dx, double *dy ) {
	if( !dx || !dy ) {

		Log::Warning( "dx/dy are NULL pointers!" );

		return;
	}
	
	*dx = this->dx;
	*dy = this->dy;
}

// moves the camera by a delta. this is not the recommended way to move the camera
void Camera::Move( int dx, int dy ) {
	this->dx = -dx;
	this->dy = -dy;

	x -= dx;
	y -= dy;
}

// updates camera, including currently focused position
void Camera::Update( void ) {
	if( focusSprite ) {
		Coordinate pos = focusSprite->GetWorldPosition();
		Focus( pos.GetX(), pos.GetY() );
	}
}

// "Shakes" the camera (as eye candy for battles)
void Camera::Shake( Uint32 duration ) {
	// TODO: write me
}