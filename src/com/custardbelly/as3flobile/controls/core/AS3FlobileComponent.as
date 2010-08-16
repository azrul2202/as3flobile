/**
 * <p>Original Author: toddanderson</p>
 * <p>Class File: AS3FlobileComponent.as</p>
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
package com.custardbelly.as3flobile.controls.core
{
	import com.custardbelly.as3flobile.model.IDisposable;
	import com.custardbelly.as3flobile.skin.ISkin;
	import com.custardbelly.as3flobile.skin.ISkinnable;
	
	import flash.display.Sprite;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	
	/**
	 * AS3FlobileComponent is a base component for all components in the as3flobile package. 
	 * @author toddanderson
	 */
	public class AS3FlobileComponent extends Sprite implements IDisposable, ISkinnable
	{
		protected var _skin:ISkin;
		protected var _skinState:int;
		
		protected var _width:int = 100;
		protected var _height:int = 100;
		
		/**
		 * Constructor. 
		 */
		public function AS3FlobileComponent() 
		{
			initialize();
			createChildren();
			initializeDisplay();
			updateDisplay();
		}
		
		/**
		 * @private 
		 * 
		 * Initializes any necessary property values.
		 */
		protected function initialize():void
		{
			// abstract. Meant for override. 
		}
		
		/**
		 * @private 
		 * 
		 * Creates any necessary display chidren.
		 */
		protected function createChildren():void
		{
			// abstract. Meant for override. 
		}
		
		/**
		 * @private 
		 * 
		 * Initialize the display using newly created members and properties.
		 */
		protected function initializeDisplay():void
		{
			if( _skin != null ) _skin.initializeDisplay( _width, _height );
		}
		
		/**
		 * @private 
		 * 
		 * Redraws any display content.
		 */
		protected function updateDisplay():void
		{
			if( _skin != null ) _skin.updateDisplay( width, height );
		}
		
		/**
		 * @private 
		 * 
		 * Handles any operations related to size change.
		 */
		protected function invalidateSize():void
		{
			updateDisplay();
		}
		
		/**
		 * @private 
		 * 
		 * Handles any operations related to the state of this component in relation to its skin.
		 */
		protected function invalidateSkinState():void
		{
			updateDisplay();
		}
		
		/**
		 * @private 
		 * 
		 * Invalidates the supplied skin through the skin modifier.
		 */
		protected function invalidateSkin():void
		{
			_skin.target = this;
			initializeDisplay();
			updateDisplay();
		}
		
		/**
		 * Returns flag of this instance being on the display list. 
		 * @return Boolean
		 */
		public function isOnDisplayList():Boolean
		{
			return ( stage != null );
		}
		
		/**
		 * Returns flag of this instance being on the display list and visible for rendering. 
		 * @return Boolean
		 */
		public function isActiveOnDisplayList():Boolean
		{
			return isOnDisplayList() && visible;
		}
		
		/**
		 * @copy IDisposable#dispose()
		 */
		public function dispose():void
		{
			if( _skin != null )
			{
				_skin.dispose();
				_skin = null;
			}
		}
		
		/**
		 * @copy ISkinnable#skin
		 */
		public function get skin():ISkin
		{
			return _skin;
		}
		public function set skin( value:ISkin ):void
		{
			if( _skin == value ) return;
			
			_skin = value;
			invalidateSkin();
		}
		
		/**
		 * @opy ISkinnable#skinState
		 */
		public function get skinState():int
		{
			return _skinState;
		}
		public function set skinState( value:int ):void
		{
			if( _skinState == value ) return;
			
			_skinState = value;
			invalidateSkinState();
		}
		
		/**
		 * Accessor/Modifier for the width of this display. 
		 * @return Number
		 */
		override public function get width():Number
		{
			return _width;
		}
		override public function set width(value:Number):void
		{
			if( _width == value ) return;
			
			_width = value;
			invalidateSize();
		}
		
		/**
		 * Accessor/Modifier for the height of this display. 
		 * @return Number
		 */
		override public function get height():Number
		{
			return _height;
		}
		override public function set height(value:Number):void
		{
			if( _height == value ) return;
			
			_height = value;
			invalidateSize();
		}
	}
}