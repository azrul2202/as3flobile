/**
 * <p>Original Author: toddanderson</p>
 * <p>Class File: TextInputSkin.as</p>
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
package com.custardbelly.as3flobile.skin
{
	import com.custardbelly.as3flobile.controls.textinput.TextInput;
	import com.custardbelly.as3flobile.enum.BasicStateEnum;
	
	import flash.display.Graphics;
	import flash.text.TextField;
	import flash.text.TextFormat;

	/**
	 * TextInputSkin is a base skin class for a TextInput control. 
	 * @author toddanderson
	 */
	public class TextInputSkin extends Skin
	{
		protected var _defaultFormat:TextFormat;
		protected var _boilerFormat:TextFormat;
		
		/**
		 * Constructor.
		 */
		public function TextInputSkin() 
		{ 
			super();
			// Create the default and boiler plate formats.
			_defaultFormat = new TextFormat( "DroidSans", 14 );
			_boilerFormat = new TextFormat( "DroidSans", 14, 0xBBBBBB, null, true );
		}
		
		/**
		 * @private
		 * 
		 * Initializes the background display for the control. 
		 * @param display Graphics
		 * @param width int
		 * @param height int
		 */
		protected function initializeBackground( display:Graphics, width:int, height:int ):void
		{
			updateBackground( display, width, height );
		}
		
		/**
		 * @private
		 * 
		 * Initializes the clear button display for the control. 
		 * @param display Graphics
		 * @param width int
		 * @param height int
		 */
		protected function initializeClearDisplay( display:Graphics, width:int, height:int ):void
		{
			updateClearDisplay( display, width, height );
		}
		
		/**
		 * @private
		 * 
		 * Initializes the input display for the control. 
		 * @param display TextField
		 * @param width int
		 * @param height int
		 */
		protected function initializeInput( display:TextField, width:int, height:int ):void
		{
			display.defaultTextFormat = _defaultFormat;
		}
		
		/**
		 * @private
		 * 
		 * Updates the background dislpay for the control. 
		 * @param display Graphics
		 * @param width int
		 * @param height int
		 */
		protected function updateBackground( display:Graphics, width:int, height:int ):void
		{
			var lineColor:uint = ( _target.skinState == BasicStateEnum.FOCUSED ) ? 0xFF7F00 : 0x666666;
			display.clear();
			display.beginFill( 0xFFFFFF );
			display.lineStyle( 2, lineColor, 1, false, "normal", "square", "miter" );
			display.drawRoundRect( 0, 0, width, height, 5, 5 );
			display.endFill();
		}
		
		/**
		 * @private
		 * 
		 * updates the clear button display for the control. 
		 * @param display Graphics
		 * @param width int
		 * @param height int
		 */
		protected function updateClearDisplay( display:Graphics, width:int, height:int ):void
		{
			const offset:int = 4;
			const doubleOffset:int = 8;
			var radius:int = ( height / 2 ) - offset;
			var position:Number = offset + ( radius * 0.5 );
			display.clear();
			display.beginFill( 0xCCCCCC );
			display.drawCircle( width - position - offset, position + offset, radius );
			display.endFill();
			display.lineStyle( 2, 0xFFFFFF, 1, true, "normal", "square", "miter" );
			display.moveTo( width - position - radius, doubleOffset );
			display.lineTo( width - doubleOffset, height - doubleOffset );
			display.moveTo( width - doubleOffset, doubleOffset );
			display.lineTo( width - position - radius, height - doubleOffset );
		}
		
		/**
		 * @private
		 * 
		 * Updates the input display for the control. 
		 * @param display TextField
		 * @param width int
		 * @param height int
		 */
		protected function updateInput( display:TextField, width:int, height:int ):void
		{
			if( _target.skinState == BasicStateEnum.NORMAL )
			{
				var format:TextFormat = ( display.text == ( _target as TextInput ).defaultText ) ? _boilerFormat : _defaultFormat;
				if( display.getTextFormat() != format )
				{
					display.setTextFormat( format );
					// Base height on font size. This will be overwritten if multiline is true on input.
					display.height = int(format.size) * 1.25;
				}
			}
			
			// Offsetting based on clear button size and positioning.
			const offset:int = 8;
			var widthOffset:int = ( height / 2 ) + offset;
			// Update width based on offset.
			display.width = width - widthOffset;
			// Base height on multiline.
			if( display.multiline ) display.height = height;
			display.y = ( height - display.height ) / 2;
		}
		
		/**
		 * @inherit
		 */
		override public function initializeDisplay( width:int, height:int ):void
		{
			super.initializeDisplay( width, height );
			
			var inputTarget:TextInput = ( _target as TextInput );
			initializeBackground( inputTarget.backgroundDisplay, width, height );
			initializeClearDisplay( inputTarget.clearButtonDisplay, width, height );
			initializeInput( inputTarget.inputDisplay, width, height );
		}
		
		/**
		 * @inherit
		 */
		override public function updateDisplay( width:int, height:int ):void
		{
			super.updateDisplay( width, height );
			
			var inputTarget:TextInput = ( _target as TextInput );
			updateBackground( inputTarget.backgroundDisplay, width, height );
			updateClearDisplay( inputTarget.clearButtonDisplay, width, height );
			updateInput( inputTarget.inputDisplay, width, height );
		}
		
		/**
		 * @inherit
		 */
		override public function dispose():void
		{
			super.dispose();
			_defaultFormat = null;
		}
	}
}