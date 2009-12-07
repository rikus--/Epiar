/**\file			ship.h
 * \author			Chris Thielen (chris@luethy.net)
 * \date			Created: Unknown (2006?)
 * \date			Modified: Friday, November 14, 2009
 * \brief
 * \details
 */


#ifndef __H_SHIP__
#define __H_SHIP__

#include "Engine/models.h"
#include "Sprites/sprite.h"

class Ship : public Sprite {
	public:
		Ship();
		
		bool SetModel( Model *model );
		bool SetFlareAnimation( string filename );
		Sprite *GetSprite();
		string GetModelName();
		
		void Update( void );
		void Rotate( float direction );
		void Accelerate( void );
		void Damage( short int damage );

		void Draw( void );
		
		/* Status functions */
		float directionTowards(Coordinate c);
		float directionTowards(float angle);
		float getHullIntegrityPct();
		
		virtual int GetDrawOrder( void ) {
			return( DRAW_ORDER_SHIP );
		}

	private:
		Model *model;
		Animation *flareAnimation;
		struct {
			/* Related to ship's condition */
			short int hullEnergyAbsorbed; /* hull health - once the hull absorbs to much energy, your ship blows apart, hooray! :) */
			
			/* Flags */
			bool isAccelerating; // cleared by update, set by accelerate (so it's always updated twice a loop)
		} status;
};

#endif // __H_SHIP__