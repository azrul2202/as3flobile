/**
 * <p>Original Author: toddanderson</p>
 * <p>Class File: HorizontalScrollViewportStrategy.as</p>
 * <p>Version: 0.1</p>
 *
 * <p>Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:</p>
 *
 * <p>The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.</p>
 *
 * <p>THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.</p>
 *
 * <p>Licensed under The MIT License</p>
 * <p>Redistributions of files must retain the above copyright notice.</p>
 */
package com.custardbelly.as3flobile.view.viewport.context
{
	import com.custardbelly.as3flobile.model.ScrollMark;
	import com.custardbelly.as3flobile.view.viewport.IScrollViewport;
	import com.custardbelly.as3flobile.view.viewport.IScrollViewportDelegate;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	
	
	/**
	 * HorizontalScrollViewportStrategy is an IScrollViewportStrategy implementation to mediate scrolling operations along the x-axis of a target IScrollViewport.
	 * @author toddanderson
	 */
	// Based on : http://github.com/davidaurelio/TouchScroll/blob/master/src/touchscroll.js
	public class HorizontalScrollViewportStrategy implements IScrollViewportStrategy
	{
		protected var _content:DisplayObject;
		protected var _bounds:Rectangle;
		protected var _delegate:IScrollViewportDelegate;
		
		protected var _currentScrollPosition:Number;
		protected var _scrollBoundsLeft:int;
		protected var _scrollBoundsRight:int;
		protected var _scrollAreaWidth:int;
		protected var _threshold:Number;
		protected var _velocity:Number;
		
		protected var _marks:Vector.<ScrollMark>;
		protected var _markIndex:uint;
		
		protected var _coordinate:Point;
		
		protected var _framerate:int = 24;
		protected var _damp:Number;
		
		public static const DAMP:Number = 0.95;
		public static const THRESHOLD:Number = 0.01;
		public static const VECTOR_MIN:Number = 0.01;
		public static const VECTOR_MAX:int = 60;
		public static const VECTOR_MULTIPLIER:Number = 0.25;
		public static const RETURN_TIME:int = 70;
		public static const CAPACITY:uint = 20;
		
		/**
		 * Constructor.
		 */
		public function HorizontalScrollViewportStrategy() {}
		
		/**
		 * @private 
		 * 
		 * Initializes any necessary values usedin mediating and determining scroll.
		 */
		protected function initialize():void
		{
			_velocity = 0;
			_currentScrollPosition = 0;
			_content.x = _content.y = _currentScrollPosition;
			
			_scrollBoundsLeft = _bounds.x;
			_scrollAreaWidth = _bounds.width - _bounds.x;
			_scrollBoundsRight =  _scrollAreaWidth - ( isNaN( _content.width ) ? 0 : _content.width );
			
			_damp = DAMP;
			_threshold = VerticalScrollViewportStrategy.THRESHOLD * _bounds.width;
			
			// Create marks and fill with capacity.
			if( _marks == null )
				_marks = new Vector.<ScrollMark>( HorizontalScrollViewportStrategy.CAPACITY );
			
			var i:int;
			for( i = 0; i < HorizontalScrollViewportStrategy.CAPACITY; i++ )
			{
				_marks[i] = ScrollMark.getScrollMark( 0, 0, 0 );
			}
			
			// Crate coordinate point used in notify delegates of aniimation.
			if( _coordinate == null ) _coordinate = new Point();
			_coordinate.x = _coordinate.y = 0;
		}
		
		/**
		 * @private
		 * 
		 * Adds a mark to the revolving list to be used to determine passing of time and distance between marks in a scroll operation. 
		 * @param x Number
		 * @param time Number
		 * @return ScrollMark
		 */
		protected function addMark( x:Number, time:Number ):ScrollMark
		{
			var index:uint = _markIndex;
			
			if( ++_markIndex == HorizontalScrollViewportStrategy.CAPACITY )
				_markIndex = 0;
			
			_marks[index].x = x;
			_marks[index].time = time;
			return _marks[index];
		}
		
		/**
		 * @private
		 * 
		 * Returns the recently added mark to the revolving list. 
		 * @return ScrollMark
		 */
		protected function recentMark():ScrollMark
		{
			var index:uint = ( _markIndex == 0 ) ? _marks.length - 1 : _markIndex - 1;
			return _marks[index];
		}
		
		/**
		 * @private
		 * 
		 * Returns the crossover percentage between current time and the previous time values.
		 * @param value Length of time between current scroll mark and min passage of time.
		 * @param valueMin Previous time of scroll mark.
		 * @param valueMax Recent time of scroll mark.
		 * @param targetMin Minimum value.
		 * @param targetMax Maximum value.
		 * @return Number
		 */
		protected function linearMap( value:Number, valueMin:Number, valueMax:Number, targetMin:Number, targetMax:Number ):Number
		{
			var zeroValue:Number = value - valueMin;
			var maxRange:Number = valueMax - valueMin;
			var valueRange:Number = ( maxRange > 1 ) ? maxRange : 1;
			var targetRange:Number = targetMax - targetMin;
			var zeroTargetValue:Number = zeroValue * ( targetRange / valueRange );
			var targetValue:Number = zeroTargetValue + targetMin;
			return targetValue;
		}
		
		/**
		 * @private
		 * 
		 * Creates a new value point from a specified range of points based on crossover.
		 * @param from Number
		 * @param to Number
		 * @param percent Number
		 * @return Number
		 */
		protected function interpolate( from:Number, to:Number, percent:Number ):Number
		{
			return ( from * ( 1 - percent ) ) + ( to * percent );
		}
		
		/**
		 * @private
		 * 
		 * Limits the current position to the boundaries specified in the target viewport.
		 */
		protected function limitPosition():void
		{
			if( _currentScrollPosition > _scrollBoundsLeft )
			{
				_currentScrollPosition = _scrollBoundsLeft;
			}
			else if( _currentScrollPosition < _scrollBoundsRight )
			{
				_currentScrollPosition = _scrollBoundsRight;
			}
		}
		
		/**
		 * @private 
		 * 
		 * Begins an animated sequence for scrolling.
		 */
		protected function startAnimate():void
		{
			// Use ENTER_FRAME to update position based on velocity.
			if( !_content.hasEventListener( Event.ENTER_FRAME ) )
			{
				_content.addEventListener( Event.ENTER_FRAME, animate, false, 0, true );
			}
		}
		
		/**
		 * @private 
		 * 
		 * Ends an animated sequence for scrolling.
		 */
		protected function endAnimate():void
		{
			// Remove enter frame handler.
			_content.removeEventListener( Event.ENTER_FRAME, animate, false );
			// Notify delegate of end.
			if( _delegate )
			{
				_coordinate.x = _currentScrollPosition;
				_delegate.scrollViewDidEnd( _coordinate );
			}
			
			// Remove previously held values on mark list.
			var i:int;
			var mark:ScrollMark;
			for( i = 0; i < HorizontalScrollViewportStrategy.CAPACITY; i++ )
			{
				mark = _marks[i];
				mark.x = mark.y = mark.time = 0;
			}
			_markIndex = 0;
		}
		
		/**
		 * @private
		 * 
		 * Handler for animation of scroll. May be invoked throuhg event system or directly. 
		 * @param evt Event
		 */
		protected function animate( evt:Event = null ):void
		{
			// Update current positon with velocity.
			_currentScrollPosition += _velocity;
			// Limit the position.
			limitPosition();
			// Set the position of target content along the x-axis.
			_content.x = _currentScrollPosition;
			
			// IF we have stopped moving, stop moving.
			if( _velocity == 0 ) return;
			// Notify delegate of animation.
			if( _delegate )
			{
				_coordinate.x = _currentScrollPosition;
				_delegate.scrollViewDidAnimate( _coordinate );
			}
			
			// Damp the velocity.
			_velocity *= _damp;
			// If our velocity has gone below the minimum threshold of movement, stop.
			var velAbs:Number = ( _velocity > 0.0 ) ? _velocity : -_velocity;
			if( velAbs < HorizontalScrollViewportStrategy.VECTOR_MIN )
			{
				_velocity = 0;
				endAnimate();
			}
		}
		
		/**
		 * @copy IScrollViewportStrategy#start()
		 */
		public function start( point:Point ):void
		{
			// Notify delegate of end.
			if( _delegate )
			{
				_coordinate.x = _currentScrollPosition;
				_delegate.scrollViewDidEnd( _coordinate );
			}
			
			// Start from the top.
			_velocity = 0;
			_markIndex = 0;
			
			// Add mark to revolving list.
			addMark( point.x, getTimer() );
			// Start the animation session.
			startAnimate();
			
			// Notify the delegate of start.
			if( _delegate )
			{
				_coordinate.x = _currentScrollPosition;
				_delegate.scrollViewDidStart( _coordinate );
			}
		}
		
		/**
		 * @copy IScrollViewportStrategy#move()
		 */
		public function move( point:Point ):void
		{
			// Grab reference to last mark.
			var previousMark:ScrollMark = recentMark();
			// Store reference to current mark.
			var currentMark:ScrollMark = addMark( point.x, getTimer() );
			
			// * This method is simply a move of point along the x-axis, it is not a running update on animation,
			//		as such, we clamp down on velocity.
			
			// Update velocity and position.
			_velocity = 0;
			_currentScrollPosition += currentMark.x - previousMark.x;
			limitPosition();
			
			// Notify client of animate.
			if( _delegate )
			{
				_coordinate.x = _currentScrollPosition;
				_delegate.scrollViewDidAnimate( _coordinate );
			}
		}
		
		/**
		 * @copy IScrollViewportStrategy#end()
		 */
		public function end( point:Point ):void
		{
			var previousMark:ScrollMark = recentMark();
			var currentMark:ScrollMark = addMark( point.x, getTimer() );
			
			// Update position.
			_currentScrollPosition += currentMark.x - previousMark.x;
			limitPosition();
			
			// Find the most recent mark related to the crossover.
			var crossover:Number = currentMark.time - HorizontalScrollViewportStrategy.RETURN_TIME;
			var recentIndex:uint;
			var i:uint;
			var length:uint = _marks.length;
			var mark:ScrollMark;
			find: while( i++ < length - 1 )
			{
				mark = _marks[i];
				if( mark.time > crossover )
				{
					recentIndex  = i;
					break find;
				}
			}
			if( recentIndex == 0 ) recentIndex = 1;
			
			// Grab the two related marks based on the difference within time.
			var recentMark:ScrollMark = _marks[recentIndex];
			previousMark = _marks[int(recentIndex - 1)];
			// Determine the threshold and new point.
			var crossoverPercent:Number = linearMap( crossover, previousMark.time, recentMark.time, 0, 1 );
			var newPoint:Number = interpolate( previousMark.x, recentMark.x, crossoverPercent );
			var threshold:Number = currentMark.x - newPoint;
			var absoluteThreshold:Number = ( threshold > 0.0 ) ? threshold : -threshold;
			
			// If we haven't reach our threshold, our latest point is the current one.
			if( absoluteThreshold < _threshold )
			{
				newPoint = currentMark.x;
			}
			// If we have determined that the newest point is the current one, then we have stopped animating.
			if( currentMark.x == newPoint )
			{
				endAnimate();
				return;
			}
			// Update the velocity.
			var velocity:Number = threshold * HorizontalScrollViewportStrategy.VECTOR_MULTIPLIER;
			var absoluteVelocity:Number = ( velocity > 0.0 ) ? velocity : -velocity;
			// If we have reached our max velocity, start slowing down.
			if( absoluteVelocity >= HorizontalScrollViewportStrategy.VECTOR_MAX )
			{
				var factor:Number = HorizontalScrollViewportStrategy.VECTOR_MAX / absoluteVelocity;
				velocity *= factor;
			}
			_velocity = velocity;
		}
		
		/**
		 * @copy IScrollViewportStrategy#mediate()
		 */
		public function mediate( viewport:IScrollViewport ):void
		{
			// Hold refernces to properties on the IScrollViewport for ease of operations.
			_content = viewport.content;
			_bounds = viewport.scrollRect;
			_delegate = viewport.delegate;
			// If we have the minimum of what is needed, initialize.
			if( _content && _bounds )
				initialize();
		}
		
		/**
		 * @copy IScrollViewportStrategy#unmediate()
		 */
		public function unmediate():void
		{
			// Kill handlers.
			if( _content ) _content.removeEventListener( Event.ENTER_FRAME, animate, false );
			// Return marks.
			if( _marks != null )
			{
				var i:int;
				var length:int = _marks.length;
				var mark:ScrollMark;
				for( i = 0; i < length; i++ )
				{
					mark = _marks[i];
					ScrollMark.returnScrollMark( mark );
				}
			}
		}
	}
}