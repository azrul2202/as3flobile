/**
 * <p>Original Author: toddanderson</p>
 * <p>Class File: IScrollViewportContext.as</p>
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
	import com.custardbelly.as3flobile.view.viewport.IScrollViewport;
	import com.custardbelly.as3flobile.view.viewport.IScrollViewportDelegate;
	
	import flash.display.InteractiveObject;
	import flash.geom.Rectangle;

	/**
	 * IScrollViewportContext provides a context for which a scrolling strategy can perform animation.  
	 * @author toddanderson
	 */
	public interface IScrollViewportContext
	{
		/**
		 * Initializes the context with a target IScrollViewport. 
		 * @param viewport IScrollViewport
		 */
		function initialize( viewport:IScrollViewport ):void;
		/**
		 * Updates the context and strategy.
		 */
		function update():void;
		/**
		 * Activates this context.
		 */
		function activate():void;
		/**
		 * Deactivates this context.
		 */
		function deactivate():void;
		/**
		 * Performs any clean up from the context.
		 */
		function dispose():void;
		
		/**
		 * Accessor/Modifier for the IScrollViewportStrategy. 
		 * @return IScrollViewportStrategy
		 */
		function get strategy():IScrollViewportStrategy;
		function set strategy( value:IScrollViewportStrategy ):void;
	}
}