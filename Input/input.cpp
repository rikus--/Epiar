/*
 * Filename      : input.cpp
 * Author(s)     : Chris Thielen (chris@luethy.net)
 * Date Created  : Sunday, June 4, 2006
 * Last Modified : Saturday, January 5, 2008
 * Purpose       : 
 * Notes         :
 */

#include "includes.h"
#include "Input/input.h"
#include "Sprites/player.h"
#include "UI/ui.h"
#include "Utilities/log.h"
#include "Graphics/video.h"

Input::Input() {
	memset( keyDown, 0, sizeof( bool ) * SDLK_LAST );
}

bool Input::Update( void ) {
	SDL_Event event;
	bool quitSignal = false;

	while( SDL_PollEvent( &event ) ) {
		switch( event.type ) {
			case SDL_QUIT:
				quitSignal = true;
				break;
			case SDL_KEYDOWN:
			{
				bool quitSignalUpdate = _UpdateHandleKeyDown( &event );
				if( quitSignalUpdate ) quitSignal = quitSignalUpdate;
				break;
			}
			case SDL_KEYUP:
			{
				bool quitSignalUpdate = _UpdateHandleKeyUp( &event );
				if( quitSignalUpdate ) quitSignal = quitSignalUpdate;
				break;
			}
			case SDL_MOUSEMOTION:
			{
				_UpdateHandleMouseMotion( &event );
				break;
			}
			case SDL_MOUSEBUTTONUP:
			{
				_UpdateHandleMouseUp( &event );				
				break;
			}
			case SDL_MOUSEBUTTONDOWN:
			{
				_UpdateHandleMouseDown( &event );				
				break;
			}
			default:
				break;
		}
	}
	
	// the list of sub-input systems that handle events
	UI::HandleInput( events ); // anything the UI doesn't care about will be left in the list for the next subsystem
	Handle( events ); // default handler. player motion is handled here

	events.clear();
	
	// this could be false - returning quitSignal doesn't imply quitting
	return quitSignal;
}

void Input::_UpdateHandleMouseMotion( SDL_Event *event ) {
	assert( event );

	Uint16 x, y;

	// translate so (0,0) is lower-left of screen
	x = event->motion.x;
	y = Video::GetHeight() - event->motion.y;
	
	events.push_front( InputEvent( MOUSE, MOUSEMOTION, x, y ) );
}

void Input::_UpdateHandleMouseDown( SDL_Event *event ) {
	assert( event );

	Uint16 x, y;
	
	// translate so (0,0) is lower-left of screen
	x = event->button.x;
	y = Video::GetHeight() - event->button.y;

	events.push_front( InputEvent( MOUSE, MOUSEDOWN, x, y ) );
}

void Input::_UpdateHandleMouseUp( SDL_Event *event ) {
	assert( event );

	Uint16 x, y;
	
	// translate so (0,0) is lower-left of screen					
	x = event->button.x;
	y = Video::GetHeight() - event->button.y;

	events.push_front( InputEvent( MOUSE, MOUSEUP, x, y ) );
}

bool Input::_UpdateHandleKeyDown( SDL_Event *event ) {
	bool quitSignal = false;
	
	assert( event );

	switch( event->key.keysym.sym ) {
		case SDLK_ESCAPE:
			quitSignal = true;
			break;
		default:
			events.push_front( InputEvent( KEY, KEYDOWN, event->key.keysym.sym ) );
			keyDown[ event->key.keysym.sym ] = 1;
			break;
	}

	return quitSignal;
}

bool Input::_UpdateHandleKeyUp( SDL_Event *event ) {
	bool quitSignal = false;
	
	assert( event );

	switch( event->key.keysym.sym ) {
		case SDLK_ESCAPE:
			quitSignal = true;
			break;
		default:
			events.push_front( InputEvent( KEY, KEYUP, event->key.keysym.sym ) );
			keyDown[ event->key.keysym.sym ] = 0;
			break;
	}

	return quitSignal;
}

void Input::Handle( list<InputEvent> & events ) {
	Player *player = Player::Instance();

	if( keyDown[ SDLK_LEFT ] ) player->Rotate( _LEFT );
	if( keyDown[ SDLK_RIGHT ] ) player->Rotate( _RIGHT );
	if( keyDown[ SDLK_UP ] ) player->Accelerate();
	if( keyDown[ SDLK_g] ) {
		static int used = 0;
		if(used == 0)
			ui_demo();
		used = 1;
	}
}