/*
 * Filename      : ui_widget.h
 * Author(s)     : Chris Thielen (chris@luethy.net)
 * Date Created  : Unknown (2006?)
 * Last Modified : Saturday, January 5, 2008
 * Purpose       : 
 * Notes         :
 */

#ifndef __H_UI_WIDGET__
#define __H_UI_WIDGET__

class Widget {
	public:
		Widget() { };
		virtual ~Widget() { };
		
		bool AddChild( Widget *widget );
		virtual void Draw( int relx = 0, int rely = 0 );
		virtual void Update( void );

		int GetX( void ) { return x; }
		int GetY( void ) { return y; }
		void SetX( int x ) { this->x = x; }
		void SetY( int y ) { this->y = y; }

		// This is called when a widget obtains focus (in case it wants to highlight itself or something)
		virtual void Focus( int x, int y ) {
			dragX = x - this->x;
			dragY = this->y - y;
		};
		virtual void Unfocus( void ) {};
		int GetDragX( void ) { return dragX; }
		int GetDragY( void ) { return dragY; }
		
		virtual int GetWidth( void ) = 0;
		virtual int GetHeight( void ) = 0;
	
		Widget *DetermineMouseFocus( int x, int y );
		virtual void MouseDown( int wx, int wy ) {}; // coords of mouse down, relative to widget's upper left (0,0)
	
	private:
		int x, y;
		int dragX, dragY; // if dragging, this is the offset from (x,y) to the point of click for the drag
		list<Widget *> children;
};

#endif // __H_UI_WIDGET__